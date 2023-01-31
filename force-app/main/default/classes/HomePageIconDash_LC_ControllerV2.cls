public without sharing class HomePageIconDash_LC_ControllerV2 {
    
    public static User loggedinUser = [SELECT Id, Name, Market__c, Profile.Name, IsActive, (SELECT Id, Name, Profile.Name, IsActive FROM ManagedUsers WHERE IsActive = TRUE) FROM User WHERE Id = :userInfo.getUserId()];
    
    @AuraEnabled
    public static Map<String, Integer> getDashboardStats(string daysInPast) {
        Integer numdaysInPast = 365;
        if(daysInPast != null && daysInPast != '' ){
            numdaysInPast = Integer.valueOf(daysInPast);
        }
        
        List<Id> AUManagersIdList = new List<Id>();
        List<Id> targetAUPersonIdList = new List<Id>();
        List<User_Role__c> usrs = [Select Id, Name,Viewing_User__r.name, Viewing_User__c,Add_Subordinates__c, Viewing_User__r.Profile.Name FROM User_Role__c WHERE MasterUser__c =:loggedinUser.id ];
    
        Boolean isManager = false;
        
        if(usrs !=  null && usrs.size() > 0){
            for(User_Role__c usr : usrs){
                system.debug('usr '+usr.Viewing_User__r.name);
                targetAUPersonIdList.add(usr.Viewing_User__c);
                if(usr.Add_Subordinates__c == true ){
                    System.debug('usr.Add_Subordinates__c'+usr.Add_Subordinates__c);
                    AUManagersIdList.add(usr.Viewing_User__c);
                }
            }           
            
        }
        
        targetAUPersonIdList.add(loggedinUser.Id);
        if(loggedinUser.Profile.Name.contains('Sales Manager')){ 
            isManager = true;
            if(loggedinUser.ManagedUsers != null){            
                for(User userId :loggedinUser.ManagedUsers){
                    targetAUPersonIdList.add(userId.Id);
                }
            }
        }
        if(loggedinUser.Profile.Name.contains('Dealer Principle')){
            isManager = true;
            for(User userId :loggedinUser.ManagedUsers){
                targetAUPersonIdList.add(userId.Id);
                if(userId.Profile.Name.contains('Sales Manager')){
                    AUManagersIdList.add(userId.Id);
                }   
            }
            
        }
        if(  AUManagersIdList != null && AUManagersIdList.size() > 0 ){
            List<User> mangers =  [Select Name, Retailer_Name__c, Profile.Name, Market__c, (SELECT Id,Name,Profile.Name FROM ManagedUsers) from user where id IN :AUManagersIdList];        
            System.debug('mangers'+mangers);
            for(User userM : mangers){
                
                for(User userId :userM.ManagedUsers){
                    targetAUPersonIdList.add(userId.Id);
                    
                }
            }
        }
        
        System.debug('targetAUPersonIdList'+targetAUPersonIdList);
        
        //////////////
        Map<String, Integer> dashboardStats = new Map<String, Integer>();
        //total number of Tasks due today, not closed, assigned to current user
        //total number of Tasks overdue, not closed, assigned to current user
        List<Task> todaysTasks = new List<Task>();
        List<Task> overdueTasks = new List<Task>();
        
        //total number of Won Opportunities for New Vehicle assigned to current user (this month)
        //total number of Won Opportunities for Used Vehicle assigned to current user (this month)
        List<Opportunity> newOpps = new List<Opportunity>();
        List<Opportunity> myOpportunities= new  List<Opportunity>();
        
        
        for(Task t : [SELECT Id, ActivityDate FROM Task WHERE ActivityDate >= Last_N_Days:5 AND IsClosed = false AND OwnerId In :targetAUPersonIdList]){
            if(t.ActivityDate < Date.today()){
                overdueTasks.add(t);
            }
            else if(t.ActivityDate == Date.today()){
                todaysTasks.add(t);
            }
        }
        
        for(Opportunity opp : [SELECT Id, Purchase_Type__c,LastModifiedById,StageName, OwnerId, Owner.Name, IsWon FROM Opportunity WHERE ((IsWon = true AND CloseDate = THIS_MONTH) OR StageName = 'Qualified') AND OwnerId In :targetAUPersonIdList]){
            if(opp.Purchase_Type__c == 'New Vehicle' && opp.IsWon && targetAUPersonIdList.Contains(opp.OwnerId) ){
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
        
        //CC
        List<Lead> leads = new  List<Lead>();
        for(Lead lead : [SELECT Id, DB_Created_Date_without_Time__c, CreatedDate, Name, Brand_Offline__c, Vehicle_Model_Offline__c, Type__c, LeadSource, OwnerId, Owner.Name, LastModifiedById                              
                         FROM Lead 
                         WHERE Status = '1. Open' AND LastModifiedDate >= Last_N_Days:5 AND OwnerId In :targetAUPersonIdList
                         ORDER BY LastModifiedDate DESC]){
                             system.debug((lead.OwnerId == UserInfo.getUserId() && lead.LastModifiedById != UserInfo.getUserId()));
                             if(targetAUPersonIdList.contains(lead.OwnerId)  && lead.LastModifiedById != lead.OwnerId) { 
                                 leads.add(lead);
                                 
                             }
                         }
        
        
        List<ProcessInstance> approvalProcesses = new List<ProcessInstance>();
        //possibly massive query check in preprod
        for(ProcessInstance pi : [SELECT Id, TargetObjectId, (SELECT Id, StepStatus FROM Steps ORDER BY CreatedDate DESC LIMIT 1), (SELECT Id, ActorId FROM Workitems ORDER BY CreatedDate DESC LIMIT 1) FROM ProcessInstance WHERE Status = 'Pending']){
            if(pi.Workitems.size() > 0 && pi.Steps.size() > 0 && pi.Workitems[0].ActorId == UserInfo.getUserId() && pi.Steps[0].StepStatus == 'Started'){
                String thisObj = '' + pi.TargetObjectId;
                if(thisObj.startsWith('006')){
                    approvalProcesses.add(pi);
                }
            }
        }        
        SchemaUtility.CurrentDateDetails financialDetails = new SchemaUtility.CurrentDateDetails(system.today().year(),system.today().month());  
        Integer SalesTarget =0;
        Integer testDriveTarget =0;
        /*List<Id> targetPersonIdList = new List<Id>();
if(loggedinUser.Profile.Name.contains('Sales Manager')){
system.debug(loggedinUser.ManagedUsers);
for(User userId :loggedinUser.ManagedUsers){
targetPersonIdList.add(userId.Id);
}
}else{

system.debug(loggedinUser);
targetPersonIdList.add(loggedinUser.Id);
}*/
        system.Debug('targetPersonIdList'+targetAUPersonIdList);
        system.Debug('financialDetails.financailYear'+financialDetails.financailYear);
        List<Sales_Target__c> targetList = [SELECT Id,Current_Month_Target__c,RecordtypeId,Salesperson__c, Salesperson__r.name, RecordType.DeveloperName FROM Sales_Target__c 
                                            WHERE Salesperson__c IN :targetAUPersonIdList AND Target_Year__c = :''+financialDetails.financailYear];
        
        system.debug(targetList);
        for(Sales_Target__c target: targetList){
            if(target.RecordtypeId != null && target.RecordType.DeveloperName != null ){
                if(target.RecordType.DeveloperName == 'Opportunity_Sales_Target')  SalesTarget += Integer.valueof(target.Current_Month_Target__c);
                if(target.RecordType.DeveloperName == 'Test_Drive_Targets')  testDriveTarget += Integer.valueof(target.Current_Month_Target__c);
            }else{
                SalesTarget += Integer.valueof(target.Current_Month_Target__c);
            }
            
        }
        
        Id testDriveRecordtypeId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('Test_Drive').getRecordTypeId();
        List<Event> comletedTestDriveEvents = [SELECT Id FROM Event WHERE EndDateTime = THIS_MONTH AND Test_Drive_Status__c ='Finished' AND RecordtypeId=:testDriveRecordtypeId AND OwnerId In :targetAUPersonIdList];
        system.debug('comletedTestDriveEvents'+comletedTestDriveEvents);
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
        return dashboardStats;
    }
    
    @AuraEnabled
    public static boolean getIsSalesManager() {
        Id profileId = UserInfo.getProfileId();
        List<Profile> salesmgr = [SELECT Name FROM Profile WHERE Id = :profileId AND Name LIKE '%Sales Manager%'];
        return salesmgr.size() > 0;
    }
    
}