public without sharing class ListViewEventController {
    @AuraEnabled
    public static List<Event> getEvents(string whereQuery, string limitNum, boolean justMine) {
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
        
        
        if(limitNum == null){
            limitNum = ' LIMIT 10'; 
        }
        
        string fullQuery = 'SELECT CreatedDate,Subject,type,RecordType.Name,Owner.Name,WhatId,Description, What.Name, What.Type,ActivityDate, StartDateTime,EndDateTime, whoid, who.name FROM Event  '+whereQuery+' ORDER BY  StartDateTime DESC nulls last '+limitNum;
        
        return Database.query(fullQuery);
        
    }
    
    /*
* 
*  List<EventPlus> EventPlusList = new List<EventPlus>();
*      for(Event ev : EventList ){
EventPlus ep = new EventPlus();
ep.Subject = ev.Subject;
ep.CreatedDate = ev.CreatedDate;
ep.RecordTypeName = ev.RecordType.Name;
ep.WhatId = ev.WhatId;
ep.WhatName = ev.What.Name; 
ep.Description = ev.Description;
ep.WhatTypeID = ev.What.Type+'/'+ev.WhatId;
ep.ActivityDate = ev.ActivityDate ;
ep.StartDatetime = ev.StartDatetime ;
ep.WhoId = ev.WhoId ;
ep.Whoname = ev.Who.Name ;
ep.EndDate = ev.EndDate ;
ep.eyedee = ev.Id;
EventPlusList.add(ep);
}
return EventPlusList;
public class EventPlus {
Public id EyeDee;
public String Subject;
public DateTime CreatedDate;
public String RecordTypeName;
public ID WhatId;
public String WhatName;
public String Description;
public String WhatTypeID;

public Date ActivityDate;
public DateTime StartDatetime;

public Id WhoId;
public String Whoname;
public Date EndDate;


}
*/
    
}