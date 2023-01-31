public without sharing class HomePageRecordListControllerAU {

public static Id taskRecordtypeId =  Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Auto_Generated_Task').getRecordTypeId();
    public static Id taskMandatoryRecordtypeId =  Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Mandatory_AGT').getRecordTypeId();
    public static Id eventRecordtypeId =  Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('Auto_Generated_Event').getRecordTypeId();
    
    @AuraEnabled
    public static boolean getIsSalesManager() {
        Profile userProfile = [SELECT Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId()];
        return (userProfile != null && userProfile.Name.toUpperCase().indexOf('SALES MANAGER') > -1);
    }
    

    
    @AuraEnabled
    public static SearchResultWrapper getNewPageAUSRecordList(string daysInPast) {
        integer numdaysInPast = 365;
        if(daysInPast != null && daysInPast != '' ){
            numdaysInPast = integer.valueOf(daysInPast);
        }
        System.debug('CALLLED getNewPageRecordList');
        SearchResultWrapper returnWrapper = new SearchResultWrapper();
        List<TaskInfoListWrapper> todaysTasks = new List<TaskInfoListWrapper>();
        List<TaskInfoListWrapper> overdueTasks = new List<TaskInfoListWrapper>();
        
        boolean isAustralian = true; 
        boolean isManager = false; 
        List<Id> recordtypeIdList = new List<Id>{taskRecordtypeId,taskMandatoryRecordtypeId,eventRecordtypeId};
            
            User me = [Select Name, Retailer_Name__c, Profile.Name, Market__c, (SELECT Id,Name,Profile.Name FROM ManagedUsers) from user where id = :UserInfo.getUserId()];
        List<User_Role__c> usrs = [Select Id, Name, Viewing_User__c,Add_Subordinates__c, Viewing_User__r.Profile.Name FROM User_Role__c WHERE MasterUser__c =:me.id ];
        List<Id> targetAUPersonIdList = new List<Id>();
        List<Id> AUManagersIdList = new List<Id>();
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
            isManager = true;
            for(User userId :me.ManagedUsers){
                targetAUPersonIdList.add(userId.Id);
            }
        }
        if(me.Profile.Name.contains('Dealer Principle')){
            isManager = true;
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
        
        
        Map<Id,Id> taskWhatIdMap = New Map<Id,Id>();
        List<Task> taskList=[SELECT Id, ActivityDate,Subject,WhatId,What.Name, Owner.Name FROM Task WHERE ActivityDate <= TODAY AND IsClosed = false AND OwnerId IN : targetAUPersonIdList];
        for(Task t : taskList){
            if(t.WhatId !=null)
				taskWhatIdMap.put(t.id, t.WhatId);           
        }   
        System.debug(taskList);
        
        Map<Id,Opportunity> taskOpportunityMap= New Map<id,Opportunity>([select id,Primary_Contact__r.MobilePhone, Primary_Contact__r.Email from Opportunity where Id In:taskWhatIdMap.values() ]);
        Map<Id,Account> taskAccountMap= New Map<id,Account>([select id, PersonMobilePhone, PersonEmail, retailer_email__c,recordtype.Name from Account where Id In:taskWhatIdMap.values() ]);
        
        for(Task t :taskList){
            TaskInfoListWrapper taskInfo =new TaskInfoListWrapper();
           ActivityWrapper ot = new ActivityWrapper();
            
            ot.Id = t.id;
            ot.ActivityDate = t.ActivityDate;
            ot.Subject = t.Subject;
           ot.WhatId = t.WhatId;
            ot.WhatName = t.What.Name;
           ot.OwnerName = t.Owner.Name;
            taskInfo.objTask = ot;
            
            taskInfo.primaryEmail='';
        	taskInfo.PrimaryMobile='';
            if(taskOpportunityMap.containsKey(t.WhatId))
            {
               taskInfo.PrimaryEmail=taskOpportunityMap.get(t.WhatId).Primary_Contact__r.Email; 
               taskInfo.PrimaryMobile=taskOpportunityMap.get(t.WhatId).Primary_Contact__r.MobilePhone;
            }else if(taskAccountMap.containsKey(t.WhatId))
            {
               taskInfo.PrimaryEmail=taskAccountMap.get(t.WhatId).PersonEmail; 
               if(taskAccountMap.get(t.WhatId).recordtype.Name=='Corporate')
               taskInfo.PrimaryEmail=taskAccountMap.get(t.WhatId).retailer_email__c;     
               taskInfo.PrimaryMobile=taskAccountMap.get(t.WhatId).PersonMobilePhone;
            }
            if(t.ActivityDate < Date.today()){                
                overdueTasks.add(taskInfo);
            }
            else{
                todaysTasks.add(taskInfo);
            }
        }
        
        List<Event> eventList = [SELECT Id, ActivityDate,Subject,WhatId,What.Name, Owner.Name FROM Event WHERE ActivityDate <= TODAY AND event_completed__c = false AND OwnerId IN :targetAUPersonIdList ];
        
        System.debug(eventList);
        for(Event et :eventList){
            TaskInfoListWrapper taskInfo =new TaskInfoListWrapper();
              ActivityWrapper ot = new ActivityWrapper();
            
            ot.Id = et.id;
            ot.ActivityDate = et.ActivityDate;
            ot.Subject = et.Subject;
           ot.WhatId = et.WhatId;
            ot.WhatName = et.What.Name;
           ot.OwnerName = et.Owner.Name;
            taskInfo.objTask = ot;
            taskInfo.primaryEmail='';
        	taskInfo.PrimaryMobile='';
            if(taskOpportunityMap.containsKey(et.WhatId))
            {
               taskInfo.PrimaryEmail=taskOpportunityMap.get(et.WhatId).Primary_Contact__r.Email; 
               taskInfo.PrimaryMobile=taskOpportunityMap.get(et.WhatId).Primary_Contact__r.MobilePhone;
            }else if(taskAccountMap.containsKey(et.WhatId))
            {
               taskInfo.PrimaryEmail=taskAccountMap.get(et.WhatId).PersonEmail; 
               if(taskAccountMap.get(et.WhatId).recordtype.Name=='Corporate')
               taskInfo.PrimaryEmail=taskAccountMap.get(et.WhatId).retailer_email__c;     
               taskInfo.PrimaryMobile=taskAccountMap.get(et.WhatId).PersonMobilePhone;
            }
            if(et.ActivityDate < Date.today()){                
                overdueTasks.add(taskInfo);
            }
            else{
                todaysTasks.add(taskInfo);
            }
        }
        
        List<Opportunity> allQualifiedOpp = new  List<Opportunity>();
        
        for(Opportunity opp : [SELECT Id, LastModifiedBy.Id,Enquiry_Type__c,DB_Created_Date_without_Time__c,CreatedDate, OwnerId, Owner.Name, Name, Purchase_Type__c, AccountId, Account.Name, Retailer_Name__c, StageName, Opportunity_Age__c,
                               Primary_Model_Interest__c, Primary_Model_Interest__r.Name, LeadSource, Primary_Contact__r.MobilePhone, Primary_Contact__r.Email, (SELECT Id,Subject, CreatedById FROM Tasks ),
                               (SELECT Id,Subject,CreatedById FROM Events  )
                               FROM Opportunity WHERE IsClosed = False AND  CreatedDate >= :Date.today().addDays(-(numdaysInPast)) AND isWon = FALSE AND (OwnerId IN : targetAUPersonIdList OR (Owner.Retailer_Name__c = :me.Retailer_Name__c AND Owner.Name LIKE '%Default%')) ORDER BY CreatedDate DESC]){
                                   if(  addOppToList( opp, opp.Tasks,opp.Events, isManager)){
                                       allQualifiedOpp.add(opp); 
                                   }
                                   
                                   
                               }
        
        List<TaskListWrapper> sortableTaskList = new List<TaskListWrapper>();
        for(TaskInfoListWrapper TILW: todaysTasks)
        {
            sortableTaskList.add(new TaskListWrapper(TILW));
        }
        sortableTaskList.sort();
        for(taskListWrapper TLW: sortableTaskList)
        {
            returnWrapper.resultFollowUpTaskList.add(TLW.TaskList);
        }
        
        List<TaskListWrapper> sortableOverdueList = new List<TaskListWrapper>();
        for(TaskInfoListWrapper TILW: overdueTasks)
        {
            sortableOverdueList.add(new TaskListWrapper(TILW));
        }
        sortableOverdueList.sort();
        for(taskListWrapper TLW: sortableOverdueList)
        {
            returnWrapper.resultOverdueTaskList.add(TLW.TaskList);
        }
        returnWrapper.resultIsAustralian = true;
        //returnWrapper.resultFollowUpTaskList.addAll(todaysTasks);
        //returnWrapper.resultOverdueTaskList.addAll(overdueTasks);
        returnWrapper.resultOpportunityList.addAll(allQualifiedOpp);
        
        
        return returnWrapper;
    }
    
    public class SearchResultWrapper {
        @AuraEnabled
        public List<TaskInfoListWrapper> resultFollowUpTaskList = new List<TaskInfoListWrapper>();
        @AuraEnabled
        public List<TaskInfoListWrapper> resultOverdueTaskList = new List<TaskInfoListWrapper>();
        @AuraEnabled
        public List<Opportunity> resultOpportunityList = new List<Opportunity>();
        @AuraEnabled
        public List<Lead> resultLeadList = new List<Lead>();   
        @AuraEnabled
        public List<Asset> resultAssetList =new List<Asset>();
        @AuraEnabled
        public boolean resultIsAustralian = false;  
    }
    
    //ActivityDate,Subject,WhatId,What.Name, Owner.Name
    public class ActivityWrapper{
        @AuraEnabled
        public string Id{get;set;}
        @AuraEnabled
        public Date ActivityDate{get;set;}
        @AuraEnabled
        public string Subject{get;set;}
        @AuraEnabled
        // Below 2 variables are now base variables "WhatName" and "WhatId" opposed to the Backends version of "Obj.What.ID/Name".
        // This has been rectified in the Component, but can be altered to better match the base object if need be, though such a need should not exist unless
        // the component needs to be interchangable between Events, Tasks or custom Wrappers such as this one
        public string WhatId{get;set;}
        @AuraEnabled
        public string WhatName{get;set;}
        @AuraEnabled
        public string OwnerName{get;set;}
    }
    
    public class TaskInfoListWrapper{
        @AuraEnabled
        public ActivityWrapper objTask{get;set;}
        @AuraEnabled
        public string primaryEmail{get;set;}
        @AuraEnabled
        public string PrimaryMobile{get;set;}
    }
    
    private static boolean addOppToList(Opportunity opp, List<Task> tsks, List<Event> evts, Boolean isManager){    
        Id meId = UserInfo.getUserId();
        boolean add = false;
        If( opp.OwnerId == meId ||(opp.Owner.Name != null && opp.Owner.Name.toUpperCase().indexOf('DEFAULT') > -1 && isManager ) ){
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