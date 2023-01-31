public class aop_EventRequestTriggerLogic {
   
    public Request__c HandleEventRequestContact(Request__c evReq, List<Contact> contactList, List<aop_Area_Configuration__c> areaConfigs)
    {
        System.debug('1.Number of Queries used in this apex code so far: ' + Limits.getQueries() + ' TriggerLogi line 5');

        aop_EventRequestTriggerContactHandler businessLogic = new aop_EventRequestTriggerContactHandler();
        if(evReq.aop_Customer__c != null)
        {
            businessLogic.SetRequestFieldsFromContact(evReq, contactList);
            System.debug('1.Number of Queries used in this apex code so far: ' + Limits.getQueries() + ' TriggerLogi line 11');
        }
        else
        {
            evReq = businessLogic.PopulateExistingContact(evReq, contactList);
            /*if(evReq.aop_Customer__c != null)
            {
                businessLogic.SetRequestFieldsFromContact(evReq, contactList);
                System.debug('1.Number of Queries used in this apex code so far: ' + Limits.getQueries() + ' TriggerLogic line 19');
            }*/
        }
        evReq = businessLogic.SetNewOwner(evReq, areaConfigs);
        System.debug('1.Number of Queries used in this apex code so far: ' + Limits.getQueries() + ' TriggerLogic line 23');
            
        return evReq;
    }
    
    public static Boolean IsAOPRequest(Request__c evReq, List<RecordType> recordTypes)
    {
        System.debug('1.Number of Queries used in this apex code so far: ' + Limits.getQueries() + ' TriggerLogi line 30');
        RecordType preReg;
        RecordType walkIn;
        if(!recordTypes.isEmpty())
        {
            for(RecordType recType: recordTypes)
            {
                if(recType.DeveloperName == 'Pre_Registration_Request' && recType.sObjectType == 'Request__c')
                {
                    preReg = recType;
                }
                else if(recType.DeveloperName == 'Walk_In' && recType.sObjectType == 'Request__c')
                {
                    walkIn = recType;
                }
                System.debug('1.Number of Queries used in this apex code so far: ' + Limits.getQueries() + ' TriggerLogi line 45');
            }
        }
        if(preReg != null)
        {
            if(evReq.RecordTypeId == preReg.Id)
            {
                return true;
            }
        }
        if(walkIn != null)
        {
            if(evReq.RecordTypeId == walkIn.Id)
            {
                return true;
            }
        }
        System.debug('1.Number of Queries used in this apex code so far: ' + Limits.getQueries() + ' TriggerLogi line 62');
        return false;
    }
    

    
    public Request__c HandleNoQualificationNeeded(Request__c evReq)
    {
        System.debug('1.Number of Queries used in this apex code so far: ' + Limits.getQueries() + ' TriggerLogi line 70');
        if(evReq.aop_Customer__c != null && evReq.aop_Status__c == System.label.aop_Submitted)
        {
            aop_EventRequestTriggerQualifyHandler handler = new aop_EventRequestTriggerQualifyHandler();
            evReq = handler.CheckContactCommunityAccess(evReq);
            System.debug('1.Number of Queries used in this apex code so far: ' + Limits.getQueries() + ' TriggerLogi line 75');
        }     
        return evReq;
    }
    
    public Request__c HandleQualification(Request__c evReq, List<Account> accountList, List<aop_Area_Configuration__c> areaConfigs)
    {
        System.debug('1.Number of Queries used in this apex code so far: ' + Limits.getQueries() + ' TriggerLogi line 82');
        aop_EventRequestTriggerContactHandler contactHandler = new aop_EventRequestTriggerContactHandler();
        aop_Area_Configuration__c eventConfig = contactHandler.GetEventConfig(evReq, areaConfigs);
        aop_EventRequestTriggerQualifyHandler handler = new aop_EventRequestTriggerQualifyHandler();
        System.debug('1.Number of Queries used in this apex code so far: ' + Limits.getQueries() + ' TriggerLogi line 86');
        if(evReq.aop_Status__c == System.label.aop_Submitted && evReq.aop_Source__c == System.label.aop_Retailer)
        {
            evReq = handler.QualifyRetailerEventRequest(evReq, accountList);
            evReq = handler.QualifyByRetailer(evReq, eventConfig);
        }
        else if(evReq.aop_Status__c == System.label.aop_Submitted)
        {
            evReq = handler.AutoQualifyOrReject(evReq, eventConfig); 
        }
        return evReq;
    }
    
    public Request__c HandlePersonAccountCreation(Request__c evReq, List<RecordType> recordTypes, List<aop_Area_Configuration__c> areaConfigs)
    {
        System.debug('1.Number of Queries used in this apex code so far: ' + Limits.getQueries() + ' TriggerLogi line 101');
        if(evReq.aop_Status__c == System.label.aop_Qualified)
        {
            aop_EventRequestTriggerAccessHandler handler = new aop_EventRequestTriggerAccessHandler();
            if(evReq.aop_Customer__C == null)
            {
                System.debug('1.Number of Queries used in this apex code so far: ' + Limits.getQueries() + ' TriggerLogi line 107');
                aop_EventRequestTriggerContactHandler contactHandler = new aop_EventRequestTriggerContactHandler();
                aop_Area_configuration__c eventConfig = contactHandler.GetEventConfig(evReq, areaConfigs);
                Account newPerson = handler.CreateNewPersonAccount(evReq, eventConfig, recordTypes);
                System.debug('1.Number of Queries used in this apex code so far: ' + Limits.getQueries() + ' Logic line 111');
                insert newPerson;
                System.debug('1.Number of Queries used in this apex code so far: ' + Limits.getQueries() + ' Logic line 113');
                //Querying the created person account to get the contact ID
                newPerson = [SELECT Id, PersonContactId, Pseudo_Account_Owner__c FROM Account WHERE ID =: newPerson.Id LIMIT 1];
                System.debug('1.Number of Queries used in this apex code so far: ' + Limits.getQueries() + ' TriggerLogi line 114');
                if(newPerson.PersonContactId != null)
                {
                    evReq.aop_Customer__c = newPerson.PersonContactId;
                } 
            }
        }
        return evReq;
    }
    
    @future
    public static void HandleCommunityAccess(Id evReqID)
    {
        System.debug('1.Number of Queries used in this apex code so far: ' + Limits.getQueries() + ' TriggerLogi line127');
        List<Request__c> evReqs = [SELECT Campaign__c, Mobile__c, aop_Home_Phone__C, RecordTypeId, aop_Status__c, aop_Customer__c, 
                            Language__C, aop_Country__c, Email__C, First_Name__c, Last_Name__c, aop_Source__c 
                            FROM Request__c  WHERE Id =: evReqID LIMIT 1];
        if(!evReqs.isEmpty())
        {
            Request__c evReq = evReqs[0];
            aop_EventRequestTriggerContactHandler configGetter = new aop_EventRequestTriggerContactHandler();
            aop_Area_Configuration__c areaConfig = configGetter.GetEventConfigFuture(evReq);
            if(evReq.aop_Status__c == System.label.aop_Qualified)
            {
                //check contact has aop access
                HandleCommunityUser(evReq, areaConfig);
                System.debug('1.Number of Queries used in this apex code so far: ' + Limits.getQueries() + ' TriggerLogi line 140');
            }
        }
    }
    
    public Request__c HandleWalkIn(Request__c evReq, List<RecordType> recordTypes, List<aop_Area_Configuration__c> areaConfigs)
    {
        System.debug('1.Number of Queries used in this apex code so far: ' + Limits.getQueries() + ' TriggerLogi line 146');
        if(evReq.aop_Source__c == System.label.aop_Walk_in)
        {
            aop_EventRequestTriggerAccessHandler accessHandler = new aop_EventRequestTriggerAccessHandler();
            if(evReq.aop_Customer__c == null)
            {
                aop_EventRequestTriggerContactHandler contactHandler = new aop_EventRequestTriggerContactHandler();
                aop_Area_configuration__c eventConfig = contactHandler.GetEventConfig(evReq, areaConfigs);
                Account newAccount = accessHandler.CreateNewPersonAccount(evReq, eventConfig, recordTypes);
                System.debug('1.Number of Queries used in this apex code so far: ' + Limits.getQueries() + ' TriggerLogi line 155');
                
                insert newAccount;
                List<Account> accs = [SELECT Id, PersonContactId FROM Account WHERE ID =: newAccount.Id LIMIT 1];
                
                if(!accs.isEmpty() && accs[0] != null && accs[0].PersonContactId != null)
                {
                    Account acc = accs[0];
                    evReq.aop_Customer__c = acc.PersonContactId;
                    List<Contact> cons = [SELECT FirstName, LastName FROM Contact WHERE Id =: acc.PersonContactId LIMIT 1];
                    if(!cons.isEmpty())
                    {
                        Contact con = cons[0];
                        accessHandler.CreateCampaignMember(con, evReq);
                    }
                }
            }
            else
            {
                List<Contact> cons = [SELECT FirstName, LastName FROM Contact WHERE Id =: evReq.aop_Customer__c LIMIT 1];
                System.debug('1.Number of Queries used in this apex code so far: ' + Limits.getQueries() + ' TriggerLogi line 175');
                if(!cons.isEmpty())
                {
                    Contact con = cons[0];
                    con.aop_Country__c = evReq.aop_Country__c;
                    update con;
                    accessHandler.CreateCampaignMember(con, evReq);
                }
            }
        }
        return evReq;
    }
    
    @future
    public static void HandleWalkInCommunityAccess(Id evReqID)
    {
        System.debug('1.Number of Queries used in this apex code so far: ' + Limits.getQueries() + ' TriggerLogi line 191');
        List<Request__c> evReqs = [SELECT Mobile__c, aop_Home_Phone__C, Campaign__c, RecordTypeId, aop_Status__c, 
                            aop_Customer__c, Language__C, aop_Country__c, Email__C, First_Name__c, Last_Name__c, 
                            aop_Source__c FROM Request__c WHERE Id  =:  evReqId LIMIT 1];
        aop_EventRequestTriggerContactHandler configGetter = new aop_EventRequestTriggerContactHandler();
        if(!evReqs.isEmpty())
        {
            Request__c evReq = evReqs[0];
            aop_Area_Configuration__c areaConfig = configGetter.GetEventConfigFuture(evReq);
            if(evReq != null && evReq.aop_Source__c == System.label.aop_Walk_in)
            {
                HandleCommunityUser(evReq, areaConfig);
                System.debug('1.Number of Queries used in this apex code so far: ' + Limits.getQueries() + ' TriggerLogi line 203');
            }
        }
        
    }
    
    public static void HandleCommunityUser(Request__c evReq, aop_Area_Configuration__c areaConfig)
    {
        System.debug('1.Number of Queries used in this apex code so far: ' + Limits.getQueries() + ' TriggerLogi line 211');
        aop_eventRequestTriggerQualifyHandler qualHandler = new aop_eventRequestTriggerQualifyHandler();
        if(!qualHandler.ContactHasCommunityAccess(evReq))
        {
            string permId = null;
            if(areaConfig != null)
            {
                permId = areaConfig.aop_Community_Permission_Set__c;
            }
            //check if contact is already associated with customer community user
            aop_EventRequestTriggerAccessHandler accessHandler = new aop_EventRequestTriggerAccessHandler();
            User existingUser = accessHandler.IsContactCommunityUser(evReq.aop_Customer__c);
            System.debug('1.Number of Queries used in this apex code so far: ' + Limits.getQueries() + ' TriggerLogi line 223');
            if(existingUser == null)
            {
                User newUser = accessHandler.CreateCommunityUser(evReq, areaConfig);
                if(newUser != null && permId != null)
                {
                    accessHandler.AssignPermissionSet(newUser, permId);
                }
            }
            else if(existingUser != null && permId != null)
            {
                System.debug('1.Number of Queries used in this apex code so far: ' + Limits.getQueries() + ' TriggerLogi line 234');
                existingUser = accessHandler.UpdateExistingUser(existingUser, evReq, areaConfig);
                update existingUser;
                List<PermissionSetAssignment> permAssign = [SELECT Id FROM PermissionSetAssignment 
                                                            WHERE PermissionSetID =: permId AND AssigneeID =: existingUser.Id 
                                                            LIMIT 1];
                if(permAssign.isEmpty())
                {
                    accessHandler.AssignPermissionSet(existingUser, permId);
                }
            }
        }
    }
    
    public void SetContactQualified(Request__c evReq)
    {
        System.debug('1.Number of Queries used in this apex code so far: ' + Limits.getQueries() + ' TriggerLogi line 250');
        if(evReq != null && (evReq.aop_Status__c == System.label.aop_Qualified || (evReq.aop_Status__c == System.label.aop_No_Qualification_Required && evReq.aop_Source__c != System.label.aop_Walk_in)) && evReq.aop_Customer__c != null)
        {
            List<Contact> cons = [SELECT Id FROM Contact WHERE Id =: evReq.aop_Customer__c LIMIT 1];
            if(!cons.isEmpty())
            {
                Contact con = cons[0];
                con.aop_Is_Qualified_for_Events__c = true;
                update con;
            }
        }  
    }
    
    public void HandleBeforeUpdate(Request__c evReq, List<Request__c> oldMap, List<RecordType> recordTypes, List<Account>  accountList, List<aop_Area_Configuration__c>  configList, List<Contact> contactList)
    {
        System.debug('1.Number of Queries used in this apex code so far: ' + Limits.getQueries() + ' TriggerLogi line 265');
        if(evReq != null && oldMap != null)
        {
            if(!IsUpdateQueueRemoval(evReq, oldMap))
            {
                HandleEventRequestContact(evReq, contactList, configList);
                HandleQualification(evReq, accountList, configList);  
                HandlePersonAccountCreation(evReq, recordTypes, configList); 
                SetContactQualified(evReq);
                System.debug('1.Number of Queries used in this apex code so far: ' + Limits.getQueries() + ' TriggerLogi line 274');
            }
        }
    }
    
    public boolean IsUpdateQueueRemoval(Request__c newReq, List<Request__c> oldMap)
    {
        System.debug('1.Number of Queries used in this apex code so far: ' + Limits.getQueries() + ' TriggerLogi line 281');
        integer counter = 0;
        Map<string, Schema.SObjectField> fieldMap = Schema.SObjectType.Request__c.fields.getMap();
        Request__c oldReq;
        for(Request__c req : oldMap)
        {
            if(req.Id == newReq.Id)
            {
                oldReq = req;
            }
        }
        if(oldReq != null)
        {
            for(string fieldKey : fieldMap.keySet())
            {
                if(oldReq.get(fieldKey) != newReq.get(fieldKey))
                {
                    counter = counter + 1;
                }
            }
        }
        if(counter > 1)
        {
            return false;
        }
        else
        {
            if(oldReq != null && oldReq.OwnerId != newReq.OwnerID)
            {
                return true;
            }
            return false;
        }
    }
    
    public Request__c setLeftQueueTimeToNow(Request__c evReq)
    {
        try
        {
            Datetime startDate = System.Now();
            Datetime endDate = evReq.CreatedDate;  
            Integer intDays =  startDate.Date().daysBetween(endDate.Date());
            Datetime sameDayEndDate = startDate.addDays(intDays);     
            decimal decHours =  ((sameDayEndDate.getTime())/1000/60)- ((endDate.getTime())/1000/60);
            evReq.aop_Time_Left_In_Queue__c = decHours;
            return evReq;
        }
        catch(exception e)
        {
            system.debug(e.getMessage());
            return evReq;
        }
        
    }
}