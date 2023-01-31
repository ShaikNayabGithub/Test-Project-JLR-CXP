public without sharing class JLREventOnAccountController {

    @AuraEnabled
    public static ActivityWrapper getActivityList(String accountId) {
        Set<Id> idsToSearch = new Set<Id>();
        Id primaryAccountId;
        Account thisAccount = [SELECT Id, Is_Primary__c, Primary_Account__c, RecordType.DeveloperName FROM Account WHERE Id = :accountId];
        if(thisAccount.Is_Primary__c){
            primaryAccountId = thisAccount.Id;
        }
        else{
            primaryAccountId = thisAccount.Primary_Account__c;
        }
        idsToSearch.add(accountId);
        idsToSearch.add(primaryAccountId);
        ActivityWrapper allActivities = new ActivityWrapper();
        if(thisAccount.RecordType.DeveloperName != 'Retailer'){
            //for(Account acc : [SELECT Id, (SELECT Id FROM OpenActivities WHERE RecordType.DeveloperName = 'JLR_Event') FROM Account WHERE Id = :primaryAccountId]){
            //    allActivities.add(acc.OpenActivities);
            //}
            System.debug('Getting Events');
            for(Event ev : [SELECT Id, Subject, WhoId, Who.Name, WhatId, What.Name, StartDateTime, EndDateTime, Type, Location, Description, OwnerId, Owner.Name, RecordType.Name FROM Event WHERE Visible_to_Retailer__c = true AND (WhatId IN :idsToSearch OR WhoId IN :idsToSearch)]){
                allActivities.myEvents.add(ev);
            }
            for(Task tk : [SELECT Id, Subject, WhoId, Who.Name, WhatId, What.Name, ActivityDate, Type, Status, Priority, Description, OwnerId, Owner.Name, RecordType.Name FROM Task WHERE Visible_to_Retailer__c = true AND (WhatId IN :idsToSearch OR WhoId IN :idsToSearch)]){
                allActivities.myTasks.add(tk);
            }
        }
        return allActivities;
    }
    
    public class ActivityWrapper {
        @AuraEnabled public List<Event> myEvents {get; set;}
        @AuraEnabled public List<Task> myTasks {get; set;}
        
        public ActivityWrapper() {
        	this.myEvents = new List<Event>();
        	this.myTasks = new List<Task>();
        }
    }
    
}