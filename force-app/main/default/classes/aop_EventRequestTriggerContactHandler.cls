public class aop_EventRequestTriggerContactHandler {
    public Request__c PopulateExistingContact(Request__C evReq, List<Contact> contactList)
    { 
        ContactMatcher contactMatcher = new ContactMatcher();
            if(evReq.aop_Customer__c == null)
            {
                Contact existingContact = contactMatcher.GetMatchingContact(evReq.Last_Name__c, evReq.Email__c, evReq.Mobile__c);
                if(existingContact != null)
                {
                    evReq.aop_Customer__c = existingContact.Id;
                    if(existingContact != null)
                    {
                        if(existingContact.FirstName != null)
                        {
                            evReq.First_Name__c = existingContact.FirstName;
                        }
                        if(existingContact.LastName != null)
                        {
                            evReq.Last_Name__c = existingContact.LastName;                
                        }
                        if(existingContact.Email != null)
                        {
                            evReq.Email__c = existingContact.Email;
                        }
                        if(existingContact.Language__c != null)
                        {
                            aop_TridentLanguageMapping__c languageMap = aop_TridentLanguageMapping__c.getValues(existingContact.Language__c);
                            if(languageMap != null && languageMap.aop_Request_Language__c  != null)
                            {
                                evReq.Language__c = languageMap.aop_Request_Language__c;                    
                            }
                        }
                        if(existingContact.aop_Country__c != null)
                        {
                            evReq.aop_Country__c = existingContact.aop_Country__c;
                        }  
                        
                    }
                }
            }
        return evReq;

    }

    public Request__C SetNewOwner(Request__C request, List<aop_Area_Configuration__c> areaConfigs)
    {   
        aop_Area_Configuration__c eventConfig = GetEventConfig(request, areaConfigs);        
        if(eventConfig != null && eventConfig.aop_New_Record_Owner__c != null)
        {            
            request.OwnerId = eventConfig.aop_New_Record_Owner__c;
        }

        return request;
    }

    public aop_Area_Configuration__c GetEventConfig(Request__C request, List<aop_Area_Configuration__c> areaConfigs)
    {
        if(request.aop_Country__c != null)
        {
            aop_NationalityToISOCode__C countryKey = aop_NationalityToISOCode__c.getValues(request.aop_Country__c);
                if(countryKey != null)
                {
                    string checkfrontInstance = countryKey.aop_Checkfront_Instance__c;
                    if(areaConfigs != null && !areaConfigs.isEmpty())
                    {
                        for(aop_Area_Configuration__c config : areaConfigs)
                        {
                            if(config.aop_Checkfront_Instance__c == checkfrontInstance)
                            {
                                return config;
                            }
                        }
                    }
                }
        }
        return null;
    }

    public aop_Area_Configuration__c GetEventConfigFuture(Request__C request)
    {
        if(request.aop_Country__c != null)
        {
            aop_NationalityToISOCode__C countryKey = aop_NationalityToISOCode__c.getValues(request.aop_Country__c);
                if(countryKey != null)
                {
                    string checkfrontInstance = countryKey.aop_Checkfront_Instance__c;
                    List<aop_Area_Configuration__C> eventConfig  = [SELECT aop_Community_Permission_Set__c, 
                                                                    aop_Community_URL__c, aop_Qualify_if_Opportunity__c, 
                                                                    aop_Minimum_Age__c, aop_New_Record_Owner__c, 
                                                                    aop_Auto_Qualification__c,   aop_Auto_Rejection_Enabled__c, 
                                                                    aop_Customer_Queue_Name__c, aop_Retailer_Queue_Name__c 
                                                                    FROM aop_Area_Configuration__c
                                                                     WHERE aop_Checkfront_Instance__c =: checkfrontInstance];
                    if(!eventConfig.isEmpty() && eventConfig[0] != null)
                    {         
                        return eventConfig[0];
                    }
                }
        }
        return null;
    }

    public Request__c SetRequestFieldsFromContact(Request__c evReq, List<Contact> contactList)
    {
        if(evReq.aop_Customer__c != null)
        {
            Contact con;
            if(!contactList.isEmpty())
            {
                for(Contact contact : contactList)
                {
                    if(contact.Id == evReq.aop_Customer__c)
                    {
                        con = contact;
                    }
                }
            }
            if(con != null)
            {
                if(con.FirstName != null)
                {
                    evReq.First_Name__c = con.FirstName;
                }
                if(con.LastName != null)
                {
                    evReq.Last_Name__c = con.LastName;                
                }
                if(con.Email != null)
                {
                    evReq.Email__c = con.Email;
                }
                if(con.Language__c != null)
                {
                    aop_TridentLanguageMapping__c languageMap = aop_TridentLanguageMapping__c.getValues(con.Language__c);
                    if(languageMap != null && languageMap.aop_Request_Language__c  != null)
                    {
                        evReq.Language__c = languageMap.aop_Request_Language__c;                    
                    }
                }
                if(con.aop_Country__c != null)
                {
                    evReq.aop_Country__c = con.aop_Country__c;
                }  
            }                 
        }
        return evReq;
    }

}