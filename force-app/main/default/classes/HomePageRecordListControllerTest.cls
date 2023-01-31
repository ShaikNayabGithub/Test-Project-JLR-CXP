@isTest
public class HomePageRecordListControllerTest {
    
    static TestMethod void getNewPageRecordListTestNonAus(){       
        User portaluser = TestUtility.createPortaluser('India','Sales Executive');  
        Opportunity opp = new Opportunity();
        opp.Name = 'name';
        opp.StageName = 'Qualified';
        Account testAccount = new Account();
        testAccount.LastName = 'Test Account Name';
        testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId(); 
        testAccount.PersonEmail = 'test@test.test';
        insert testAccount;
        opp.AccountId = testAccount.Id;
        Vehicle_Specification__c vehicleSpec1 = new Vehicle_Specification__c();
        vehicleSpec1.RecordTypeId =  Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByDeveloperName().get('Make').getRecordTypeId(); 
        
        vehicleSpec1.Name = 'Jaguar';
        insert vehicleSpec1;
        opp.Brand__c = vehicleSpec1.Id;
        opp.CloseDate = Date.today().addDays(5);
        opp.OwnerId = portaluser.Id;   
        insert opp;
        
        System.RunAs(portaluser){
            List<Task> activitiesList = new List<Task>();
            activitiesList.add(new Task(OwnerId = portaluser.Id, Subject ='Sample test', ActivityDate = system.today()));
            activitiesList.add(new Task(OwnerId = portaluser.Id, Subject ='Sample test', ActivityDate = system.today().addDays(-1)));
            activitiesList.add(new Task(OwnerId = portaluser.Id, Subject ='Sample test',WhatId = opp.Id, ActivityDate = system.today().addDays(1)));
            insert activitiesList;
            List<Event> eventList = new List<Event>();
            eventList.add(new Event(ActivityDateTime=DateTime.Now(), DurationInMinutes = 1, OwnerId = portaluser.Id, Subject ='Sample test', ActivityDate = system.today()));
            eventList.add(new Event(ActivityDateTime=DateTime.Now(), DurationInMinutes = 1, OwnerId = portaluser.Id, Subject ='Sample test', ActivityDate = system.today().addDays(-1)));
            eventList.add(new Event(ActivityDateTime=DateTime.Now(), DurationInMinutes = 1, OwnerId = portaluser.Id, Subject ='Sample test',WhatId = opp.Id, ActivityDate = system.today().addDays(1)));
            insert eventList;
            HomePageRecordListController.getIsSalesManager();
            HomePageRecordListController.getNewPageRecordList(null);
        }
        
    }
    static TestMethod void getNewPageRecordListTestAustralia(){       
        User portaluser = createPortaluser();     
        
        Opportunity opp = new Opportunity();
        opp.Name = 'name';
        opp.StageName = 'Qualified';
        Account testAccount = new Account();
        testAccount.LastName = 'Test Account Name';
        testAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId(); 
        testAccount.PersonEmail = 'test@test.test';
        insert testAccount;
        opp.AccountId = testAccount.Id;
        Vehicle_Specification__c vehicleSpec1 = new Vehicle_Specification__c();
        vehicleSpec1.RecordTypeId =  Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByDeveloperName().get('Make').getRecordTypeId(); 
        vehicleSpec1.Name = 'Jaguar';
        insert vehicleSpec1;
        opp.Brand__c = vehicleSpec1.Id;
        opp.CloseDate = Date.today().addDays(5);
        opp.OwnerId = portaluser.Id;   
        insert opp;
        
        
        System.RunAs(portaluser){
            List<Task> activitiesList = new List<Task>();
            activitiesList.add(new Task(OwnerId = portaluser.Id, Subject ='Sample test', ActivityDate = system.today()));
            activitiesList.add(new Task(OwnerId = portaluser.Id, Subject ='Sample test', ActivityDate = system.today().addDays(-1)));
            activitiesList.add(new Task(OwnerId = portaluser.Id, Subject ='Sample test',WhatId = opp.Id, ActivityDate = system.today().addDays(1)));
            insert activitiesList;
            List<Event> eventList = new List<Event>();
            eventList.add(new Event(ActivityDateTime=DateTime.Now(), DurationInMinutes = 1, OwnerId = portaluser.Id, Subject ='Sample test',WhatId = opp.Id, ActivityDate = system.today()));
            eventList.add(new Event(ActivityDateTime=DateTime.Now(), DurationInMinutes = 1, OwnerId = portaluser.Id, Subject ='Sample test', WhatId = opp.Id, ActivityDate = system.today().addDays(-1)));
            eventList.add(new Event(ActivityDateTime=DateTime.Now(), DurationInMinutes = 1, OwnerId = portaluser.Id, Subject ='Sample test',WhatId = opp.Id, ActivityDate = system.today().addDays(1)));
            insert eventList;
            HomePageRecordListController.getIsSalesManager();
            HomePageRecordListController.getNewPageRecordList(null);
        }
        
    }
   
    
    private static User createPortaluser(){
        Account retailerAccount = new Account();
        retailerAccount.Name = 'Test Account';
        retailerAccount.RecordTypeId = AccountUtilities.RecordTypes.get('Retailer').Id;
        insert retailerAccount;
        Profile salesExecutiveProfile = [select Id from Profile where Name = 'Sales Executive' limit 1];
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
        commUser.Country = 'Australia';
        commUser.LanguageLocaleKey = 'en_US';
        commUser.LocaleSidKey = 'en_US';
        commUser.TimeZoneSidKey = 'America/Chicago';
        commUser.EmailEncodingKey = 'UTF-8';
        commUser.DefaultCurrencyIsoCode ='GBP';
        commUser.Market__c = 'Australia';
        System.RunAs(new User(Id=userinfo.getUserId())){
            insert commUser;
        }
        return commUser;
    }
}