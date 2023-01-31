public class AccountJaguarLRStatusUpadateProcessor {
    
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
            
            public static void updateLRAndJaguarStatus(Account accData) {
                set<id> oppIdsSet = new set<id>();
                set<String> brandSet = new set<String>();
                map<String,List<Role__c>> accountRoleMap = new map<String,List<Role__c>>();
                for(Opportunity opp : [select id,accountid,Brand__c,stageName from Opportunity 
                                       where accountid =: accData.Id]){
                                           if(opp.stageName != null
                                              && opp.accountid != null
                                              && opp.Brand__c != null){
                                                  oppIdsSet.add(opp.Id);
                                              }
                                       }
                
                for(Opportunity opp : [select id,brand__r.name from opportunity where brand__c != null AND brand__r.name != null AND accountid =: accData.Id]){
                    brandSet.add(opp.brand__r.name);
                }
                
                
                system.debug('brandSet--> '+brandSet);   
                if(brandSet != null && !brandSet.isEmpty()){
                    for(Role__c rlIns : [select id,Role__c,Account__c,Vehicle__r.brand__r.name
                                         from Role__c 
                                         where 
                                         Account__c =: accData.Id 
                                         AND Account__c != null
                                         AND Vehicle__c != null
                                         AND Role__c != 'Previous Owner']){
                                             if(rlIns.Vehicle__c != null
                                                &&  rlIns.Vehicle__r.brand__c != null
                                                &&  rlIns.Vehicle__r.brand__r.name != null
                                                && brandSet.contains(rlIns.Vehicle__r.brand__r.name)){
                                                    if(!accountRoleMap.containskey(rlIns.Account__c+'-'+rlIns.vehicle__r.brand__r.name)){
                                                        accountRoleMap.put(rlIns.Account__c+'-'+rlIns.vehicle__r.brand__r.name,new List<Role__c>{rlIns});
                                                    }else{
                                                        accountRoleMap.get(rlIns.Account__c+'-'+rlIns.vehicle__r.brand__r.name).add(rlIns);
                                                    }
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
                                              accountid =:accData.Id and accountid != null AND Brand__c != null]){
                                                  if(!accountRoleMap.containskey(opp.AccountId+'-'+opp.Brand__r.Name)){
                                                      system.debug('won --> '+opp.iswon);
                                                      system.debug('Brand --> '+opp.Brand__r.Name);
                                                      system.debug('Jaguar_Status --> '+opp.account.ntt_Jaguar_Status__c);
                                                      if(opp.Brand__r.Name == jaguarBrand){
                                                          accData.Id = opp.AccountId;
                                                          if(opp.IsWon){
                                                              accData.ntt_Jaguar_Status__c = 'Customer';
                                                          }else if(!opp.IsWon && opp.IsClosed){
                                                              accData.ntt_Jaguar_Status__c = 'Suspect';
                                                          }else if(!opp.IsWon && !opp.IsClosed){
                                                              accData.ntt_Jaguar_Status__c = 'Prospect';
                                                          }
                                                      }else if(opp.Brand__r.Name == landRoverBrand){
                                                          accData.Id = opp.AccountId;
                                                          if(opp.IsWon){
                                                              accData.ntt_Land_Rover_Status__c = 'Customer';
                                                          }else if(!opp.IsWon && opp.IsClosed){
                                                              accData.ntt_Land_Rover_Status__c = 'Suspect';
                                                          }else if(!opp.IsWon && !opp.IsClosed){
                                                              accData.ntt_Land_Rover_Status__c = 'Prospect';
                                                          }
                                                      }
                                                  }
                                              }
                   }
            }
    
    
    
    public static void handleJaguarAndLandRoverStatus(Account accData){
        map<Id,Role__c> roleMap = new map<Id,Role__c>();
        Id accRecTypeId = Schema.SObjectType.Role__c.getRecordTypeInfosByDeveloperName().get('Account').getRecordTypeId();
        for(Role__c rl: [select id,Account__c,Vehicle__c,Role__c from Role__c 
                         where Account__c =:accData.Id
                         AND Vehicle__c != null
                         AND Role__c != null
                         AND recordTypeId =: accRecTypeId 
                        ]){
                            roleMap.put(rl.Account__c,rl);
                        }
        
        system.debug('roleMap --> '+roleMap);        
        if(roleMap != null 
           && !roleMap.isEmpty()){
               map<Id,List<accountRolerWrapper>> jaguarRoleWrapperMap = new map<Id,List<accountRolerWrapper>>();
               map<Id,List<accountRolerWrapper>> landRoverRoleWrapperMap = new map<Id,List<accountRolerWrapper>>();
               for(Role__c  role : [select Account__c,Role__c,Vehicle__r.Brand__r.Name
                                    from Role__c 
                                    where 
                                    Account__c =: accData.Id 
                                    AND Role__c IN: roleList
                                    AND Vehicle__c != null
                                    AND Account__c != null
                                    AND (Account__r.recordtypeid =:corpRecTypeId OR Account__r.recordtypeid =:individualRecTypeId)
                                   ]){
                                       if(role.Vehicle__r.Brand__c != null
                                          &&  role.Vehicle__r.Brand__r.Name != null
                                          && role.Vehicle__r.Brand__r.Name == jaguarBrand){
                                              accountRolerWrapper roleIns = new accountRolerWrapper();
                                              roleIns.role = role.Role__c;
                                              roleIns.accountIns = role.Account__c;
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
                                   Account__c =: accData.Id 
                                   AND Role__c IN: roleList
                                   AND Vehicle__c != null
                                   AND Account__c != null
                                   AND (Account__r.recordtypeid =:corpRecTypeId OR Account__r.recordtypeid =:individualRecTypeId)
                                  ]){
                                      if(role.Vehicle__r.Brand__c != null
                                         &&  role.Vehicle__r.Brand__r.Name != null
                                         && role.Vehicle__r.Brand__r.Name == landRoverBrand){
                                             accountRolerWrapper roleIns = new accountRolerWrapper();
                                             roleIns.role = role.Role__c;
                                             roleIns.accountIns = role.Account__c;
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
                      for(id acc : jaguarRoleWrapperMap.keyset()){
                          List<accountRolerWrapper> accWrapList = jaguarRoleWrapperMap.get(acc);
                          if(accWrapList.size() == 1 && accWrapList.get(0).role == currentOwner){
                              accData.ntt_Jaguar_Status__c = customerStatus;
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
                                  accData.ntt_Jaguar_Status__c = lapsedCustomerStatus;
                              }else if(iscurrent){
                                  accData.ntt_Jaguar_Status__c = repeatCustomerStatus;
                              }
                          }
                      }
                  }
               
               if(landRoverRoleWrapperMap != null 
                  && !landRoverRoleWrapperMap.isEmpty()){
                      for(id acc : landRoverRoleWrapperMap.keyset()){
                          List<accountRolerWrapper> accWrapList = landRoverRoleWrapperMap.get(acc);
                          if(accWrapList.size() == 1 && accWrapList.get(0).role == currentOwner){
                              accData.ntt_Land_Rover_Status__c = customerStatus;
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
                                  accData.ntt_Land_Rover_Status__c = lapsedCustomerStatus;
                              }else if(iscurrent){
                                  accData.ntt_Land_Rover_Status__c = repeatCustomerStatus;
                              }
                          }
                      }
                  }
           }   
    }
    
    public static void handleLapsedStatus(Account accIns){
        set<id> lostOppIdsSet = new set<Id>();
        for(Opportunity oppIns : [select id,accountid,isclosed from Opportunity 
                                  where accountid =: accIns.Id]){
                                      if(oppIns.isclosed){
                                          lostOppIdsSet.add(oppIns.accountid);
                                      }else if(!oppIns.isclosed){
                                          lostOppIdsSet.remove(oppIns.accountid);
                                      }
                                  }
        if(lostOppIdsSet.contains(accIns.Id)){
            if(accIns.Customer_Journey_Stage__c != null
               && custJouStatusset.contains(accIns.Customer_Journey_Stage__c)){
                   accIns.ntt_Jaguar_Status__c = 'Lapsed Customer';
                   accIns.ntt_Land_Rover_Status__c = 'Lapsed Customer';
               }
        }
    }
    
    public class accountRolerWrapper{
        public String role;
        public String accountIns;
        public integer count;
    }
}