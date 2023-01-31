public class aop_EventRequestTriggerAccessHandler {
    public Account CreateNewPersonAccount(Request__c evReq, aop_Area_Configuration__C eventConfig, List<RecordType> recordTypes)
    {        
        Account newAccount = new Account(aop_Country__pc = evReq.aop_Country__c, PersonMailingStreet = evReq.aop_Street__c, 
                                        PersonMailingCity = evReq.City__c, PersonMailingState = evReq.aop_State_Province__c, 
                                        PersonMailingPostalCode = evReq.aop_Postcode_Zip_Code__c, 
                                        PersonMailingCountry = evReq.aop_Country__c, Salutation = evReq.Salutation__c, 
                                        FirstName = evReq.First_Name__c, LastName = evReq.Last_Name__c, 
                                        Language__pc = evReq.Language__c, PersonEmail = evReq.Email__c, 
                                        PersonBirthdate = evReq.aop_Date_of_Birth__c, PersonMobilePhone = evReq.Mobile__c,
                                        PersonHomePhone = evReq.aop_Home_Phone__c, et4ae5__HasOptedOutOfMobile__pc = !evReq.Consent_SMS__c,
                                        Phone = evReq.aop_Home_Phone__c, 
                                        Direct_Mail_Opt_Out__pc = !evReq.Consent_Post__c, 
                                        PersonHasOptedOutOfEmail = !evReq.Consent_Email__c, 
                                        PersonDoNotCall = !evReq.Consent_Phone__c);
        RecordType rt;
        if(!recordTypes.isEmpty())
        {
            for(RecordType recType: recordTypes)
            {
                if(recType.DeveloperName == 'Individual' && recType.sObjectType == 'Account')
                {
                    rt = recType;
                    newAccount.RecordTypeId = rt.Id;
                    break;
                }
            }
        }
        if(eventConfig != null && eventConfig.aop_New_Record_Owner__c != null)
        {
            newAccount.ownerid= eventConfig.aop_New_Record_Owner__c;
        }
        string accountRegion = GetRegionOrMarket(evReq);
        if(accountRegion != null)
        {
            newAccount.Region_or_Market__c = accountRegion;
        }
        System.debug('1.Number of Queries used in this apex code so far: ' + Limits.getQueries() + ' AccessHandler line 35');
        return newAccount;
        
    }
    
    public string GetRegionOrMarket(Request__c evReq)
    {
        aop_NationalityToISOCode__c countryMap = aop_NationalityToISOCode__c.getInstance(evReq.aop_Country__c);
        string accountRegion = null;
        if(countryMap != null)
        {
            if(countryMap.aop_Region_or_Market__c != null)
            {
                accountRegion = countryMap.aop_Region_or_Market__c;
            }
        }
        return accountRegion;
    }

    public User IsContactCommunityUser(Id contactId)
    {
        List<User> existingUsers = [SELECT Id FROM User WHERE ContactId =: contactId AND IsPortalEnabled = true];
        if(!existingUsers.isEmpty())
        {
            return existingUsers[0];
        }
        return null;
    }

    public string GetUserName(Request__c request)
    {
        string toSearch = request.Email__c.Replace('@', '%@');
        integer length = toSearch.indexOf('@');
        string searchString = toSearch.substring(0, length);
        List<User> userList = [SELECT Username FROM User WHERE Email like: searchString];
        System.debug(userList);
        if(userList.isEmpty())
        {
            return request.Email__c;
        }
        else
        {
            string toReturn = toSearch.replace('%@', (userList.size() +1) + '@');
            return toReturn;
        }
    }

    public string GetCommunityNickName(Request__c request)
    {
        string concatName = request.Last_Name__c + request.First_Name__c;
        List<User> userList = [SELECT Username FROM User WHERE CommunityNickname like: concatName + '%'];
        if(userList.isEmpty())
        {
            return concatName;
        }
        else
        {
            integer size = userList.size() + 1;
            return concatName + size;
        }
    }

    public Id GetProfileID(string leName)
    {
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name =: leName];
        if(!profiles.isEmpty())
        {
            return profiles[0].Id;
        }
        return null;
    }

    public User CreateCommunityUser(Request__c request, aop_Area_Configuration__c areaConfig)
    {
        try
        {
            string alias1 = '';
            if(request.First_Name__c != null){
                alias1 = request.First_Name__c.substring(0,1);
            }
            string alias2 = request.Last_Name__c;
            if(alias2.length() > 7)
            {
                alias2 = request.Last_Name__c.substring(0,7);
            }

            string uName = GetUserName(request);
            string nickName = GetCommunityNickName(request);

            User newUser = new User(ContactID = request.aop_Customer__c, IsActive = true, CommunityNickname = nickName, 
                                    UserName = uName, FirstName = request.First_Name__c, LastName = request.Last_Name__c, 
                                    Alias = alias1+alias2, Email = request.Email__c, Phone = request.aop_Home_Phone__c, 
                                    MobilePhone = request.Mobile__c);
            string accountRegion = GetRegionOrMarket(request);
            if(accountRegion != null)
            {
                newUser.Market__c = accountRegion;
            }
            Id profId = GetProfileId('Customer Community Login User');
            if(profId != null)
            {
                newUser.ProfileId = profId;
            }
            else
            {
                return null;
            }
            aop_Locale_Mapping__c localeMap = GetLocaleMapping(request);
            if(localeMap != null)
            {
                newUser.EmailEncodingKey = localeMap.aop_Encoding__c;
                newUSer.TimeZoneSidKey = localeMap.aop_Time_Zone__c;
                newUser.LocaleSidKey = localeMap.aop_Locale_Code__c;
                newUser.LanguageLocaleKey = localeMap.aop_Salesforce_Language__c;
            }
            else
            {
                throw new aop_AOPException('No locale mapping found for locale ' + request.aop_Country__c + ' - could not create new portal user');
            }
            if(areaConfig != null)
            {
                newUser = UpdateExistingUser(newUser, request, areaConfig);
            }

            insert newUser;
            return newUser;
            }
        catch(exception e)
        {
            if(areaConfig != null && areaConfig.aop_New_Record_Owner__c != null)
            {
                Id targetId = areaConfig.aop_New_Record_Owner__c;
                Messaging.SingleEmailMessage newMessage = new Messaging.SingleEmailMessage();
                newMessage.setTargetObjectId(targetId);
                newMessage.saveAsActivity = false;
                newMessage.setSenderDisplayName('Salesforce Error Reporting');
                newMessage.setSubject('An error has occurred while creating a community user');
                newMessage.setPlainTextBody('An error was encountered creating a user for ' + request.First_Name__C + ' ' + request.Last_Name__C + ' error message: ' +e.getMessage());
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { newMessage });
            }

        }
        return null;
    }

    public void AssignPermissionSet(User newUser, string setId)
    {
        if(setId != null)
        {
            List<PermissionSet> permSets = [SELECT Id FROM PermissionSet WHERE Id =: setId LIMIT 1];
            if(!permSets.isEmpty() && newUser != null)
            {
                PermissionSet permSet = permSets[0];
                PermissionSetAssignment permAssign = new PermissionSetAssignment(AssigneeId = newUser.Id, PermissionSetId = permSet.Id);
                insert permAssign;
            }
            else
            {
                throw new aop_AOPException('Either permission set or user is missing - unable to assign');
            }
            //Update the user to advise that it has AOP Access
            if(newUser.aop_Has_AoP_Community_Access__c != true)
            {
                newUser.aop_Has_AoP_Community_Access__c = true;
                update newUser; 
            }
        }
        else
        {
            throw new aop_AOPException('No permission set ID specified for permission set assignment');
        }

    }

    public string GetCampaignNameFromRequest(Request__c evReq)
    {
        if(evReq != null && evReq.Campaign__c != null)
        {
            List<Campaign> campaignList = [SELECT Name FROM Campaign WHERE Id =: evReq.Campaign__c LIMIT 1];
            if(!campaignList.isEmpty())
            {
                return campaignList[0].Name;
            }
        }
        return null;
    }

    public void CreateCampaignMember(Contact con, Request__c evReq)
    {
        List<CampaignMember> memberList = [SELECT Id FROM CampaignMember WHERE Id =: evReq.Campaign__c AND ContactId =: con.Id];
        if(memberList.isEmpty())
        {
            CampaignMember newMemb = new CampaignMember(CampaignId = evReq.Campaign__c, aop_Session_Start__C = DateTime.Now(), 
                                                        aop_Session_End__c = DateTime.Now(), ContactID = con.Id, 
                                                        aop_CF_Status__C = 'Attended');
            insert newMemb;
        }

    }

    public aop_Locale_Mapping__c GetLocaleMapping(Request__c request)
    {
        Map<string, aop_Locale_Mapping__c> localeMap = aop_Locale_Mapping__c.getAll();
        if(localeMap != null)
        {
            for(aop_Locale_Mapping__c locale : localeMap.values())
            {
                if(locale.aop_Country__c == request.aop_Country__c && locale.aop_Language__c == request.Language__c)
                {
                    return locale;
                }
            }
        }
        return null;
    }

    public User UpdateExistingUser(User existingUser, Request__C evReq, aop_Area_Configuration__c areaConfig)
    {
        if(evReq != null && existingUser!= null && areaConfig != null)
        {
            existingUser.aop_AOP_Community_Path__c = areaConfig.aop_Community_URL__c;
            existingUser.aop_Has_AoP_Community_Access__c = true;
        }
        if(evReq.Campaign__c != null)
        {
            string campaignName = GetCampaignNameFromRequest(evReq);
            if(campaignName != null)
            {
                existingUser.aop_AOP_Welcome_Location__c = campaignName;
            }
        }
        return existingUser;
    }
}