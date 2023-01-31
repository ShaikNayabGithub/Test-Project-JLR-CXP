public with sharing class HomePageRecordListController {
    
    public static Id taskRecordtypeId =  Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Auto_Generated_Task').getRecordTypeId();
    public static Id taskMandatoryRecordtypeId =  Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Mandatory_AGT').getRecordTypeId();
    public static Id eventRecordtypeId =  Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('Auto_Generated_Event').getRecordTypeId();
    
    @AuraEnabled
    public static boolean getIsSalesManager() {
        Profile userProfile = [SELECT Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId()];
        return (userProfile != null && userProfile.Name.toUpperCase().indexOf('SALES MANAGER') > -1);
    }
    
    @AuraEnabled
    public static boolean getIsSalesExecutive() {
        Profile userProfile = [SELECT Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId()];
        return (userProfile != null && userProfile.Name.toUpperCase().indexOf('SALES EXECUTIVE') > -1);
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
        boolean isAustralian = false; 
        List<Id> recordtypeIdList = new List<Id>{taskRecordtypeId,taskMandatoryRecordtypeId,eventRecordtypeId};
            User me = [Select Market__c from user where id = :UserInfo.getUserId()];
        if(me.Market__c != null && me.Market__c == 'Australia'){
            isAustralian = true;
        } 
        
        for(Task t : [SELECT Id, ActivityDate,Subject,WhoId, Who.Name, WhatId,What.Name, Owner.Name FROM Task WHERE ActivityDate >= Last_N_Days:5 AND IsClosed = false]){
            if(t.ActivityDate < Date.today()){
                overdueTasks.add(t);
            }
            else if(t.ActivityDate == Date.today()){
                todaysTasks.add(t);
            }
        }   
        List<Opportunity> allQualifiedOpp = new  List<Opportunity>();
        
        if(!isAustralian){
            for(Opportunity opp : [SELECT Id, LastModifiedBy.Id,Enquiry_Type__c,DB_Created_Date_without_Time__c,CreatedDate, OwnerId, Owner.Name, Name, Purchase_Type__c, AccountId, Account.Name, Retailer_Name__c, StageName, Opportunity_Age__c,
                                   Primary_Model_Interest__c, Primary_Model_Interest__r.Name, LeadSource, (SELECT Id,Subject, CreatedById FROM Tasks WHERE RecordtypeId IN :recordtypeIdList LIMIT 1),
                                   (SELECT Id,Subject,CreatedById FROM Events WHERE RecordtypeId IN :recordtypeIdList LIMIT 1)
                                   FROM Opportunity WHERE StageName = 'Qualified' ORDER BY CreatedDate]){
                                       if(opp.OwnerId == UserInfo.getUserId() && opp.LastModifiedBy.Id != UserInfo.getUserId()){
                                           allQualifiedOpp.add(opp); 
                                       }else{
                                           if(opp.Owner.Name != null && opp.Owner.Name.toUpperCase().indexOf('DEFAULT') > -1  ){
                                               allQualifiedOpp.add(opp);
                                           } 
                                       }
                                   }
            
            //CC
            
            for(Lead lead : [SELECT Id, Status, DB_Created_Date_without_Time__c, CreatedDate, Name, Brand_Offline__c, Vehicle_Model_Offline__c, Primary_Model_Interest__r.Name, Type__c, LeadSource, OwnerId, Owner.Name, LastModifiedBy.Id,                              
                              (SELECT Id,Subject, CreatedById FROM Tasks LIMIT 1),
                                   (SELECT Id,Subject,CreatedById FROM Events LIMIT 1)
                             FROM Lead 
                             WHERE Status = '1. Open' AND LastModifiedDate  >=  Last_N_Days:5 
                             ORDER BY LastModifiedDate DESC]){
                                 if(lead.OwnerId == UserInfo.getUserId() && lead.LastModifiedBy.Id != UserInfo.getUserId()) {
                                     allLeads.add(lead);
                                     
                                 }
                             }
            
            
        }
        //
        
        //CC
        
        returnWrapper.resultIsAustralian = isAustralian;
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