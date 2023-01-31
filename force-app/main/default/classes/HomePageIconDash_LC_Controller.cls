public with sharing class HomePageIconDash_LC_Controller {
    
    // public static User loggedinUser = [SELECT Id, Name, Market__c, Profile.Name, IsActive, (SELECT Id, Name, Profile.Name, IsActive FROM ManagedUsers WHERE IsActive = TRUE) FROM User WHERE Id = :userInfo.getUserId()];
    
    @AuraEnabled
    public static Map<String, Integer> getDashboardStats(String daysInPast) {
        Integer numdaysInPast = 365;
        if(daysInPast != null && daysInPast != '' ){
            numdaysInPast = Integer.valueOf(daysInPast);
        }
        Map<String, Integer> dashboardStats = new Map<String, Integer>();
        
        // Get list of target user Ids which is used to display detailed description of the count at home page
        Set < Id > targetIds = RetailerUsersSalesTargetBoardController.getTargetUserIds(UserInfo.getUserId());
        
        //total number of Tasks due today, not closed, assigned to current user
        List<Task> todaysTasks = new List<Task>();
        //total number of Tasks overdue, not closed, assigned to current user
        List<Task> overdueTasks = new List<Task>();
        
        for(Task t : [SELECT Id, ActivityDate FROM Task WHERE ActivityDate >= Last_N_Days:5 AND IsClosed = false AND OwnerId IN :targetIds]){
            if(t.ActivityDate < Date.today()){
                overdueTasks.add(t);
            }
            else if(t.ActivityDate == Date.today()){
                todaysTasks.add(t);
            }
        }
        
        //total number of Won Opportunities for New Vehicle assigned to current user (this month)
        List<Opportunity> newOpps = new List<Opportunity>();
        //total number of Won Opportunities for Used Vehicle assigned to current user (this month)
        List<Opportunity> myOpportunities= new  List<Opportunity>();
        
        for(Opportunity opp : [SELECT Id, Purchase_Type__c, LastModifiedById, StageName, OwnerId, Owner.Name, IsWon FROM Opportunity 
                               WHERE ((IsWon = true AND CloseDate = THIS_MONTH) OR StageName = 'Qualified') 
                               AND OwnerId IN :targetIds]) {
            if(opp.Purchase_Type__c == 'New Vehicle' && opp.IsWon) {
                newOpps.add(opp);
            }
            if(opp.OwnerId == UserInfo.getUserId() && opp.LastModifiedById != UserInfo.getUserId() && opp.StageName == 'Qualified'){
                myOpportunities.add(opp);
            }else{
                if(opp.Owner.Name != null && opp.Owner.Name.toUpperCase().indexOf('DEFAULT') > -1  ){
                    myOpportunities.add(opp);
                } 
            } 
        }  
        
        /* String currentUserId = UserInfo.getUserId();
        
        // Get Lead Count
        Integer leadCount = [SELECT count() FROM Lead 
                             WHERE OwnerId = :currentUserId 
                             AND LastModifiedById != :currentUserId 
                             AND Status = '1. Open' 
                             AND LastModifiedDate >= Last_N_Days:5]; */
        
        //CC
        List<Lead> leads = new  List<Lead>();
        for(Lead lead : [SELECT Id, DB_Created_Date_without_Time__c, CreatedDate, Name, Brand_Offline__c, Vehicle_Model_Offline__c, Type__c, LeadSource, OwnerId, Owner.Name, LastModifiedById                              
                         FROM Lead 
                         WHERE Status = '1. Open' 
                         AND LastModifiedDate >= Last_N_Days:5
                         AND OwnerId In :targetIds
                         ORDER BY LastModifiedDate DESC]){
                             if(lead.OwnerId == UserInfo.getUserId() && lead.LastModifiedById != lead.OwnerId) { 
                                 leads.add(lead);
                             }
                         }
        System.debug('### leads - ' + leads);
        
        
        List<ProcessInstance> approvalProcesses = new List<ProcessInstance>();
        for(ProcessInstance pi : [SELECT Id, TargetObjectId, (SELECT Id, StepStatus FROM Steps ORDER BY CreatedDate DESC LIMIT 1), (SELECT Id, ActorId FROM Workitems ORDER BY CreatedDate DESC LIMIT 1) FROM ProcessInstance WHERE Status = 'Pending']){
            if(pi.Workitems.size() > 0 && pi.Steps.size() > 0 && pi.Workitems[0].ActorId == UserInfo.getUserId() && pi.Steps[0].StepStatus == 'Started'){
                String thisObj = '' + pi.TargetObjectId;
                if(thisObj.startsWith('006')){
                    approvalProcesses.add(pi);
                }
            }
        }        
         
        Integer SalesTarget = 0;
        Integer testDriveTarget = 0;
        /* List<Id> targetPersonIdList = new List<Id>();
        if(loggedinUser.Profile.Name.contains('Sales Manager')) {
            targetPersonIdList.add(loggedinUser.Id);
            system.debug(loggedinUser.ManagedUsers);
            for(User userId :loggedinUser.ManagedUsers) {                
                targetPersonIdList.add(userId.Id);
            }
        } 
        else {
            system.debug(loggedinUser);
            targetPersonIdList.add(loggedinUser.Id);
        } */
        
        SchemaUtility.CurrentDateDetails financialDetails = new SchemaUtility.CurrentDateDetails(system.today().year(), system.today().month()); 
        String financialYear = String.valueOf(financialDetails.financailYear);
        List<Sales_Target__c> targetList = [SELECT Id, Current_Month_Target__c, RecordtypeId, RecordType.DeveloperName 
                                            FROM Sales_Target__c 
                                            // WHERE Salesperson__c IN :targetPersonIdList 
                                            WHERE Salesperson__c IN :targetIds 
                                            AND Target_Year__c = :financialYear];
        
        system.debug(targetList);
        for(Sales_Target__c target: targetList) {
            if(target.RecordtypeId != null && target.RecordType.DeveloperName != null ) {
                if(target.RecordType.DeveloperName == 'Opportunity_Sales_Target')  SalesTarget += Integer.valueof(target.Current_Month_Target__c);
                if(target.RecordType.DeveloperName == 'Test_Drive_Targets')  testDriveTarget += Integer.valueof(target.Current_Month_Target__c);
            }
            else {
                SalesTarget += Integer.valueof(target.Current_Month_Target__c);
            }
        }
        
        Id testDriveRecordtypeId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('Test_Drive').getRecordTypeId();
        List<Event> comletedTestDriveEvents = [SELECT Id FROM Event
                                               WHERE EndDateTime = THIS_MONTH 
                                               AND Test_Drive_Status__c ='Finished' 
                                               AND RecordtypeId=:testDriveRecordtypeId 
                                               AND OwnerId In :targetIds];
        
        dashboardStats.put('AssignedOpportunities', myOpportunities.size());
        dashboardStats.put('Leads', leads.size());
        dashboardStats.put('FollowUps', todaysTasks.size());
        dashboardStats.put('OverdueFollowUps', overdueTasks.size());
        dashboardStats.put('NewSales', newOpps.size());
        //dashboardStats.put('UsedSales', newOpps.size());
        dashboardStats.put('SalesTarget',SalesTarget);
        dashboardStats.put('TestDriveTarget',testDriveTarget);
        dashboardStats.put('totalTestDrives', comletedTestDriveEvents != null ? comletedTestDriveEvents.size() : 0);        
        dashboardStats.put('Approvals', approvalProcesses.size());
        System.debug('### ' + dashboardStats);
        return dashboardStats;
    }
    
    @AuraEnabled
    public static boolean getIsSalesManager() {
        Id profileId = UserInfo.getProfileId();
        List<Profile> salesmgr = [SELECT Name FROM Profile WHERE Id = :profileId AND (Name LIKE '%Sales Manager%' OR Name LIKE '%Dealer Principle%') ];
        return salesmgr.size() > 0;
    }
   
}