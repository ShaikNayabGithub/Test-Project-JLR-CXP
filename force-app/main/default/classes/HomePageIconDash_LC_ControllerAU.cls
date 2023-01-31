public without sharing class HomePageIconDash_LC_ControllerAU {
 public static User loggedinUser =[SELECT Id,Name, Market__c, Retailer_Name__c, Profile.Name, (SELECT Id,Name,Profile.Name FROM ManagedUsers) FROM User where id=:userinfo.getUserId()];
    
    @AuraEnabled
    public static Map<String, Integer> getDashboardStatsAU(string daysInPast) {
        Id testDriveRecordtypeId = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('Test_Drive').getRecordTypeId();
        integer numdaysInPast = 365;
        List<Id> AUManagersIdList = new List<Id>();
        List<Id> targetAUPersonIdList = new List<Id>();
        List<User_Role__c> usrs = [Select Id, Name, Viewing_User__c,Add_Subordinates__c, Viewing_User__r.Profile.Name FROM User_Role__c WHERE MasterUser__c =:loggedinUser.id ];
        if(daysInPast != null && daysInPast != '' ){
            numdaysInPast = integer.valueOf(daysInPast);
        }
        Map<String, Integer> dashboardStats = new Map<String, Integer>();
        //total number of Tasks due today, not closed, assigned to current user
        //total number of Tasks overdue, not closed, assigned to current user
        List<Task> todaysTasks = new List<Task>();
        List<Task> overdueTasks = new List<Task>();   
        //total number of Events due today, not closed, assigned to current user
        //total number of Events overdue, not closed, assigned to current user
        List<Event> todaysEvents = new List<Event>();
        List<Event> overdueEvents = new List<Event>();
        //total number of Won Opportunities for New Vehicle assigned to current user (this month)
        //total number of Won Opportunities for Used Vehicle assigned to current user (this month)
        List<Opportunity> newOpps = new List<Opportunity>();
        List<Opportunity> myOpportunities= new  List<Opportunity>();
        Boolean isManager = false;
        
        if(usrs !=  null && usrs.size() > 0){
            for(User_Role__c usr : usrs){
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
                  System.debug('AUManagersIdList'+AUManagersIdList);
          List<User> mangers =  [Select Name, Retailer_Name__c, Profile.Name, Market__c, (SELECT Id,Name,Profile.Name FROM ManagedUsers) from user where id IN :AUManagersIdList];
        //  List<User> mangers =  [Select Name,  Profile.Name, Market__c, (SELECT Id,Name,Profile.Name FROM ManagedUsers) from user where Partner_Manager__c IN :AUManagersIdList];
           System.debug('mangers'+mangers);
            for(User userM : mangers){
                
                for(User userId :userM.ManagedUsers){
                    targetAUPersonIdList.add(userId.Id);
                       System.debug('AUManagersIdList'+AUManagersIdList);
                }
            }
        }
        
        
        for(Task t : [SELECT Id, ActivityDate FROM Task WHERE ActivityDate <= TODAY AND IsClosed = false AND OwnerId IN :targetAUPersonIdList ]){
            if(t.ActivityDate < Date.today()){
                overdueTasks.add(t);
            }
            else{
                todaysTasks.add(t);
            }
        }
        
        for(Event evt : [SELECT Id, ActivityDate FROM Event WHERE ActivityDate <= TODAY AND event_completed__c = false AND OwnerId IN :targetAUPersonIdList ]){
            if(evt.ActivityDate < Date.today()){
                overdueEvents.add(evt);
                       System.debug('Overdue Events '+overdueEvents);
            }
            else{
                todaysEvents.add(evt);
                       System.debug('todays Events '+todaysEvents);
            }
        }
        System.debug('targetAUPersonIdList'+targetAUPersonIdList);
        
        
        
        
        for(Opportunity opp : [SELECT Id,Sale_Type__c, Purchase_Type__c,LastModifiedBy.Id,StageName, OwnerId, Owner.Name, IsWon , Enquiry_Type__c,DB_Created_Date_without_Time__c,CreatedDate, Name,  AccountId, Account.Name, Retailer_Name__c,  Opportunity_Age__c,Owner.Retailer_Name__c,
                               Primary_Model_Interest__c, Primary_Model_Interest__r.Name, LeadSource,
                               (SELECT Id,Subject,CreatedById FROM Events  ),
                               (SELECT Id,Subject, CreatedById FROM Tasks )
                               FROM Opportunity WHERE (IsWon = true AND CloseDate = THIS_MONTH AND OwnerId IN:targetAUPersonIdList ) OR (IsClosed = False AND IsWon = False AND CreatedDate >= :Date.today().addDays(-(numdaysInPast))  AND ( OwnerId IN:targetAUPersonIdList OR (Owner.Retailer_Name__c = :loggedinUser.Retailer_Name__c AND Owner.Name LIKE '%Default%' ) ) )]){
                                   if((opp.Purchase_Type__c == 'New Vehicle' || opp.Sale_Type__c == 'Demonstrator') && opp.IsWon){
                                       newOpps.add(opp);
                                   }
                                   if(addOppToList( opp, opp.Tasks, opp.Events, isManager)){  
                                       myOpportunities.add(opp);
                                   }
                               }  
        
        
        
        
        SchemaUtility.CurrentDateDetails financialDetails = new SchemaUtility.CurrentDateDetails(system.today().year(),system.today().month());  
        Integer SalesTarget =0;
        Integer testDriveTarget =0;     
        List<Sales_Target__c> targetList = [SELECT Id,Current_Month_Target__c,RecordtypeId, RecordType.DeveloperName FROM Sales_Target__c 
                                            WHERE Salesperson__c IN :targetAUPersonIdList AND Target_Year__c = :''+financialDetails.financailYear];
        
        
        for(Sales_Target__c target: targetList){
            if(target.RecordtypeId != null && target.RecordType.DeveloperName != null ){
                if(target.RecordType.DeveloperName == 'Opportunity_Sales_Target')  SalesTarget += Integer.valueof(target.Current_Month_Target__c);
                if(target.RecordType.DeveloperName == 'Test_Drive_Targets')  testDriveTarget += Integer.valueof(target.Current_Month_Target__c);
            }else{
                SalesTarget += Integer.valueof(target.Current_Month_Target__c);
            }
            
        }
        List<Event> comletedTestDriveEvents = [SELECT Id FROM Event WHERE EndDateTime = THIS_MONTH AND Test_Drive_Status__c ='Finished' AND RecordtypeId=:testDriveRecordtypeId AND OwnerId IN :targetAUPersonIdList];
        dashboardStats.put('AssignedOpportunities', myOpportunities.size());
        
        dashboardStats.put('FollowUps', todaysTasks.size() + todaysEvents.size());
        dashboardStats.put('OverdueFollowUps', overdueTasks.size() + overdueEvents.size());
        dashboardStats.put('NewSales', newOpps.size());
        //dashboardStats.put('UsedSales', newOpps.size());
        dashboardStats.put('SalesTarget',SalesTarget);
        dashboardStats.put('TestDriveTarget',testDriveTarget);
        dashboardStats.put('totalTestDrives', comletedTestDriveEvents != null ? comletedTestDriveEvents.size() : 0);        
        
        return dashboardStats;
    }
    
    
    
  
    
    @AuraEnabled
    public static boolean getIsSalesManager() {
        Id profileId = UserInfo.getProfileId();
        List<Profile> salesmgr = [SELECT Name FROM Profile WHERE Id = :profileId AND (Name LIKE '%Sales Manager%' OR Name LIKE '%Dealer Principle%') ];
        return salesmgr.size() > 0;
        /*Id profileId = UserInfo.getProfileId();
        List<Profile> salesmgr = [SELECT Name FROM Profile WHERE Id = :profileId AND Name LIKE '%Sales Manager%'];
        return salesmgr.size() > 0;*/
    }
    private static boolean addOppToList(Opportunity opp, List<Task> tsks, List<Event> evts, Boolean isManager){  
        Id meId = UserInfo.getUserId();
        boolean add = false;
        If(( opp.OwnerId == meId && opp.IsWon == FALSE )||(opp.Owner.Name != null && opp.Owner.Name.toUpperCase().indexOf('DEFAULT') > -1 && opp.IsWon == FALSE && isManager  ) ){
            add = true;
            if(tsks !=  null && tsks.size() > 0){
                for(Task tsk : tsks){
                    if(tsk.createdById == meId){
                        add = false;
                    }
                }
            }
            if(evts !=  null && evts.size() > 0){
                for(Event evt : evts){
                    if(evt.createdById == meId){
                        add = false;
                    }
                }
            }                
        }
        
        return add;
    }
    
}