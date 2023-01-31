/*****************
Description - For Japan Shuho, all applicable leads are converted into Account/Contact/Opportunity
Applicable leads - Country_ISO_Code__c == 'JP' & Secondary_Lead_Source__c == 'Showroom Visit Form'
*****************/ 

public with sharing class LeadConversionHandler {
    
    private static Map<String,Schema.RecordTypeInfo> AccountSchema = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
    public static Id IndiAccountRT = AccountSchema.get('Individual').getRecordTypeId();
    public static Id IndiPrimAccountRT = AccountSchema.get('Individual_Golden_Record').getRecordTypeId();
    public static Id CorpAccountRT = AccountSchema.get('Corporate').getRecordTypeId();
    public static Id CorpPrimAccountRT = AccountSchema.get('Corporate_Golden_Record').getRecordTypeId();
    private static Map<String,Schema.RecordTypeInfo> EventSchema = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName();
    public static Id ShowroomApptRT = EventSchema.get('Showroom_appointment').getRecordTypeId();
    
    public static Map<Id,Id> DefaultUserMap = new Map<ID,ID>();
    public static List<Event> CreateEventsList = new List<Event>();
    public static String QUALIFIED = 'Qualified';
    public static String SHOWROOM_APPOINTMENT = Label.Shuho_Showroom_Appointment; //'Showroom appointment';
    
    @future
    public static void convertleads(String leadStr, Set<Id> LeadOwnerQIds){
        if(leadStr == null) return;
        List<Lead> LeadstoConvert = (List<Lead>)json.deserialize(leadStr, List<Lead>.class);
        Set<ID> CreatedContactIds = new Set<ID>();
        Set<ID> CreatedAccountIds = new Set<ID>();
        Map<Id,Id> CreatedOpptyIdLeadIdMap = new Map<Id,Id>();
        Map<Id,Id> LeadIdOwnerIdMap = new Map<Id,Id>();
        Map<Id,String> LeadIdDescriptionMap = new Map<Id,String>();
        list<Database.LeadConvert> leadConverts = new list<Database.LeadConvert>();
        
        //list<Database.LeadConvert> leadConverts = new list<Database.LeadConvert>();
        
        if(!LeadOwnerQIds.isEmpty()){
            populateDefaultUserMap(LeadOwnerQIds);
        }
        
        for(Lead Ld : LeadstoConvert){
            
            system.debug('£££ Inside Leads converting '+ Ld.Secondary_Lead_Source__c);
            system.debug('£££ Lead ID '+ Ld.Id);
            Database.LeadConvert objLeadConvert = new Database.LeadConvert();
            objLeadConvert.setLeadId(Ld.Id);
            objLeadConvert.setOpportunityName(Ld.Name);
            objLeadConvert.setConvertedStatus(QUALIFIED);
            
            if(string.valueOf(Ld.OwnerId).startswith('00G') && DefaultUserMap.get(Ld.OwnerId) != null){
                objLeadConvert.setOwnerId(DefaultUserMap.get(Ld.OwnerId));
                LeadIdOwnerIdMap.put(Ld.Id,DefaultUserMap.get(Ld.OwnerId));
                LeadIdDescriptionMap.put(Ld.Id,Ld.Description);
                leadConverts.add(objLeadConvert); // add the leads only if we have a owner defined for the new records, else do not convert
            }                
            else if(string.valueOf(Ld.OwnerId).startswith('005')){
                objLeadConvert.setOwnerId(Ld.OwnerId);
                LeadIdOwnerIdMap.put(Ld.Id,Ld.OwnerId);
                LeadIdDescriptionMap.put(Ld.Id,Ld.Description);
                leadConverts.add(objLeadConvert); // add the leads only if we have a owner defined for the new records, else do not convert
            }            
            
            /*Database.LeadConvertResult objLeadConvertResult = Database.convertLead(objLeadConvert);
system.debug('£££ After conversion getAccountId() '+ objLeadConvertResult.getAccountId());
system.debug('£££ After conversion getContactId() '+ objLeadConvertResult.getContactId());
system.debug('£££ After conversion getOpportunityId() '+ objLeadConvertResult.getOpportunityId());
system.debug('£££ After conversion isSuccess() '+ objLeadConvertResult.isSuccess());
system.debug('£££ After conversion getErrors() '+ objLeadConvertResult.getErrors());
CreatedContactIds.add(objLeadConvertResult.getContactId());
CreatedAccountIds.add(objLeadConvertResult.getAccountId());
CreatedOpportunityIds.add(objLeadConvertResult.getOpportunityId());*/
        }
        system.debug('leadConverts --->  '+leadConverts);
        if(!leadConverts.isEmpty()){
            for(Integer i = 0; i <= leadConverts.size()/100 ; i++){
                list<Database.LeadConvert> tempList = new list<Database.LeadConvert>();
                Integer startIndex = i*100;
                Integer endIndex = ((startIndex+100) < leadConverts.size()) ? startIndex+100: leadConverts.size();
                for(Integer j=startIndex;j<endIndex;j++){
                    tempList.add(leadConverts[j]);
                }
                Database.LeadConvertResult[] lcresultList = Database.convertLead(tempList, false);
                for(Database.LeadConvertResult lcr : lcresultList){
                    if(lcr.isSuccess()){
                        system.debug('££££ LeadConvertResult ' + lcr);
                        CreatedContactIds.add(lcr.getContactId());
                        CreatedAccountIds.add(lcr.getAccountId());
                        CreatedOpptyIdLeadIdMap.put(lcr.getOpportunityId(),lcr.getLeadID());
                    }else {
                        if(!test.isRunningTest()){
                            throw new ConvertLeadActionException(lcr.getErrors()[0].getMessage());     
                        }
                    }                  
                }
            }
        }        
        if(!CreatedOpptyIdLeadIdMap.keyset().isEmpty()){
            system.debug('££££ CreatedOpptyIdLeadIdMap ' + CreatedOpptyIdLeadIdMap);
            createEvents(CreatedOpptyIdLeadIdMap,LeadIdOwnerIdMap);
            updateOpportunity(CreatedOpptyIdLeadIdMap,LeadIdDescriptionMap);
        }
        if(!CreatedAccountIds.isEmpty())
            updateAccounts(CreatedAccountIds);
    }
    
    public static void populateDefaultUserMap(Set<Id> LeadOwnerQIds){
        List<Contact> OwnerContactsUserList = new List<Contact>([SELECT ID,Account_Queue_ID__c,(SELECT Id,ContactId FROM Users) FROM Contact WHERE Account_Queue_ID__c IN: LeadOwnerQIds AND Default_Retailer_Record_Owner__c =: TRUE]);
        system.debug('££££ OwnerContactsUserList ' + OwnerContactsUserList);
        Set<Id> OwnerContactIds = new Set<Id>();
        
        if(!OwnerContactsUserList.isEmpty()){
            for(Contact con : OwnerContactsUserList){
                for(User usr : con.Users){
                    if(LeadOwnerQIds.contains(con.Account_Queue_ID__c))
                        DefaultUserMap.put(con.Account_Queue_ID__c,usr.Id);
                    system.debug('££££ con.Account_Queue_ID__c '+con.Account_Queue_ID__c);
                    system.debug('££££ con.usr.Id '+ usr.Id);
                }
            }
        }
    }
    
    public static void createEvents(Map<Id,Id> CreatedOpptyIdLeadIdMap,Map<Id,Id> LeadIdOwnerIdMap){
        
        String STATUS_PLANNED = 'Planned';
        Datetime STARTDATE = DateTime.now();
        Datetime ENDDATE = STARTDATE.addHours(1);
        Id welComeRecTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Welcome_Questionnaire').getRecordTypeId();
        List<Task> taskInsertList = new List<Task>();
        
        for(Id oppId : CreatedOpptyIdLeadIdMap.keyset()){
            Event eve = new Event();
            eve.RecordtypeID = ShowroomApptRT;
            eve.Subject = SHOWROOM_APPOINTMENT;
            eve.OwnerId = LeadIdOwnerIdMap.get(CreatedOpptyIdLeadIdMap.get(oppId));
            eve.WhatId = oppId;
            eve.StartDateTime = STARTDATE;
            eve.EndDateTime = ENDDATE;
            eve.Test_Drive_Status__c = STATUS_PLANNED;
            CreateEventsList.add(eve);
            
            Task taskIns = new Task();
            taskIns.Subject = Label.Shuho_LEad_Conversion_Welcome_Questionnaire;
            taskIns.recordtypeid = welComeRecTypeId; 
            taskIns.whatid = oppId;
            taskIns.Status = 'Completed';
            taskIns.OwnerId = LeadIdOwnerIdMap.get(CreatedOpptyIdLeadIdMap.get(oppId));
            taskInsertList.add(taskIns);
                       
        }
        if(!CreateEventsList.isempty())
            insert CreateEventsList;
        
         if(!taskInsertList.isempty())
            insert taskInsertList;
    }
    
    
    public static void updateAccounts(Set<Id> CreatedAccountIds){
        //Map<Id,Contact> CreatedContacts = new Map<Id,Contact>([Select Id from Contact where Id IN: CreatedContactIds ]);
        Map<Id,Account> CreatedAccounts = new Map<Id,Account>([Select Id, RecordTypeID, Is_Primary__c, Primary_Account__c from Account where Id IN: CreatedAccountIds ]);
        //Map<Id,Opportunity> CreatedOpportunities = new Map<Id,Opportunity>([Select Id from Opportunity where Id IN: CreatedOpportunityIds ]);
        
        String JP_OWNER = 'Retailer Owner (JP)';
        ID DefaultOwnerJP = [SELECT Id FROM User WHERE Name =: JP_OWNER].Id;
        for(Account acc : CreatedAccounts.values()){
            
            if(acc.Is_Primary__c == true){
                system.debug('££££ Inside Created Account '+ acc.Id);
                system.debug('££££ Inside Created Account RT '+ acc.RecordTypeId);
                acc.Is_Primary__c = false;
                acc.Primary_Account__c = null;
                if(acc.RecordTypeId == CorpPrimAccountRT)
                    acc.RecordTypeId = CorpAccountRT;
                if(acc.RecordTypeId == IndiPrimAccountRT)
                    acc.RecordTypeId = IndiAccountRT;
            }
        }
        
        if(!CreatedAccounts.keyset().isEmpty()){
            Database.update(CreatedAccounts.values());
        }   
    }
    
    
    public static void updateOpportunity(Map<Id,Id> CreatedOpptyIdLeadIdMap,map<Id,String> LeadIdDescriptionMap){
        Id oppRecTypeId =  Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Sales_Process_with_RDA').getRecordTypeId();
        List<Opportunity> updateOpps = new List<Opportunity>();
        for(Id oppId : CreatedOpptyIdLeadIdMap.keyset()){
            system.debug('££££ oppId '+ oppId);
            Opportunity newOpp = new Opportunity();
            newOpp.Id = oppId;
            newOpp.recordTypeId = oppRecTypeId;
            newOpp.Description = LeadIdDescriptionMap.get(CreatedOpptyIdLeadIdMap.get(oppId));
            updateOpps.add(newOpp);
        }
        system.debug('££££ updateOpps ' + updateOpps);
        if(!updateOpps.isEmpty()){
            update updateOpps;
        }   
    }
    class ConvertLeadActionException extends Exception {}
}