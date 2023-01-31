public class AccountCustomerJourneyStatusHandler {
    static String ResolveVal = 'Resolve';
    static String selectVal = 'Select';
    static String enjoyVal = 'Enjoy';
    static String takeTheKeysVal = 'Take the Keys';
    static String maintainVal = 'Maintain';
    static String commitVal = 'Commit';
    static String renewVal = 'Renew';
    static String lapsedVal = 'Lapsed';
    static String ServiceDataStatus = 'Completed';    
    
    static set<String> caseStageSet = new set<String>{'Solved', 'Closed','Closed2', 'Cancelled'};
        static set<String> enjoyOppStageSet = new set<String>{'Handover','Won', 'Handover & RDA'};
            static set<String> commitOppStageSet = new set<String>{'Order','Order Taken'};
                static set<String> selectOppStageSet = new set<String>{'Qualify', 'Qualified', 'Test Drive Demo','Select Vehicle', 'Appraise','Negotiate','Negotiation','Contacted', 'Test Drive','Re-Opened','Appraisal','Negotiation & Approval','Vehicle Selection','Test Drive Taken/Booked'};
                    static set<String> accountRecordTypeSet = new set<String>{'Individual','Corporate'};
                        //'Contacted', 'Test Drive','Re-Opened','Negotiation','Appraisal','Negotiation & Approval','Vehicle Selection','Test Drive Taken/Booked'
                        
                        public static void SetAccountCustomerJourneyStage(List<Opportunity> opps, Map<Id, Opportunity> oldOppMap) {
                            map<Id,Opportunity> oppStageMap = new map<Id,Opportunity>();
                            
                            for(Opportunity opp : opps){
                                if(opp.accountId != null && accountRecordTypeSet.contains(opp.Account_Record_Type_Name__c)
                                   && opp.StageName != null && opp.IsCustomerJourneyStageMaintain__c != True
                                   && (oldOppMap == null || opp.StageName != oldOppMap.get(opp.Id).StageName)){
                                       oppStageMap.put(opp.AccountId,opp);
                                   }
                            }
                            
                            if(oppStageMap != null 
                               && !oppStageMap.isEmpty()){
                                   set<Id> accCaseIdSet = checkForClosedCase(oppStageMap.keyset()); 
                                   system.debug('accCaseIdSet --> '+accCaseIdSet);
                                   if(accCaseIdSet != null 
                                      && !accCaseIdSet.isEmpty()){
                                          SetCustomerStage(accCaseIdSet,oppStageMap,oldOppMap);
                                      }
                               }
                        }
    
    
    public static void SetCustomerStage(set<Id> accCaseIdSet, map<Id,Opportunity> oppStageMap,Map<Id, Opportunity> oldOppMap){
        
        system.debug('accCaseIdSet --> '+accCaseIdSet);
        system.debug('oppStageMap --> '+oppStageMap);
        system.debug('oldOppMap --> '+oldOppMap);
        
        map<id,Account> accountUpdateMap = new map<id,Account>();
        set<Id> accWithTaskIdsSet = new set<Id>();
        accWithTaskIdsSet = checkForOpenTasks(accCaseIdSet);
        for(id accIds : accCaseIdSet){
            if(oppStageMap.containskey(accIds)){
                
                Opportunity oppIns = oppStageMap.get(accIds);
                Account accIns = new Account();
                accIns.Id = accIds;
                system.debug('Stage Name --> '+oppIns.StageName);
                
                if(commitOppStageSet.contains(oppIns.stageName)){
                    accIns.Customer_Journey_Stage__c = commitVal;
                    accountUpdateMap.put(accIns.Id,accIns);
                    system.debug('Commit --> '+accountUpdateMap);
                    
                }else if(enjoyOppStageSet.contains(oppIns.StageName)){
                    accIns.Customer_Journey_Stage__c = takeTheKeysVal;
                    accountUpdateMap.put(accIns.Id,accIns);
                    system.debug('Take The Keys --> '+accountUpdateMap);
                    
                }else if(oppIns.Handover_Date__c != null && enjoyOppStageSet.contains(oppIns.StageName)){
                    accIns.Customer_Journey_Stage__c = enjoyVal;
                    accountUpdateMap.put(accIns.Id,accIns);
                    system.debug('Enjoy --> '+accountUpdateMap); 
                    
                } else if(selectOppStageSet.contains(oppIns.StageName)){
                    accIns.Customer_Journey_Stage__c = selectVal;
                    accountUpdateMap.put(accIns.Id,accIns);
                    system.debug('Select --> '+accountUpdateMap);
                    
                }
                /*else if(oppIns.iswon){
accIns.Customer_Journey_Indicator__c = renewVal;
accountUpdateMap.put(accIns.Id,accIns);
system.debug('Renew --> '+accountUpdateMap);

}else if(accWithTaskIdsSet != null 
&& !accWithTaskIdsSet.isEmpty() 
&& accWithTaskIdsSet.contains(accIds)){
accIns.Customer_Journey_Indicator__c = lapsedVal;
accountUpdateMap.put(accIns.Id,accIns);
system.debug('Lapsed --> '+accountUpdateMap); 
}*/
            }
        }
        
        system.debug('Account Update Map --> '+accountUpdateMap);
        if(accountUpdateMap != null
           && !accountUpdateMap.isEmpty()){
               updateAccountCustomerJourney(accountUpdateMap);
           }
    }
    
    
    
    public static void SetMaintainCustomerStage(List<Service_Data__c> serviceDataList){
        set<id> assetIdsSet = new set<id>();
        for(Service_Data__c serv : serviceDataList){
            if(serv.Service_Status__c != ServiceDataStatus && serv.Asset__c != null){
                assetIdsSet.add(serv.Asset__c);
            }
        }
        if(assetIdsSet != null && !assetIdsSet.isEmpty()){
            map<Id,Account> accountUpdateMap = new map<Id,Account>();
            for(Role__c roleIns : [select id,Account__c,Role__c,Vehicle__c from Role__c where Account__c != null and Vehicle__c in: assetIdsSet and Role__c = 'Current Owner' and Account__r.Record_Type_Name__c IN ('Individual','Corporate')]){
                Account accIns = new Account();
                accIns.id = roleIns.Account__c;
                accIns.Customer_Journey_Stage__c = maintainVal;
                accountUpdateMap.put(accIns.Id,accIns);
            }
            if(accountUpdateMap != null 
               && !accountUpdateMap.isEmpty()){
                   update accountUpdateMap.values();
               }
        }
    }
    
    public static void SetEnjoyCustomerStage(List<Service_Data__c> serviceDataList,map<Id,Service_Data__c> serviceDataMap){
        set<id> assetIdsSet = new set<id>();
        for(Service_Data__c serv : serviceDataList){
            if(serv.Service_Status__c == ServiceDataStatus 
               && serv.Asset__c != null 
               && serv.Service_Status__c != serviceDataMap.get(serv.Id).Service_Status__c){
                   assetIdsSet.add(serv.Asset__c);
               }
        }
        if(assetIdsSet != null && !assetIdsSet.isEmpty()){
            map<Id,Account> accountUpdateMap = new map<Id,Account>();
            for(Role__c roleIns : [select id,Account__c,Role__c,Vehicle__c from Role__c where Account__c != null and Vehicle__c in: assetIdsSet and Role__c = 'Current Owner' and Account__r.Record_Type_Name__c IN ('Individual','Corporate')]){
                Account accIns = new Account();
                accIns.id = roleIns.Account__c;
                accIns.Customer_Journey_Stage__c = enjoyVal;
                accountUpdateMap.put(accIns.Id,accIns);
            }
            if(accountUpdateMap != null 
               && !accountUpdateMap.isEmpty()){
                   update accountUpdateMap.values();
               }
        }
    }
    
    public static Set<Id> checkForOpenTasks(Set<Id> accIdsSet){
        List<Task> taskList = [select id,whatId from Task where whatId in:accIdsSet and isclosed = false];
        Set<Id> accWithTaskIdsSet = new set<Id>();
        for(Task tsk : taskList){
            if(!accIdsSet.contains(tsk.whatId)){
                accWithTaskIdsSet.add(tsk.whatId);
            }
        }
        if(accWithTaskIdsSet != null && !accWithTaskIdsSet.isEmpty()){
            return accWithTaskIdsSet;
        }
        return null;
    }
    
    public static Set<Id> checkForClosedCase(Set<Id> accIds){
        Set<Id> accsWithOpenCases = new Set<Id>();
        List<Account> openCaseAccList = new List<Account>();
        map<id,Account> accountUpdateMap = new map<id,Account>();
        for(AggregateResult c: [SELECT 
                                AccountId 
                                FROM 
                                Case 
                                WHERE 
                                AccountId=:accIds 
                                AND Status NOT IN: caseStageSet
                                AND Account_Record_Type_Name__c IN ('Individual','Corporate')
                                GROUP BY AccountId]){
                                    Id accountId = (Id) c.get('AccountId');
                                    accsWithOpenCases.add(accountId);
                                }
        
        if(!accsWithOpenCases.isEmpty()){
            for(id IdSet: accsWithOpenCases){
                Account accIns = new Account();
                accIns.ID = IdSet;
                accIns.Customer_Journey_Stage__c = ResolveVal;
                accountUpdateMap.put(accIns.Id,accIns);
            }
        }
        Set<Id> accsWithClosedCases = new Set<Id>();
        for(Id accId: accIds){
            if(!accsWithOpenCases.contains(accId)){
                accsWithClosedCases.add(accId);
            }
        }
        if(accountUpdateMap != null
           && !accountUpdateMap.isEmpty()){
               updateAccountCustomerJourney(accountUpdateMap);
           }
        
        return accsWithClosedCases;
    }
    
    public static void getAccountsForCRCCaseClosed(List<Case> cases, Map<Id,Case> oldCases){
        List<Case> closedCRCCasesWithAccount = new List<Case>();
        set<Id> closedaccountIdSset = new set<Id>();
        for(Case ca : cases){
            if(ca.AccountId != null 
               && (oldCases == null || ca.status != oldCases.get(ca.Id).status)){
                   closedaccountIdSset.add(ca.AccountId);
               }
        }
        if(!closedaccountIdSset.isEmpty()){
            map<id,integer> closedCountMap = new  map<id,integer>();
            for(AggregateResult aggr : [SELECT count(Id) cnt, accountId act FROM  case WHERE isclosed = true and  accountid IN:closedaccountIdSset AND Account_Record_Type_Name__c IN ('Individual','Corporate') group by accountId]){
                closedCountMap.put((String)aggr.get('act'),(Integer)aggr.get('cnt'));
            }
            
            map<id,integer> nonClosedCountMap = new  map<id,integer>();
            for(AggregateResult aggr : [SELECT count(Id) cnt, accountId act FROM  case WHERE isclosed = false and  accountid IN:closedaccountIdSset AND Account_Record_Type_Name__c IN ('Individual','Corporate') group by accountId]){
                nonClosedCountMap.put((String)aggr.get('act'),(Integer)aggr.get('cnt'));
            }
            
            map<Id,Account> accountUpdateMap = new map<Id,Account>();
            Set<Id> accountIdSetToCheckOpp = new Set<Id>();
            for(Id idIns : closedaccountIdSset){
                Account accIns = new Account();
                accIns.Id = idIns;
                if(closedCountMap.containskey(idIns) && !nonClosedCountMap.containskey(idIns)){
                    accIns.Customer_Journey_Stage__c = EnjoyVal;
                    accountUpdateMap.put(idIns,accIns);
                }else if(!closedCountMap.containskey(idIns) && nonClosedCountMap.containskey(idIns)){
                    accIns.Customer_Journey_Stage__c = ResolveVal;
                    accountUpdateMap.put(idIns,accIns);
                }
            }
            
            if(accountUpdateMap != null && !accountUpdateMap.isempty()){
                update accountUpdateMap.values();
            }
        }
    }
    
    public static void updateAccountCustomerJourney(map<id,Account> accountUpdateMap){
        system.debug('-->  '+json.serialize(accountUpdateMap.values()));
        Database.SaveResult[] srList = Database.update(accountUpdateMap.values(), false);
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {System.debug('Successfully updated account. Account ID: ' + sr.getId());}
            else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Account fields that affected this error: ' + err.getFields());
                }
            }
        }        
    }
}