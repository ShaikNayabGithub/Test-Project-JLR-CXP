public class AccountJagANDLRStatusHandler { 
    
    public static String jaguarBrand = 'Jaguar';
    public static String landRoverBrand = 'Land Rover';
    public static String customerStatus = 'Customer';
    public static String lapsedCustomerStatus = 'Lapsed Customer';
    public static String repeatCustomerStatus = 'Repeat Customer';
    public static String previousOwner = 'Previous Owner';
    public static String currentOwner = 'Current Owner';
    static Id corpRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate').getRecordTypeId();
    static Id individualRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();
    public static list<String> roleList = new list<String>{'Current Owner','Previous Owner'};
        public static list<String> custJouStatusset = new list<String>{'Lapse'};
            
            @future
            public static void updateLRAndJaguarStatus(String oppStr,String oldOppMapStr) {
                List<Opportunity> opportunities = new List<Opportunity>();
                map<Id,Opportunity> oldOppMap = new map<Id,Opportunity>();
                if(oppStr != null){
                    opportunities = (List<Opportunity>)json.deserialize(oppStr, List<Opportunity>.class);
                }
                if(oldOppMapStr != null){
                    oldOppMap = (map<Id,Opportunity>)json.deserialize(oldOppMapStr, map<Id,Opportunity>.class);
                }
                set<id> accountIdsSet = new set<id>();
                set<id> oppIdsSet = new set<id>();
                set<id> nonPrimaryaccIdsSet = new set<id>();
                set<String> brandSet = new set<String>();
                map<String,List<Role__c>> accountRoleMap = new map<String,List<Role__c>>();
                for(Opportunity opp : opportunities){
                    if(opp.stageName != null
                       && opp.accountid != null
                       && opp.Brand__c != null
                       && (oldOppMap.isEmpty() ||  (!oldOppMap.isEmpty() && opp.stageName != oldOppMap.get(opp.Id).stageName))){
                           oppIdsSet.add(opp.Id);
                           accountIdsSet.add(opp.accountid);
                       }
                }
                
                if(accountIdsSet != null && !accountIdsSet.isEmpty()){
                    for(Opportunity opp : [select id,brand__r.name from opportunity where accountid IN: accountIdsSet]){
                        brandSet.add(opp.brand__r.name);
                    }
                    system.debug('brandSet--> '+brandSet);   
                    if(brandSet != null && !brandSet.isEmpty()){
                        system.debug('accountIdsSet--> '+accountIdsSet);
                        for(Account accIns : [select id,recordtypeid from Account where id in:accountIdsSet 
                                              AND (recordtypeid =:corpRecTypeId OR recordtypeid =:individualRecTypeId)]){
                                                  nonPrimaryaccIdsSet.add(accIns.Id);
                                              }
                    }
                    system.debug('nonPrimaryaccIdsSet--> '+nonPrimaryaccIdsSet);   
                    
                    if(nonPrimaryaccIdsSet != null
                       && !nonPrimaryaccIdsSet.isEmpty()){
                           for(Role__c rlIns : [select id,Role__c,Account__c,vehicle__r.name,Vehicle__r.brand__r.name,Vehicle__r.brand__c
                                                from Role__c 
                                                where 
                                                Account__c in: nonPrimaryaccIdsSet 
                                                AND Account__c != null
                                                AND Vehicle__c != null
                                                AND Vehicle__r.brand__c != null
                                                AND Vehicle__r.brand__r.name in: brandSet
                                                AND Role__c != 'Previous Owner']){
                                                    
                                                    if(!accountRoleMap.containskey(rlIns.Account__c+'-'+rlIns.vehicle__r.brand__r.name)){
                                                        accountRoleMap.put(rlIns.Account__c+'-'+rlIns.vehicle__r.brand__r.name,new List<Role__c>{rlIns});
                                                    }else{
                                                        accountRoleMap.get(rlIns.Account__c+'-'+rlIns.vehicle__r.brand__r.name).add(rlIns);
                                                    }
                                                }
                       }
                    system.debug('accountRoleMap--> '+accountRoleMap);
                    system.debug('oppIdsSet--> '+oppIdsSet);
                    if(oppIdsSet != null
                       && !oppIdsSet.isEmpty()){
                           map<Id,Account> accountUpdateMap = new map<Id,Account>();
                           for(Opportunity opp : [select 
                                                  id,Brand__c,Brand__r.Name,isWon,IsClosed,accountid,account.ntt_Jaguar_Status__c,account.ntt_Land_Rover_Status__c 
                                                  from opportunity 
                                                  where 
                                                  accountid in:nonPrimaryaccIdsSet and accountid != null AND Brand__c != null]){
                                                      if(!accountRoleMap.containskey(opp.AccountId+'-'+opp.Brand__r.Name)){
                                                          system.debug('won --> '+opp.iswon);
                                                          system.debug('Brand --> '+opp.Brand__r.Name);
                                                          system.debug('Jaguar_Status --> '+opp.account.ntt_Jaguar_Status__c);
                                                          if(opp.Brand__r.Name == jaguarBrand){
                                                              Account accIns = new Account();
                                                              accIns.Id = opp.AccountId;
                                                              if(opp.IsWon){
                                                                  accIns.ntt_Jaguar_Status__c = 'Customer';
                                                              }else if(!opp.IsWon && !opp.IsClosed){
                                                                  accIns.ntt_Jaguar_Status__c = 'Prospect';
                                                              }
                                                              accountUpdateMap.put(accIns.Id,accIns);                                                      
                                                          }else if(opp.Brand__r.Name == landRoverBrand){
                                                              Account accIns = new Account();
                                                              accIns.Id = opp.AccountId;
                                                              if(opp.IsWon){
                                                                  accIns.ntt_Land_Rover_Status__c = 'Customer';
                                                              }else if(!opp.IsWon && !opp.IsClosed){
                                                                  accIns.ntt_Land_Rover_Status__c = 'Prospect';
                                                              }
                                                              accountUpdateMap.put(accIns.Id,accIns);   
                                                          }
                                                      }
                                                  }
                           system.debug('accountUpdateMap--> '+accountUpdateMap);
                           if(accountUpdateMap != null
                              && !accountUpdateMap.isEmpty()){
                                  update accountUpdateMap.values();
                              }
                       }
                }
            }
    
    @future
    public static void handleJaguarAndLandRoverStatusRole(String roleJsonStr,String roleOldMapStr){
        List<Role__c> currentRoles = new List<Role__c>();
        map<Id,Role__c> oldMap = new map<Id,Role__c>();
        if(roleJsonStr != null){
            currentRoles = (List<Role__c>)json.deserialize(roleJsonStr, List<Role__c>.class);
        }
        if(roleOldMapStr != null){
            oldMap = ( map<Id,Role__c>)json.deserialize(roleOldMapStr,  map<Id,Role__c>.class);
        }
        
        
        
        map<Id,Role__c> roleMap = new map<Id,Role__c>();
        Id accRecTypeId = Schema.SObjectType.Role__c.getRecordTypeInfosByDeveloperName().get('Account').getRecordTypeId();
        for(Role__c rl: currentRoles){
            if(rl.recordTypeId == accRecTypeId && (oldMap.isEmpty() && rl.Account__c != null && rl.Vehicle__c != null && rl.Role__c != null)
               || (!oldMap.isEmpty() && rl.Account__c != null && rl.Vehicle__c != null && rl.Role__c != null
                   && ((rl.Account__c != null && rl.Account__c != oldMap.get(rl.Id).Account__c)
                       || (rl.Vehicle__c != null && rl.Vehicle__c != oldMap.get(rl.Id).Vehicle__c)
                       || (rl.Role__c != null && rl.Role__c != oldMap.get(rl.Id).Role__c)
                      ))){
                          roleMap.put(rl.Account__c,rl);
                      }
        }
        
        system.debug('roleMap --> '+roleMap);        
        if(roleMap != null 
           && !roleMap.isEmpty()){
               map<Id,integer> oppCountMap = new map<Id,integer>();
               for(AggregateResult aggr : [select count(id) cnt,accountid acId from opportunity 
                                           where accountid != null 
                                           AND accountid IN: roleMap.keyset() 
                                           AND (account.recordtypeid =:corpRecTypeId OR account.recordtypeid =:individualRecTypeId)
                                           Group by accountid ]){
                                               id accountId = (id)aggr.get('acId');
                                               integer oppcnt = (integer)aggr.get('cnt');
                                               oppCountMap.put(accountId,oppcnt);                           
                                           }
               
               
               map<Id,List<accountRolerWrapper>> jaguarRoleWrapperMap = new map<Id,List<accountRolerWrapper>>();
               map<Id,List<accountRolerWrapper>> landRoverRoleWrapperMap = new map<Id,List<accountRolerWrapper>>();
               for(Role__c role : [select Account__c,Role__c,Vehicle__r.Brand__r.Name
                                   from Role__c 
                                   where 
                                   Account__c IN: roleMap.keyset() 
                                   AND Account__c != null 
                                   AND Role__c != null
                                   AND Vehicle__c != null
                                   AND Role__c IN: roleList
                                   AND (Account__r.recordtypeid =:corpRecTypeId OR Account__r.recordtypeid =:individualRecTypeId)
                                  ]){
                                      if(role.Vehicle__c != null
                                         && role.Vehicle__r.Brand__c != null
                                         && role.Vehicle__r.Brand__r.Name != null
                                         && role.Vehicle__r.Brand__r.Name == jaguarBrand)   { 
                                             accountRolerWrapper roleIns = new accountRolerWrapper();
                                             roleIns.role = role.Role__c;
                                             roleIns.accountIns = role.Account__c;
                                             //roleIns.count = (integer)aggr.get('cnt');
                                             if(!jaguarRoleWrapperMap.containskey(roleIns.accountIns)){
                                                 jaguarRoleWrapperMap.put(roleIns.accountIns,new List<accountRolerWrapper>{roleIns});
                                             }else{
                                                 jaguarRoleWrapperMap.get(roleIns.accountIns).add(roleIns); 
                                             }
                                         }
                                  }
               
               for(Role__c role : [select Account__c,Role__c,Vehicle__r.Brand__r.Name
                                   from Role__c 
                                   where 
                                   Account__c IN: roleMap.keyset() 
                                   AND Role__c IN: roleList
                                   AND Account__c != null
                                   AND Role__c != null
                                   AND Vehicle__c != null
                                   AND (Account__r.recordtypeid =:corpRecTypeId OR Account__r.recordtypeid =:individualRecTypeId)
                                  ]){
                                      if(role.Vehicle__c != null
                                         && role.Vehicle__r.Brand__c != null
                                         && role.Vehicle__r.Brand__r.Name != null
                                         && role.Vehicle__r.Brand__r.Name == landRoverBrand)   { 
                                             accountRolerWrapper roleIns = new accountRolerWrapper();
                                             roleIns.role = role.Role__c;
                                             roleIns.accountIns = role.Account__c;
                                             // roleIns.count = (integer)aggr.get('cnt');
                                             if(!landRoverRoleWrapperMap.containskey(roleIns.accountIns)){
                                                 landRoverRoleWrapperMap.put(roleIns.accountIns,new List<accountRolerWrapper>{roleIns});
                                             }else{
                                                 landRoverRoleWrapperMap.get(roleIns.accountIns).add(roleIns); 
                                             }
                                         }
                                  }
               system.debug('jaguarRoleWrapperMap --> '+json.serialize(jaguarRoleWrapperMap));
               system.debug('landRoverRoleWrapperMap --> '+json.serialize(landRoverRoleWrapperMap));
               
               if(jaguarRoleWrapperMap != null 
                  && !jaguarRoleWrapperMap.isEmpty()){
                      map<Id,Account> accountUpdateMap = new map<Id,Account>();
                      for(id acc : jaguarRoleWrapperMap.keyset()){
                          List<accountRolerWrapper> accWrapList = jaguarRoleWrapperMap.get(acc);
                          Account accIns = new Account();
                          if(accWrapList.size() == 1 && accWrapList.get(0).role == currentOwner){
                              accIns.Id = acc;
                              accIns.ntt_Jaguar_Status__c = customerStatus;
                              accountUpdateMap.put(accIns.Id,accIns);
                          }else{
                              boolean isPrevious;
                              boolean iscurrent;
                              for(accountRolerWrapper acWrap : accWrapList){
                                  if(acWrap.role == previousOwner){
                                      if(isPrevious == null)  isPrevious = true;
                                  }else if(acWrap.role == currentOwner){
                                      isPrevious = false;
                                      iscurrent = true;
                                  }
                              }
                              //&& (!oppCountMap.containskey(acc) || (oppCountMap.containskey(acc) && oppCountMap.get(acc) == 0))
                              if(isPrevious){
                                  accIns.Id = acc;
                                  accIns.ntt_Jaguar_Status__c = lapsedCustomerStatus;
                                  accountUpdateMap.put(accIns.Id,accIns);
                              }else if(iscurrent){
                                  accIns.Id = acc;
                                  accIns.ntt_Jaguar_Status__c = repeatCustomerStatus;
                                  accountUpdateMap.put(accIns.Id,accIns);
                              }
                          }
                      }
                      system.debug('--> '+accountUpdateMap);
                      if(accountUpdateMap != null 
                         && !accountUpdateMap.isEmpty()){
                             system.debug('accountUpdateMap --> '+json.serialize(accountUpdateMap));
                             update accountUpdateMap.values();
                         }
                  }
               
               if(landRoverRoleWrapperMap != null 
                  && !landRoverRoleWrapperMap.isEmpty()){
                      
                      map<Id,Account> accountUpdateMap = new map<Id,Account>();
                      for(id acc : landRoverRoleWrapperMap.keyset()){
                          List<accountRolerWrapper> accWrapList = landRoverRoleWrapperMap.get(acc);
                          Account accIns = new Account();
                          if(accWrapList.size() == 1 && accWrapList.get(0).role == currentOwner){
                              accIns.Id = acc;
                              accIns.ntt_Land_Rover_Status__c = customerStatus;
                              accountUpdateMap.put(accIns.Id,accIns);
                          }else{
                              boolean isPrevious;
                              boolean iscurrent;
                              for(accountRolerWrapper acWrap : accWrapList){
                                  if(acWrap.role == previousOwner){
                                      if(isPrevious == null)  isPrevious = true;
                                  }else if(acWrap.role == currentOwner){
                                      isPrevious = false;
                                      iscurrent = true;
                                  }
                              }
                              if(isPrevious){
                                  accIns.Id = acc;
                                  accIns.ntt_Land_Rover_Status__c = lapsedCustomerStatus;
                                  accountUpdateMap.put(accIns.Id,accIns);
                              }else if(iscurrent){
                                  accIns.Id = acc;
                                  accIns.ntt_Land_Rover_Status__c = repeatCustomerStatus;
                                  accountUpdateMap.put(accIns.Id,accIns);
                              }
                          }
                      }
                      system.debug('--> '+accountUpdateMap);
                      if(accountUpdateMap != null 
                         && !accountUpdateMap.isEmpty()){
                             system.debug('accountUpdateMap --> '+json.serialize(accountUpdateMap));
                             update accountUpdateMap.values();
                         }
                  }
           }   
    }
    
    @future
    public static void handleJaguarAndLandRoverStatusAccount(String accJsonStr,String oldAccJsonStr){
        List<Account> accList= new List<Account>();
        map<Id,Account> oldAccMap = new map<Id,Account>();
        
        if(accJsonStr != null){
            accList= (List<Account>)json.deserialize(accJsonStr, List<Account>.class);
        }
        if(oldAccJsonStr != null){
            oldAccMap = (map<Id,Account>)json.deserialize(oldAccJsonStr, map<Id,Account>.class);
        }
        
        set<id> accIdsSet = new set<id>();
        set<id> lostOppIdsSet = new set<Id>();
        for(Account accIns : accList){
            accIdsSet.add(accIns.Id);
        }
        for(Opportunity oppIns : [select id,accountid,isclosed from Opportunity 
                                  where accountid in:accIdsSet]){ 
                                      if(oppIns.isclosed){
                                          lostOppIdsSet.add(oppIns.accountid);
                                      }else if(!oppIns.isclosed){
                                          lostOppIdsSet.remove(oppIns.accountid);
                                      }
                                  }
        map<Id,Account> accUpdateMap = new map<Id,Account>();
        for(Account accIns : accList){
            if(lostOppIdsSet.contains(accIns.Id)){
                if(accIns.Customer_Journey_Stage__c != null
                   && (accIns.recordtypeid == corpRecTypeId || accIns.recordtypeid == individualRecTypeId)
                   && custJouStatusset.contains(accIns.Customer_Journey_Stage__c)
                   && accIns.Customer_Journey_Stage__c != oldAccMap.get(accIns.Id).Customer_Journey_Stage__c){
                       Account accUpdateIns = new Account();
                       accUpdateIns.ID = accIns.Id;
                       accUpdateIns.ntt_Jaguar_Status__c = 'Lapsed Customer';
                       accUpdateIns.ntt_Land_Rover_Status__c = 'Lapsed Customer';
                       accUpdateMap.put(accUpdateIns.ID,accUpdateIns);
                   }
            }
        }
        if(accUpdateMap != null && !accUpdateMap.isEmpty()){
            update accUpdateMap.values();
        }
    }
    
    public class accountRolerWrapper{
        public String role;
        public String accountIns;
        public integer count;
    }
}