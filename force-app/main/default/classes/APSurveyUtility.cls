public class APSurveyUtility {
    public static void PopulateAPSurveyContact(List<Opportunity> currentOpportunities, Map<Id, Opportunity> oldOpportunities){
        try{
            Set<String> surveyconfigset = new Set<String>();
            Map < String, AP_Survey_Config__mdt > retrieveCustomMetadataMap = AP_Survey_Config__mdt.getAll();
            // for(AP_Survey_Config__mdt mt :[SELECT Id, DeveloperName FROM AP_Survey_Config__mdt]){
            for(AP_Survey_Config__mdt mt : retrieveCustomMetadataMap.values()){
                surveyconfigset.add(mt.DeveloperName);
            }
            
            Set<ID> accIdset = new Set<ID>();
            
            for (Opportunity currOpp : currentOpportunities){
                if(surveyconfigset.contains(currOpp.Owner_Account_Country_ISO_Code__c) && (currOpp.StageName == 'Handover' || currOpp.StageName == 'Handover & RDA') && (oldOpportunities == null || (oldOpportunities.get(currOpp.id).StageName != 'Handover' && oldOpportunities.get(currOpp.id).StageName != 'Handover & RDA'))){
                    accIdset.add(currOpp.AccountId);
                }
            }
            
            If(accIdset.size()>0){
                Map<ID,Id> accountcontactmap = new Map<ID,Id>();
                for(Account acc : [select id,(select id from contacts limit 2) from Account where id IN: accIdset AND RecordType.DeveloperName = 'Corporate']){
                    if(acc.contacts.size()==1){
                        accountcontactmap.put(acc.id,acc.contacts[0].Id);
                    }
                }
                
                If(accountcontactmap.size()>0){
                    for (Opportunity currOpp : currentOpportunities){
                        if(accountcontactmap.containskey(currOpp.AccountId) && surveyconfigset.contains(currOpp.Owner_Account_Country_ISO_Code__c) && (currOpp.StageName == 'Handover' || currOpp.StageName == 'Handover & RDA') && (oldOpportunities == null || (oldOpportunities.get(currOpp.id).StageName != 'Handover' && oldOpportunities.get(currOpp.id).StageName != 'Handover & RDA'))){
                            currOpp.AP_Survey_Contact__c = accountcontactmap.get(currOpp.AccountId);
                        }
                    }
                }
            }
        }catch(exception e){
            //system.debug('Exception==='+e.getMessage());
        }
    }
    
    /*Update contact on Service data */
    public static void upopulateAPSurveyContactOnService(List<Service_Data__c> triggerNew){
        Set<String> surveyconfigset = new Set<String>();
        Map < String, AP_Survey_Config__mdt > retrieveCustomMetadataMap = AP_Survey_Config__mdt.getAll();
        // for(AP_Survey_Config__mdt mt :[SELECT Id, DeveloperName FROM AP_Survey_Config__mdt]){
        for(AP_Survey_Config__mdt mt : retrieveCustomMetadataMap.values()){
            surveyconfigset.add(mt.DeveloperName);
        }
        Map<Id, Id> mapAccounttoISOcode = new Map<Id, Id>();
        for(Service_Data__c sd : triggerNew){
            if(sd.Account__c != Null){
                mapAccounttoISOcode.put(sd.Account__c, null);
            }
        }
        if(mapAccounttoISOcode.keySet().size()>0){
            for(Account ac : [Select Id, Country_ISO_Code__c, (Select Id From Contacts LIMIT 2) From Account Where id IN :mapAccounttoISOcode.keySet()]){
                if(ac.Country_ISO_Code__c !=null){
                    if(surveyconfigset.contains(ac.Country_ISO_Code__c)){
                        if(ac.Contacts.size() == 1){
                            mapAccounttoISOcode.put(ac.Id, ac.Contacts[0].Id);
                        }                       
                    }
                }                               
            } 
            for(Service_Data__c sd : triggerNew){
                if(mapAccounttoISOcode.containskey(sd.Account__c)){
                    if(mapAccounttoISOcode.get(sd.Account__c) != null){
                        sd.AP_Survey_Contact__c = mapAccounttoISOcode.get(sd.Account__c);
                    }else{
                        sd.AP_No_Survey_Reason__c = 'No or more than one Contact';
                    }                
                }
            }
        }
    }
    
    
    //When AP Survey Response records is created then we managed sharing on the Survey Response to share it with the Active Partner users of the Retailer
    public static void createSurveyResponseShareRecords(List<AP_Survey_Response__c> listOfSurveyResonse){
        try{
            set<string> retailerIds = new set<string>(); 
            for(AP_Survey_Response__c objSurveyResonse : listOfSurveyResonse){
                if(string.isNotBlank(objSurveyResonse.Retailer__c)){
                    retailerIds.add(objSurveyResonse.Retailer__c);
               }
            }
            map<string,Set<string>> mapOfAccountUsers = new map<string,Set<string>>();
            Map<Id,Contact> mapOfContacts=New  Map<Id,Contact>([Select id,AccountId from Contact where AccountId In:retailerIds]);
           if(mapOfContacts != null && mapOfContacts.size() > 0){
               For(User objUsers : [Select Id,contactId from User where contactId in:mapOfContacts.KeySet() and IsActive =true]){
                   Set<string> userIds= new Set<string>();
                    if(mapOfContacts.containsKey(objUsers.contactId) &&  mapOfAccountUsers.containsKey(mapOfContacts.get(objUsers.contactId).AccountId)){
                        userIds = mapOfAccountUsers.get(mapOfContacts.get(objUsers.contactId).AccountId);
                    }
                    userIds.add(objUsers.id);  
                    mapOfAccountUsers.put(mapOfContacts.get(objUsers.contactId).AccountId,userIds);
                }
            }
            list<AP_Survey_Response__Share> listOfSurveyShare = new list<AP_Survey_Response__Share>();
            if(mapOfAccountUsers != null && mapOfAccountUsers.size() > 0){
               for(AP_Survey_Response__c objSurveyResonse : listOfSurveyResonse){
                    if(string.isNotBlank(objSurveyResonse.Retailer__c) && mapOfAccountUsers.containsKey(objSurveyResonse.Retailer__c)){
                        Set<string> userIds = mapOfAccountUsers.get(objSurveyResonse.Retailer__c);
                        if(userIds != null && userIds.size() > 0){
                           for(String userId:  userIds){
                               listOfSurveyShare.add(createSurveyResponseRecords(objSurveyResonse.id,userId,'Read'));
                            }
                        }
                    }
                }   
            }
            if(listOfSurveyShare != null && listOfSurveyShare.size() > 0){
                Database.SaveResult[] lsr = Database.insert(listOfSurveyShare,false);
            }
        }catch(exception e){
            system.debug('Exception==='+e.getMessage());
        }
    }
    //Return AP_Survey_Response__Share object accordin to parameters details
    private Static AP_Survey_Response__Share createSurveyResponseRecords(string surveyResponseId,String userId,String accessLevel){
        AP_Survey_Response__Share objShare = new AP_Survey_Response__Share();
        objShare.ParentId = surveyResponseId;
        objShare.UserOrGroupId = userId;
        objShare.AccessLevel =accessLevel;
        objShare.RowCause = schema.AP_Survey_Response__Share.RowCause.Apex_Managed_Sharing_of_AP_Surveys__c;
        return objShare;        
    }
    
    /*When a ServiceData record is created, take the Asset ID from Service Data
        get the matching asset record and find the recent service data records for the same Asset.
        1) If the Service data records found: Take the difference between Service Repair Dates on the New and Last Service Data record.If the difference is greater than 45 days then set the "45 Days after Last Repair Date?" to TRUE.
        2) If no record found: Set the "45 Days after Last Repair Date?" to TRUE.
    */
    public static void updateLastRepairDateCheckBox(List<Service_Data__c> newServices){
        try{
            Set<String> surveyconfigset = new Set<String>();
            Map < String, AP_Survey_Config__mdt > retrieveCustomMetadataMap = AP_Survey_Config__mdt.getAll();
            // for(AP_Survey_Config__mdt mt :[SELECT Id, DeveloperName FROM AP_Survey_Config__mdt]){
            for(AP_Survey_Config__mdt mt : retrieveCustomMetadataMap.values()){
                surveyconfigset.add(mt.DeveloperName);
            }
            
            Set<Id> accIds = new Set<Id>();
            for(service_Data__c e : newServices){
                accIds.add(e.Account__c);
            }
            
            Map<Id,Account> accMap = new Map<Id,Account>([Select id,Country_ISO_Code__c from Account where Id in:accIds and Country_ISO_Code__c in:surveyconfigset]);
            
            //Set containing all assets ID in the current Event Detail list
            Set<ID> assetIdSet = new Set<ID>();
            //Add the Asset IDs to the respective Sets
            for(service_Data__c e : newServices){
                If(e.Account__c!=null && accMap.containsKey(e.Account__c) && string.isnotBlank(e.Asset__c)){
                    assetIdSet.add(e.Asset__c);
                }
            }
            If(assetIdSet.size()>0){
                Map<Id,service_Data__c> mapOfOldServiceDataRepairDate = getExisitingServiceDataRepairDate(assetIdSet);
                for(service_Data__c e : newServices){
                    if(e.Service_Repair_Date__c != null && e.Account__c!=null && accMap.containsKey(e.Account__c) && string.isNotBlank(e.Asset__c)){
                        if(mapOfOldServiceDataRepairDate != null && mapOfOldServiceDataRepairDate.size() > 0 && mapOfOldServiceDataRepairDate.containsKey(e.Asset__c)){
                            service_Data__c objOldServiceData = mapOfOldServiceDataRepairDate.get(e.Asset__c);
                            if(objOldServiceData.Service_Repair_Date__c.date().daysBetween(e.Service_Repair_Date__c.date()) > 45 )  {
                                e.X45_Days_after_Last_Repair_Date__c = true;
                            }
                        }else{
                            e.X45_Days_after_Last_Repair_Date__c = true;  
                        }
                    }
                }
            }
        }catch(exception e){
            //system.debug('Exception==='+e.getMessage());
        }
    }
    
    //Get the matching asset record and find the recent 1 service data records for the same Asset
    private static Map<Id,service_Data__c> getExisitingServiceDataRepairDate(Set<ID> assetIdSet){
        Map<Id,service_Data__c> mapOfServiceData = new Map<Id,service_Data__c>();
        for(service_Data__c objServiceData : [select id, Service_Repair_Date__c,Asset__c from service_Data__c 
                                              where Asset__c in: assetIdSet
                                              order by Service_Repair_Date__c desc] ){
                                                  if(!mapOfServiceData.containsKey(objServiceData.Asset__c) && objServiceData.Service_Repair_Date__c != null){
                                                      mapOfServiceData.put(objServiceData.Asset__c,objServiceData);
                                                  }
                                              }
        return mapOfServiceData;
    }
}