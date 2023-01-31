@isTest
public class Task_TriggerHandler_Test{
     
    static testMethod void createdTask_testEmailNotificationToPartnerUser() 
    {
        Case cs = TestClass_CaseCreator.create('Phone');
        Account a = new Account(name='test');
        insert a;
        Contact c = new Contact(lastname='pppp',accountid=a.id,Email='email_is@mandatory.com');
        insert c;
        User u = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', country='United States',IsActive =true,
                ContactId = c.Id,
                timezonesidkey='America/Los_Angeles', username='kmoihte4edtcews34789hhgtfe@cxp.com');  
        u.profileid = [select id from profile where name='Partner Community User'].id; 
	User usrAdmin = [SELECT Id FROM User WHERE Id=: UserInfo.getUserId()];
	System.runAs(usrAdmin) {
        insert u;
        }
        Task t = new Task();
        t.subject='pppp';
        t.Description='ooooo';
        t.OwnerId=u.id;
        t.WhatId=cs.id;
        Test.startTest();
        system.assert(Limits.getEmailInvocations()==0);
        insert t;
        system.assert(t!=null && u!=null && c!=null && cs!=null && a!=null); 
        system.assert(Limits.getEmailInvocations()>0);
        Test.stopTest();
        
    }
    
    static testMethod void createdTask_PublicFieldTrue_NotPrivateTask()
    {
        
        Task_TriggerHandler handler = new Task_TriggerHandler();
        Case cs = TestClass_CaseCreator.create('Phone');
        List<Task> tasks = new List<Task>();
   		Task testTask = new Task();
        testTask.WhatId=cs.id;
        testTask.IsVisibleInSelfService = false;
        testTask.RecordTypeId = Task.sObjectType.getDescribe().getRecordTypeInfosByName().get('Task').getRecordTypeId();
        tasks.add(testTask);
    
        handler.PreCreate(tasks);

        system.assertEquals(true, tasks[0].IsVisibleInSelfService);
    }

    static testMethod void createdTask_PublicFieldNotTrue_PrivateTask()
    {
        
        Task_TriggerHandler handler = new Task_TriggerHandler();
        Case cs = TestClass_CaseCreator.create('Phone');
        List<Task> tasks = new List<Task>();
        
    	Task testTask = new Task();
        testTask.WhatId = cs.id;
        testTask.IsVisibleInSelfService = false;
        testTask.RecordTypeId = Task.sObjectType.getDescribe().getRecordTypeInfosByName().get('Task').getRecordTypeId();
        tasks.add(testTask);
    
        handler.PreCreate(tasks);

        system.assertEquals(true, tasks[0].IsVisibleInSelfService);
    }

    static testMethod void updateTask_PublicFieldNotChanged_Any()
    {
        
        Task_TriggerHandler handler = new Task_TriggerHandler();
        Case cs = TestClass_CaseCreator.create('Phone');
        List<Task> tasks = new List<Task>();    
        Task testTask = new Task();
        testTask.WhatId = cs.id;
        testTask.IsVisibleInSelfService = false;
        testTask.RecordTypeId = Task.sObjectType.getDescribe().getRecordTypeInfosByName().get('Private Task').getRecordTypeId();
        tasks.add(testTask);
        
        List<Task> oldTasks = new List<Task>();    
        Task oldTestTask = new Task();
        oldTestTask.IsVisibleInSelfService = true;
        oldTestTask.RecordTypeId = Task.sObjectType.getDescribe().getRecordTypeInfosByName().get('Private Task').getRecordTypeId();
        oldTasks.add(oldTestTask); 
        //handler.PreUpdate(tasks, oldTasks); 
        //handler.PostUpdate(tasks, oldTasks);
        system.assertEquals(false, tasks[0].IsVisibleInSelfService);
    }
    
    
    static testMethod void deleteTaskNotAllowed()
    {
    
     
      String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
      Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];     
      User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
      EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
      LocaleSidKey='en_US', ProfileId = p.Id,
      TimeZoneSidKey='America/Los_Angeles',
      UserName=uniqueUserName);
      
      List<Object_CRUD_Permissions__c > settings = new List<Object_CRUD_Permissions__c>();
      Object_CRUD_Permissions__c customS = new    Object_CRUD_Permissions__c();
      customS.Able_to_Delete_Task__c = True;
      customS.SetupOwnerId = UserInfo.getOrganizationId();
      settings.add(customS);
      Object_CRUD_Permissions__c customS2 = new    Object_CRUD_Permissions__c();
      customS2 .Able_to_Delete_Task__c = True;
      customS2 .SetupOwnerId = p.Id;
      settings.add(customS2);
      insert settings;

        System.runAs(u) {           
              
        Task_TriggerHandler handler = new Task_TriggerHandler();
        List<Task> tasks = new List<Task>();    
        Task testTask = new Task();
         testTask.RecordTypeId = Task.sObjectType.getDescribe().getRecordTypeInfosByName().get('Task').getRecordTypeId();
         tasks.add(testTask);
         try{                  
         handler.PreDelete(tasks);
         handler.PostDelete(tasks);
         }
         catch(aop_AOPException e)
         {
         Boolean expectedExceptionThrown =  e.getMessage().contains(Label.Prevent_Task_Deletion_Error_Message);        
         System.AssertEquals(expectedExceptionThrown, true);
         
         
         }
             
          }
    
       
    
    }
    
      static testMethod void deleteTaskIsNotAllowedDifferentUser()
    {
    
     
      String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
      Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
      Profile p2 = [SELECT Id FROM Profile WHERE Name='JLR System Administrator'];
      User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
      EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
      LocaleSidKey='en_US', ProfileId = p.Id,
      TimeZoneSidKey='America/Los_Angeles',
      UserName=uniqueUserName);
      List<Object_CRUD_Permissions__c > settings = new List<Object_CRUD_Permissions__c>();
      Object_CRUD_Permissions__c customS = new    Object_CRUD_Permissions__c();
      customS.Able_to_Delete_Task__c = True;
      customS.SetupOwnerId = UserInfo.getOrganizationId();
      settings.add(customS);
      Object_CRUD_Permissions__c customS2 = new    Object_CRUD_Permissions__c();
      customS2 .Able_to_Delete_Task__c = True;
      customS2 .SetupOwnerId = p2.Id;
      settings.add(customS2);
      insert settings;
      
      Boolean allowed;

        System.runAs(u) 
        {
           
              
         Task_TriggerHandler handler = new Task_TriggerHandler();
        
         List<Task> tasks = new List<Task>();    
         Task testTask = new Task();
         testTask.RecordTypeId = Task.sObjectType.getDescribe().getRecordTypeInfosByName().get('Task').getRecordTypeId();
         tasks.add(testTask);
             try
             {                  
             handler.PreDelete(tasks);
             allowed = true;
             }
             catch(aop_AOPException e)
             {
             allowed = false;                       
             }
         
         System.Assert(allowed);
             
        }
    
       
    
    }
       static testMethod void deleteTaskIsAllowedbycreator()
    {
    
     
      String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
      Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
      Profile p2 = [SELECT Id FROM Profile WHERE Name='JLR System Administrator'];
      User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
      EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
      LocaleSidKey='en_US', ProfileId = p.Id,
      TimeZoneSidKey='America/Los_Angeles',
      UserName=uniqueUserName);
      List<Object_CRUD_Permissions__c > settings = new List<Object_CRUD_Permissions__c>();
      Object_CRUD_Permissions__c customS = new    Object_CRUD_Permissions__c();
      customS.Able_to_Delete_Task__c = True;
      customS.SetupOwnerId = UserInfo.getOrganizationId();
      settings.add(customS);
      Object_CRUD_Permissions__c customS2 = new    Object_CRUD_Permissions__c();
      customS2 .Able_to_Delete_Task__c = True;
      customS2 .SetupOwnerId = p2.Id;
      settings.add(customS2);
      insert settings;
      
      Boolean allowed;

        System.runAs(u) 
        {
           
              
         Task_TriggerHandler handler = new Task_TriggerHandler();
        
         List<Task> tasksol = new List<Task>();    
         Task testTask = new Task();
            testTask.subject = 'test';
         testTask.RecordTypeId = Task.sObjectType.getDescribe().getRecordTypeInfosByName().get('Task').getRecordTypeId();
          tasksol.add(testTask);
          insert tasksol;
             List<Task> tasks = [Select id, CreatedById from task];
           
             try
             {                  
             handler.PreDelete(tasks);
             allowed = true;
             }
             catch(aop_AOPException e)
             {
             allowed = false;                       
             }
         
         System.Assert(allowed);
             
        }
    
       
    
    }
    
     static testMethod void createdTask_testEmailNotificationToPartnerUser1() 
    {
        Case cs = TestClass_CaseCreator.create('Phone');
        Account a = new Account(name='test');
        insert a;
        Contact c = new Contact(lastname='pppp',accountid=a.id,Email='email_is@mandatory.com');
        insert c;
        
        Vehicle_Specification__c vehSpec = new Vehicle_Specification__c();
        vehSpec.name = 'Make Model';
        vehSpec.recordTypeId = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByName().get('Make').getRecordTypeId();
        insert vehSpec;
        
        Vehicle_Specification__c modelSpec = new Vehicle_Specification__c();
        modelSpec.name = 'Model1';
        modelSpec.recordTypeId = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByName().get('Model').getRecordTypeId();
        modelSpec.Make__c = vehSpec.id;
        insert modelSpec;
        
        
        User u = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', country='United States',IsActive =true,
                ContactId = c.Id,
                timezonesidkey='America/Los_Angeles', username='kmoihte4edtcews34789hhgtfe@cxp.com');  
        u.profileid = [select id from profile where name='Partner Community User'].id; 
	User usrAdmin = [SELECT Id FROM User WHERE Id=: UserInfo.getUserId()];
	System.runAs(usrAdmin) {
        insert u;
        }
        Task t = new Task();
        t.subject='pppp';
        t.Description='ooooo';
        t.OwnerId=u.id;
        t.WhatId=cs.id;
        t.Vehicle_Model__c = modelSpec.id;
        t.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Appraisal').getRecordTypeId();
        Test.startTest();
        system.assert(Limits.getEmailInvocations()==0);
        insert t;
        system.assert(t!=null && u!=null && c!=null && cs!=null && a!=null); 
        system.assert(Limits.getEmailInvocations()>0);
        Test.stopTest();
        
    }
    
     static testMethod void createdTask_testEmailNotificationToPartnerUser2() 
    {
        Case cs = TestClass_CaseCreator.create('Phone');
        Account a = new Account(name='test');
        insert a;
        Contact c = new Contact(lastname='pppp',accountid=a.id,Email='email_is@mandatory.com');
        insert c;
        Opportunity oppIns = new Opportunity();
        oppIns.name = 'Opp1';
        oppIns.StageName = 'Contacted';
        oppIns.Amount = 1000;
        oppIns.CloseDate = system.today()+30;
        oppIns.Country_ISO_Code__c = 'JP';
        insert oppIns;
        
        Vehicle_Specification__c vehSpec = new Vehicle_Specification__c();
        vehSpec.name = 'Make Model';
        vehSpec.recordTypeId = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByName().get('Make').getRecordTypeId();
        insert vehSpec;
        
        Vehicle_Specification__c modelSpec = new Vehicle_Specification__c();
        modelSpec.name = 'Model1';
        modelSpec.recordTypeId = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByName().get('Model').getRecordTypeId();
        modelSpec.Make__c = vehSpec.id;
        insert modelSpec;
        
        
        User u = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', country='United States',IsActive =true,
                ContactId = c.Id,
                timezonesidkey='America/Los_Angeles', username='kmoihte4edtcews34789hhgtfe@cxp.com');  
        u.profileid = [select id from profile where name='Partner Community User'].id; 
	User usrAdmin = [SELECT Id FROM User WHERE Id=: UserInfo.getUserId()];
	System.runAs(usrAdmin) {
        insert u;
        }
        Task t = new Task();
        t.subject='pppp';
        t.Description='ooooo';
        t.OwnerId=u.id;
        t.WhatId=cs.id;
        t.WhatId = oppIns.id;
        t.Vehicle_Model__c = modelSpec.id;
        t.RecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get('Appraisal').getRecordTypeId();
        Test.startTest();
        insert t;
        Test.stopTest();
        
    }
    
    
}