@isTest
public class ListViewTaskController_Test {
    
     
    @isTest
    public static void testControllerRetrievesTask(){
        User usrAdmin = [SELECT Id FROM User WHERE Id=: UserInfo.getUserId()];
       
        System.runAs(usrAdmin) {
            Task t = new Task();
            t.subject='pppp';
            t.Description='ooooo';
            t.OwnerId=usrAdmin.id;
            insert t;
            Test.startTest();                
            List<Task> tsks = ListViewTaskController.getTasks('', '', true);
            system.assert(tsks.size() > 0);        
            Test.stopTest();
        }
        
        
    }
  
       @isTest
    public static void testControllerRetrievesTaskManager(){
      User salesManager  = createPortaluser('%'+'Sales Manager'+'%');
       System.RunAs(new User(Id=userinfo.getUserId())){
          insert salesManager;
        }
          User_Role__c usr = new  User_Role__c();
        usr.Add_Subordinates__c = true;
        usr.MasterUser__c = salesManager.id;
        usr.Viewing_User__c = salesManager.id;
        insert usr;
        System.runAs(salesManager) {
            Task t = new Task();
            t.subject='pppp';
            t.Description='ooooo';
            t.OwnerId=salesManager.id;
            insert t;
            Test.startTest();                
            List<Task> tsks = ListViewTaskController.getTasks('', '', true);
            system.assert(tsks.size() > 0);        
            Test.stopTest();
        }
        
        
    }
           @isTest
    public static void testControllerRetrievesTaskPrinciple(){
      User salesPrinciple  = createPortaluser('Dealer Principle');
       // User salesManager  = createPortaluser('%'+'Sales Manager'+'%', salesPrinciple );
      User salesManager;
       System.RunAs(new User(Id=userinfo.getUserId())){
          insert salesPrinciple;
            salesManager  = createPortaluser('%'+'Sales Manager'+'%', salesPrinciple );
           insert salesManager;
        }
        System.runAs(salesPrinciple) {
            Task t = new Task();
            t.subject='pppp';
            t.Description='ooooo';
            t.OwnerId=salesPrinciple.id;
            insert t;
            Test.startTest();                
            List<Task> tsks = ListViewTaskController.getTasks('', '', true);
            system.assert(tsks.size() > 0);    
            List<User> sm = [SELECT id, ManagerId, (SELECT Id,Name,Profile.Name FROM ManagedUsers) from user  ];
            System.debug('sm '+Json.serializePretty(sm));
            Test.stopTest();
        }
        
        
    }
   
        @isTest
    public static void testControllerRetrievesTaskWhenNoParameterPassed(){
        User usrAdmin = [SELECT Id FROM User WHERE Id=: UserInfo.getUserId()];
       
        System.runAs(usrAdmin) {
            string whereQuery; 
            string limitNum;
            Task t = new Task();
            t.subject='pppp';
            t.Description='ooooo';
            t.OwnerId=usrAdmin.id;
            insert t;
            Test.startTest();                
            List<Task> tsks = ListViewTaskController.getTasks(whereQuery, limitNum, false);
            system.assert(tsks.size() > 0);        
            Test.stopTest();
        }
        
        
    }
    
    
       private static User createPortaluser(string profile, User manager){
        Account retailerAccount = [SELECT id from Account where Name = 'Test Account' limit 1];
           
        Profile salesExecutiveProfile = [select Id from Profile where Name Like :profile  limit 1];
        //User portaluser = createuser(retailerAccount, salesExecutiveProfile.Id);
        
        Contact testCommContact = new Contact();
        testCommContact.LastName = 'Test Name';
        testCommContact.AccountID = retailerAccount.Id;
        //testCommContact.RecordTypeId = [select Id from RecordType where SObjectType = 'Contact' and Name = 'Employee Contact' limit 1].Id;
        testCommContact.RecordTypeId =  Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Employee_Contact').getRecordTypeId();
        testCommContact.Email = 'tesfdgfgt@test.test';
        insert testCommContact;
        User commUser = new User();
        commUser.Phone = '07681102495';
           commUser.ManagerId = manager.Id;
            commUser.Partner_Manager__c = manager.Id;
        commUser.Email = 'tedfgfgst@test.test';
        commUser.ProfileId = salesExecutiveProfile.Id;
        commUser.UserName = 'tesdfgfdfgt@test.test.retailer';
        commUser.Alias = 'TTT';
        commUser.ContactID = testCommContact.Id;
        commUser.FirstName = 'Test';
        commUser.LastName = 'Test';
        commUser.Country = 'India';
        commUser.LanguageLocaleKey = 'en_US';
        commUser.LocaleSidKey = 'en_US';
        commUser.TimeZoneSidKey = 'America/Chicago';
        commUser.EmailEncodingKey = 'UTF-8';
        commUser.DefaultCurrencyIsoCode ='GBP';
        commUser.Market__c = 'IN';
        commUser.Country_Iso_code__c = 'IN';
      //  System.RunAs(new User(Id=userinfo.getUserId())){
      //      insert commUser;
      //  }
        return commUser;
    }

    private static User createPortaluser(string profile){
        Account retailerAccount = new Account();
        retailerAccount.Name = 'Test Account';
        retailerAccount.RecordTypeId = AccountUtilities.RecordTypes.get('Retailer').Id;
        insert retailerAccount;
        Profile salesExecutiveProfile = [select Id from Profile where Name Like :profile  limit 1];
        //User portaluser = createuser(retailerAccount, salesExecutiveProfile.Id);
        
        Contact testCommContact = new Contact();
        testCommContact.LastName = 'Test Name';
        testCommContact.AccountID = retailerAccount.Id;
        //testCommContact.RecordTypeId = [select Id from RecordType where SObjectType = 'Contact' and Name = 'Employee Contact' limit 1].Id;
        testCommContact.RecordTypeId =  Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Employee_Contact').getRecordTypeId();
        testCommContact.Email = 'test@test.test';
        insert testCommContact;
        User commUser = new User();
        commUser.Phone = '07681102495';
        commUser.Email = 'test@test.test';
        commUser.ProfileId = salesExecutiveProfile.Id;
        commUser.UserName = 'test@test.test.retailer';
        commUser.Alias = 'TTT';
        commUser.ContactID = testCommContact.Id;
        commUser.FirstName = 'Test';
        commUser.LastName = 'Test';
        commUser.Country = 'India';
        commUser.LanguageLocaleKey = 'en_US';
        commUser.LocaleSidKey = 'en_US';
        commUser.TimeZoneSidKey = 'America/Chicago';
        commUser.EmailEncodingKey = 'UTF-8';
        commUser.DefaultCurrencyIsoCode ='GBP';
        commUser.Market__c = 'IN';
               commUser.Country_Iso_code__c = 'IN';
      //  System.RunAs(new User(Id=userinfo.getUserId())){
      //      insert commUser;
      //  }
        return commUser;
    }
    
}