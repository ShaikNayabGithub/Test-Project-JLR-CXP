public class aop_CheckfrontLogic {
    //Checks whether a campaign exists with same SKU as incoming booking
    public Campaign CheckForExistingCampaign(aop_CheckfrontWebService.aop_Checkfront newBooking)
    {
        if(newBooking.attributes.containsKey('host'))
        {
            string host = newBooking.attributes.get('host');
            if(newBooking.booking != null && newBooking.booking.order != null && newBooking.booking.order.items != null && newBooking.booking.order.items.item != null && newBooking.booking.order.items.item.attributes != null && newBooking.booking.order.items.item.attributes.containsKey('item_id'))
            {
                string itemID = newBooking.booking.order.items.item.attributes.get('item_id');                
                List<Campaign> foundCampaigns = [SELECT Id FROM Campaign WHERE 	aop_Checkfront_Item_Id__c =: itemID 
                									AND aop_Checkfront_Instance__C =: host];
                if(!foundCampaigns.isEmpty())
                {
                    return foundCampaigns[0];
                }
            }
        }
        return null; 
    }

    //Checks whether a campaign member with ID = incoming booking ID exists
    public CampaignMember CheckForExistingMember(Campaign existingCampaign, aop_CheckfrontWebService.aop_Checkfront newBooking)
    {
        if(newBooking.booking != null && newBooking.booking.code != null)
        {
            string bookingCode = newBooking.booking.code;
            List<CampaignMember> foundMembers = [SELECT Id FROM CampaignMember WHERE aop_CF_Booking_ID__c =: bookingCode
            									 AND CampaignId =: existingCampaign.Id];
            if(!foundMembers.isEmpty())
            {
                return foundMembers[0];
            }
        }
        return null;
    }

    //Updates existing or creates new campaign member with details of incoming booking
    public void UpsertCampaignMember(CampaignMember existingMember, aop_CheckfrontWebService.aop_Checkfront newBooking)
    {
        if(newBooking.booking.Status != '')
        {
            aop_CheckfrontStatuses__c statusMap = aop_CheckfrontStatuses__c.getValues(newBooking.booking.Status);
        	existingMember.aop_CF_Status__c = statusMap.aop_Salesforce_CF_Status__c;
        }
        if(newBooking.booking.start_date != '' && newBooking.booking.start_date != null)
        {
            long dateInt = long.valueOf(newBooking.booking.start_date + '000');
            existingMember.aop_Session_Start__c = Datetime.newInstance(dateInt);
        }
        if(newBooking.booking.end_date != ''  && newBooking.booking.end_date != null)
        {
            long endDateInt = long.valueOf(newBooking.booking.end_date + '000');
            existingMember.aop_Session_End__c = Datetime.newInstance(endDateInt);
        }
        upsert(existingMember);

        System.debug(existingMember);
    }

    //Called by aop_CheckfrontWebService to update salesforce with incoming booking
    public void HandleCheckfrontJSON(aop_CheckfrontWebService.aop_Checkfront newBooking)
    {
        Campaign campaign = CheckForExistingCampaign(newBooking);
        if(campaign != null)
        {
            CampaignMember campaignMem = CheckForExistingMember(campaign, newBooking);
            if(campaignMem != null)
            {
                UpsertCampaignMember(campaignMem, newBooking);
            }
            else
            {
                string checkfrontInstance = newBooking.attributes.get('host');
                List<aop_Area_Configuration__c> eventConfigs = [SELECT aop_Checkfront_Instance__c, aop_Checkfront_Token__c, aop_New_Record_Owner__c,
                                                                aop_New_Record_Owner__r.LanguageLocaleKey
	        												FROM aop_Area_Configuration__c 
	        												WHERE aop_Checkfront_Instance__c =: checkfrontInstance LIMIT 1];
                if(!eventConfigs.isEmpty() && eventConfigs != null && eventConfigs[0] != null && eventConfigs[0].aop_Checkfront_Token__c != null)
                {
                    aop_Area_Configuration__c eventConfig = eventConfigs[0];
                
                    string tid = GetTidFromCallback(newBooking, eventConfig);
                    if(tid != null)
                    {
                        Contact existingContact = CheckExistingContact(tid);
                        CampaignMember contactAlreadyBooked = CheckForSecondBooking(existingContact, campaign);
                        if(existingContact != null && contactAlreadyBooked == null)
                        {
                            CreateNewCampaignMember(newBooking, campaign, existingContact);
                        }
                        else if(existingContact != null && contactAlreadyBooked != null)
                        {
                            SendDuplicateEmail(eventConfig, newBooking, existingContact);
                        }
                    }
                }
            }
        }
    }
    
    public Messaging.SingleEmailMessage SendDuplicateEmail(aop_Area_Configuration__c eventConfig, aop_CheckfrontWebService.aop_Checkfront newBooking, Contact regarding)
    {
        //try{
            PageReference pr = new PageReference('/apex/aop_CheckfrontDuplicateError?language=' + eventConfig.aop_New_Record_Owner__r.LanguageLocaleKey);//Page.aop_CheckfrontDuplicateError;
            String pageAsString;
        	if(Test.isRunningTest())
            {
                pageAsString = '{PARAM1}{PARAM2}';
            }
        	else
            {
                pageAsString = pr.getContent().tostring();
                pageAsString = pageAsString.replace('{PARAM1}', regarding.Name);
            }
            //pageAsString = pageAsString.replace('{PARAM1}', regarding.Name);
            pageAsString = pageAsString.replace('{PARAM2}', newBooking.booking.code);
        
            Messaging.Singleemailmessage mail = new Messaging.Singleemailmessage();
            mail.setHtmlBody(pageAsString);
            Id targetUserID = eventConfig.aop_New_Record_Owner__c;
            mail.setTargetObjectId(targetUserId);
            mail.setSubject('TAOPT Duplicate');
            mail.saveAsActivity = false;
            Messaging.sendEmail(new Messaging.Singleemailmessage[] { mail});
            return mail;
        //}
        /*
        catch(exception e)
        {
            Messaging.SingleEmailMessage newEmail = new Messaging.SingleEmailMessage();
            newEmail.setSubject('error');
            newEmail.setToAddresses(new List<string>{'elizabeth.baird@nttdata.com'});
            newEmail.saveAsActivity = false;
            newEmail.setHTMLBody(e.getMessage());
            Messaging.sendEmail(new  List<Messaging.Email>{newEmail});
        }
        return null;*/
    }
    
    public CampaignMember CheckForSecondBooking(Contact existingContact, Campaign existingCampaign)
    {
        List<CampaignMember> existingMembers = [SELECT Id FROM CampaignMember WHERE ContactId =: existingContact.ID AND CampaignId =: existingCampaign.ID];
        if(!existingMembers.isEmpty())
        {
            return existingMembers[0];
        }
        return null;
    }

    //Creates a new campaign member with aop_CF_Booking_Id__c = booking code of incoming booking
    public CampaignMember CreateNewCampaignMember(aop_CheckfrontWebService.aop_Checkfront newBooking, Campaign existingCampaign, Contact existingContact)
    {
        CampaignMember newCM = new CampaignMember (ContactId = existingContact.Id, CampaignId = existingCampaign.Id, 
        											aop_CF_Booking_Id__c = newBooking.booking.code, aop_Booking_Id__C = '');
        UpsertCampaignMember(newCM, newBooking);
        return newCM;
    }


    //Checks for an existing contact/person account with ID = customer_tid in incoming booking
    public Contact CheckExistingContact(string tid)
    {
        List<Contact> contacts = [SELECT Id, Name FROM Contact WHERE Id =: tid];
        if(contacts.isEmpty())
        {
            List<Account> accounts = [SELECT PersonContactId FROM Account WHERE Id =: tid];
            if(accounts.isEmpty())
            {
                return null;
            }
            else
            {
                List<Contact> contactsRound2 = [SELECT Id, Name FROM Contact WHERE Id =: accounts[0].PersonContactId];
                if(!contactsRound2.isEmpty())
                {
                    return contactsRound2[0];
                }
            }
        }
        else
        {
            Contact existingContact = contacts[0];
            return existingContact;
        }
        return null;
    }

    //Callout to checkfront to get tid of booking
    public string GetTidFromCallback(aop_CheckfrontWebService.aop_Checkfront newBooking, aop_Area_Configuration__c eventConfig)
    {
        if(newBooking.attributes != null && newBooking.attributes.containsKey('host') && newBooking.booking.attributes.containsKey('booking_id'))
        {
            string checkfrontInstance = newBooking.attributes.get('host');
	        string bookingId = newBooking.booking.attributes.get('booking_id');
	        string query = '/api/3.0/booking/' + bookingId;

            aop_CheckfrontBookingCallout calloutClass =  new aop_CheckfrontBookingCallout();
            string toParse = calloutClass.GetCalloutResponse(eventConfig, query);
            aop_CheckfrontCalloutBookingParser.aop_Container containerObj = calloutClass.ParseToCalloutBooking(toParse);
            if(containerObj != null && containerObj.booking != null && containerObj.booking.tid != null)
            {
                string tid = containerObj.booking.tid;
                return tid;
            }
	        
        }
        return null;
    }

}