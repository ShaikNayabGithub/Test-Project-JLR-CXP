/*
 * CXPD721
 * JPatman
 * 12/07/20



*/

public without sharing class HomePageRecordListControllerV2 {
    
    public static Id taskRecordtypeId =  Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Auto_Generated_Task').getRecordTypeId();
    public static Id taskMandatoryRecordtypeId =  Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Mandatory_AGT').getRecordTypeId();
    public static Id eventRecordtypeId =  Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('Auto_Generated_Event').getRecordTypeId();
    
    @AuraEnabled
    public static boolean getIsSalesManager() {
        Profile userProfile = [SELECT Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId()];
        return (userProfile != null && userProfile.Name.toUpperCase().indexOf('SALES MANAGER') > -1);
    }
    
    @AuraEnabled
    public static SearchResultWrapper getNewPageRecordList(string daysInPast) {
        integer numdaysInPast = 365;
        if(daysInPast != null && daysInPast != '' ){
            numdaysInPast = integer.valueOf(daysInPast);
        }
        System.debug('CALLLED getNewPageRecordList');
        SearchResultWrapper returnWrapper = new SearchResultWrapper();
        List<Task> todaysTasks = new List<Task>();
        List<Task> overdueTasks = new List<Task>();
        List<Lead> allLeads = new  List<Lead>();
       Boolean isManager = false;
     
        List<Id> recordtypeIdList = new List<Id>{taskRecordtypeId,taskMandatoryRecordtypeId,eventRecordtypeId};
            User me = [Select Name, Retailer_Name__c, Profile.Name, Market__c, (SELECT Id,Name,Profile.Name FROM ManagedUsers) from user where id = :UserInfo.getUserId()];
      
        //JP
        
           
        List<User_Role__c> usrs = [Select Id, Name, Viewing_User__c,Add_Subordinates__c, Viewing_User__r.Profile.Name FROM User_Role__c WHERE MasterUser__c =:me.id ];
        List<Id> targetPersonIdList = new List<Id>();
        List<Id> managersIdList = new List<Id>();
        if(usrs !=  null && usrs.size() > 0){
            for(User_Role__c usr : usrs){
                targetPersonIdList.add(usr.Viewing_User__c);
                if(usr.Add_Subordinates__c == true ){
                    managersIdList.add(usr.Viewing_User__c);
                }
            }
            
            
        }
        
        
        targetPersonIdList.add(me.Id);
        if(me.Profile.Name.contains('Sales Manager')){
            isManager = true;
            for(User userId :me.ManagedUsers){
                targetPersonIdList.add(userId.Id);
            }
        }
        if(me.Profile.Name.contains('Dealer Principle')){
            isManager = true;
            for(User userId :me.ManagedUsers){
                targetPersonIdList.add(userId.Id);
                if(userId.Profile.Name.contains('Sales Manager')){
                    targetPersonIdList.add(userId.Id);
                }   
            }
            
        }
        if(  managersIdList != null && managersIdList.size() > 0 ){
            List<User> mangers =  [Select Name,  Profile.Name, Market__c, (SELECT Id,Name,Profile.Name FROM ManagedUsers) from user where id IN :managersIdList];
            for(User userM : mangers){
                for(User userId :userM.ManagedUsers){
                    targetPersonIdList.add(userId.Id);
                    
                }
            }
        }
        ///JP
        
        
        
        for(Task t : [SELECT Id, ActivityDate,Subject,WhoId, Who.Name, WhatId,What.Name, Owner.Name FROM Task WHERE ActivityDate >= Last_N_Days:5 AND IsClosed = false AND OwnerId IN :targetPersonIdList]){
            if(t.ActivityDate < Date.today()){
                overdueTasks.add(t);
            }
            else if(t.ActivityDate == Date.today()){
                todaysTasks.add(t);
            }
        }   
        List<Opportunity> allQualifiedOpp = new  List<Opportunity>();
        
      
            for(Opportunity opp : [SELECT Id, LastModifiedBy.Id,Enquiry_Type__c,DB_Created_Date_without_Time__c,CreatedDate, OwnerId, Owner.Name, Name, Purchase_Type__c, AccountId, Account.Name, Retailer_Name__c, StageName, Opportunity_Age__c,
                                   Primary_Model_Interest__c, Primary_Model_Interest__r.Name, LeadSource, (SELECT Id,Subject, CreatedById FROM Tasks WHERE RecordtypeId IN :recordtypeIdList LIMIT 1),
                                   (SELECT Id,Subject,CreatedById FROM Events WHERE RecordtypeId IN :recordtypeIdList LIMIT 1)
                                   FROM Opportunity WHERE StageName = 'Qualified' AND OwnerId IN :targetPersonIdList ORDER BY CreatedDate]){
                                       if(opp.OwnerId == UserInfo.getUserId() && opp.LastModifiedBy.Id != UserInfo.getUserId()){
                                           allQualifiedOpp.add(opp); 
                                       }else{
                                           if(opp.Owner.Name != null && opp.Owner.Name.toUpperCase().indexOf('DEFAULT') > -1  ){
                                               allQualifiedOpp.add(opp);
                                           } 
                                       }
                                   }
            
            //CC
            system.debug('targetPersonIdList'+json.serializePretty(targetPersonIdList));
            for(Lead lead : [SELECT Id, Status, DB_Created_Date_without_Time__c, CreatedDate, Name, Brand_Offline__c, Vehicle_Model_Offline__c, Primary_Model_Interest__r.Name, Type__c, LeadSource, OwnerId, Owner.Name, LastModifiedBy.Id,                              
                              (SELECT Id,Subject, CreatedById FROM Tasks LIMIT 1),
                                   (SELECT Id,Subject,CreatedById FROM Events LIMIT 1)
                             FROM Lead 
                             WHERE Status = '1. Open' AND LastModifiedDate  >=  Last_N_Days:5 AND OwnerId IN :targetPersonIdList
                             ORDER BY LastModifiedDate DESC]){
                                            system.debug('Lead '+lead);
                                 if(targetPersonIdList.contains(lead.OwnerId) && lead.LastModifiedBy.Id != lead.OwnerId) {
                                     allLeads.add(lead);
                                     
                                 }
                             }
            
            system.debug('allLeads'+allLeads);
        
        //
        
        //CC
        
        returnWrapper.resultIsAustralian = false;
        returnWrapper.resultFollowUpTaskList.addAll(todaysTasks);
        returnWrapper.resultOverdueTaskList.addAll(overdueTasks);
        returnWrapper.resultOpportunityList.addAll(allQualifiedOpp);
        returnWrapper.resultLeadList.addAll(allLeads);
        
        return returnWrapper;
    }
    
  
    public class SearchResultWrapper {
        @AuraEnabled
        public List<Task> resultFollowUpTaskList = new List<Task>();
        @AuraEnabled
        public List<Task> resultOverdueTaskList = new List<Task>();
        @AuraEnabled
        public List<Opportunity> resultOpportunityList = new List<Opportunity>();
        @AuraEnabled
        public List<Lead> resultLeadList = new List<Lead>();   
        @AuraEnabled
        public List<Asset> resultAssetList =new List<Asset>();
        @AuraEnabled
        public boolean resultIsAustralian = false;  
    }
    
   
    
}