public class aop_EventRequestTriggerQualifyHandler {
    public Request__c CheckContactCommunityAccess(Request__c evReq)
    {
        if(evReq.aop_Customer__c != null && evReq.aop_Status__c == System.label.aop_Submitted)
        {
            if(ContactHasCommunityAccess(evReq))
            {
                evReq.aop_Status__c = System.label.aop_No_Qualification_Required;
            }
        }
        return evReq;
    }
    
    public Boolean ContactHasCommunityAccess(Request__c evReq)
    {
        List<User> users = [SELECT aop_Has_AoP_Community_Access__c FROM User WHERE ContactId =: evReq.aop_Customer__c];
            if(!users .isEmpty())
            {
                if(users[0].aop_Has_AoP_Community_Access__c == true)
                {
                    return true;
                }
            }
        return false;
    }
    
    public Request__c QualifyRetailerEventRequest(Request__c evReq, List<Account> accountList)
    {
        if(evReq.Preferred_Retailer__c != null)
        {
            evReq.aop_Status__c = System.label.aop_Qualified;
        }
        else
        {
            if(evReq.Preferred_Retailer_Code__c != null && evReq.aop_Country__c != null)
            {
                aop_NationalityToISOCode__c countryMap = aop_NationalityToISOCode__c.getInstance(evReq.aop_Country__c);
                string isoCode = '';
                if(countryMap != null)
                {
                     isoCode  = countryMap.aop_ISO_Code__c;
                }
                string dealerCode = 'J'  + isoCode + evReq.Preferred_Retailer_Code__c;
                Account dealerAcc;
                if(!accountList.isEmpty())
                {
                	for(Account acc : accountList)
                	{
                		if(acc.Secondary_Dealer_Code__c == dealerCode)
                		{
                			dealerAcc = acc;
                			break;
                		}
                	}
                }
                if(dealerAcc != null)
                {
                    Account retailer = dealerAcc;
                    evReq.Preferred_Retailer__c = retailer.Id;
                    if(evReq.aop_Status__c != System.label.aop_No_Qualification_Required)
                    {
                         evReq.aop_Status__c = System.label.aop_Qualified;
                    }
                }
            }
        }
        return evReq;
    }
    
    public Request__c AssignToNamedQueue(Request__c evReq, string queueName)
    {
        if(queueName != null)
        {
            System.debug(queueName);
            List<Group> toAssign = [SELECT Id FROM Group WHERE Name =: queueName];
            if(!toAssign.isEmpty())
            {
                Group assignQueue = toAssign[0];
                evReq.OwnerId = assignQueue.Id;
            }
        }
        return evReq;
    }
    
    public Boolean IsCustomerOldEnough(Request__c evReq, aop_Area_Configuration__c evConfig)
    {
        if(evConfig.aop_Minimum_Age__c != null)
        {
            decimal age = evConfig.aop_Minimum_Age__c;
            integer ageAway = age.intValue();
            DateTime today = DateTime.now();
            DateTime minBirthday = today.addYears(- ageAway);
            if(evReq.aop_Date_of_Birth__c != null && evReq.aop_Date_of_Birth__c <= minBirthday)
            {
                return true;
            }
        }
        return false;
    }
    
    public Request__c QualifyByRules(Request__C evReq, aop_Area_Configuration__c eventConfig)
    {
        if(eventConfig.aop_Qualify_if_Opportunity__c == true)
        {
            evReq = QualifyByOpenOpportunity(evReq);
        }
        if(evReq.aop_Status__c != System.label.aop_Qualified && evReq.aop_Status__c != System.label.aop_Disqualified)
        {
            if(evReq.aop_Valid_Driving_License__c == true && CurrentBrandRelatedToConfig(evReq, eventConfig))
            {
                evReq.aop_Status__c = System.label.aop_Qualified;
            }
            else
            {
                evReq = AssignToNamedQueue(evReq, eventConfig.aop_Customer_Queue_Name__c);
            }
        }
        return evReq;
    }
    
    public Request__c QualifyByOpenOpportunity(Request__C evReq)
    {
        if(evReq.aop_Customer__c != null)
            {
                List<Contact> contacts = [SELECT AccountId FROM Contact WHERE Id =: evReq.aop_Customer__c];
                if(!contacts.isEmpty())
                {
                    List<Account> accounts = [SELECT Id FROM Account WHERE Id=: contacts[0].AccountId];
                    if(!accounts.isEmpty())
                    {
                        List<Opportunity> opps = [SELECT StageName FROM Opportunity WHERE AccountId =: accounts[0].Id AND IsClosed = false];
                        if(!opps.isEmpty())
                        {
                            evReq.aop_Status__c = System.label.aop_Qualified;
                        }
                    }
                }
            }
        return evReq;
    }
    
    public boolean CurrentBrandRelatedToConfig(Request__C evReq, aop_Area_Configuration__c eventConfig)
    {
        if(evReq.Current_Vehicle_Brand__c != null)
        {
            Id brandId = evReq.Current_Vehicle_Brand__c;
            List<aop_Area_Competitor__c> competitors = [SELECT Id FROM aop_Area_Competitor__c WHERE aop_Vehicle_Brand__c =: brandId AND aop_Event_Configuration__c =: eventConfig.Id];
            if(!competitors.isEmpty())
            {
                return true;
            }
        }
        return false;
    }
    
    public Request__c QualifyByRetailer(Request__c evReq, aop_Area_Configuration__c eventConfig)
    {
        if(evReq.aop_Status__c != System.label.aop_Qualified)
        {   if(eventConfig == null)
        	{
        		throw new aop_AOPException('No event config found for country ' + evReq.aop_country__c);
        	}                 
            else if(eventConfig.aop_Retailer_Queue_Name__c != null)
            {
                evReq = AssignToNamedQueue(evReq, eventConfig.aop_Retailer_Queue_Name__c);
            }
        }
        return evReq;
    }
    
    public Request__c AutoQualifyOrReject(Request__c evReq, aop_Area_Configuration__c eventConfig)
    {
        if(eventConfig != null && evReq != null)
        {
            if(eventConfig.aop_Auto_Rejection_Enabled__c == true)
            {
                Boolean oldEnough = IsCustomerOldEnough(evReq, eventConfig);
                if(!oldEnough)
                {
                    evReq.aop_Status__c = System.label.aop_Disqualified;
                    evReq.OwnerId = eventConfig.aop_New_Record_Owner__c;
                }
            }
            if(evReq.aop_Status__c == System.label.aop_Submitted && eventConfig.aop_Auto_Qualification__c == System.label.aop_Accept)
            {
                evReq.aop_Status__c = System.label.aop_Qualified;
            }
            else if(evReq.aop_Status__c == System.label.aop_Submitted && eventConfig.aop_Auto_Qualification__c == System.label.aop_Manual)
            {
                if(eventConfig.aop_Customer_Queue_Name__c != null)
                {
                    evReq = AssignToNamedQueue(evReq, eventConfig.aop_Customer_Queue_Name__c);
                }
            }
            else if(evReq.aop_Status__c == System.label.aop_Submitted && eventConfig.aop_Auto_Qualification__c == System.label.aop_Rules)
            {
                evReq = QualifyByRules(evReq, eventConfig);
            }
        }
        else
        {
            throw new aop_AOPException('No event config or event request found');
        }
        return evReq;
    }

}