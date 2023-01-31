public without sharing class ListViewTaskController {
    @AuraEnabled
    public static List<Task> getTasks(string whereQuery, string limitNum, boolean justMine) {
          Set<Id> targetAUPersonIdList = new Set<Id>();
        List<Id> AUManagersIdList = new List<Id>();        
        User me = [Select Name,  Profile.Name, Market__c, (SELECT Id,Name,Profile.Name FROM ManagedUsers) from user where id = :UserInfo.getUserId()];        
        List<User_Role__c> usrs = [Select Id, Name, Viewing_User__c,Add_Subordinates__c, Viewing_User__r.Profile.Name FROM User_Role__c WHERE MasterUser__c =:me.id ];
        if(usrs !=  null && usrs.size() > 0){
            for(User_Role__c usr : usrs){
                targetAUPersonIdList.add(usr.Viewing_User__c);
                if(usr.Add_Subordinates__c == true ){
                    AUManagersIdList.add(usr.Viewing_User__c);
                }
            }
            
            
        }

        targetAUPersonIdList.add(me.Id);
        if(me.Profile.Name.contains('Sales Manager')){ 
            
            if(me.ManagedUsers != null){            
                for(User userId :me.ManagedUsers){
                    targetAUPersonIdList.add(userId.Id);
                }
            }
        }
        if(me.Profile.Name.contains('Dealer Principle')){
       
            for(User userId :me.ManagedUsers){
                targetAUPersonIdList.add(userId.Id);
                if(userId.Profile.Name.contains('Sales Manager')){
                    AUManagersIdList.add(userId.Id);
                }   
            }
            
        }
        if(  AUManagersIdList != null && AUManagersIdList.size() > 0 ){
            List<User> mangers =  [Select Name,  Profile.Name, Market__c, (SELECT Id,Name,Profile.Name FROM ManagedUsers) from user where id IN :AUManagersIdList];
            for(User userM : mangers){
                for(User userId :userM.ManagedUsers){
                    targetAUPersonIdList.add(userId.Id);
                    
                }
            }
        }
        
        string userId = UserInfo.getUserId(); 
        if(whereQuery == null ){
            whereQuery = '';        
        }
        if(justMine){
            whereQuery = 'WHERE OwnerId = \''+String.escapeSingleQuotes(userId) +'\'  '+whereQuery; 
        }else{
            if(whereQuery != ''){
                whereQuery = ' WHERE  OwnerId IN  :targetAUPersonIdList '+'   '+whereQuery; 
            }            
        }
        
        List<Task> TaskList = new List<Task>();
        
        
        if(limitNum == null){
            limitNum = ' LIMIT 10'; 
        }
        string fullQuery = 'SELECT CreatedDate,Subject,type,RecordType.Name,WhatId,Description, What.Name, What.Type,ActivityDate,Owner.Name,  whoid, who.name FROM Task  '+whereQuery+' ORDER BY  ActivityDate DESC nulls last '+limitNum;
        //return [SELECT CreatedDate,Subject,type,RecordType.Name,WhatId,Description, What.Name, What.Type,ActivityDate,  whoid, who.name FROM Task WHERE :query  ORDER BY  CreatedDate DESC nulls last LIMIT 5];
        System.debug(fullQuery);
        return Database.query(fullQuery);
    }
}