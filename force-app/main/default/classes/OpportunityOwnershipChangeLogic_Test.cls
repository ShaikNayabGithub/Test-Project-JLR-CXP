@isTest
public class OpportunityOwnershipChangeLogic_Test {

    
       @IsTest
    static void OpportunityChangedOwnership_TestContactUpdated() {
               Id individualId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();
           Id JlrContactId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('JLR_Contact').getRecordTypeId();
        Id CorporateId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate').getRecordTypeId();
        Id individualPrimaryId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual_Golden_Record').getRecordTypeId();
        Id CorporatePrimaryId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate_Golden_Record').getRecordTypeId();
        
        Opportunity opp = new Opportunity();
        opp = createOpportunity(false);
        User bob = createPortaluser();
   Account acc1 = [SELECT id, recordtype.name,recordtypeId, owner.name FROM Account where id = :opp.AccountId];
      Contact con = new Contact();
        con.firstName = 'bob';
        con.lastname = 'forapples';
        con.email = 'bob.forapples@google.com';
        con.AccountId = acc1.id;
           con.RecordTypeId = JlrContactId;
       insert con;
        opp.Primary_Contact__c = con.Id;
        update opp;
    //    System.debug('acc1 ' + acc1);
        Test.startTest();
        opp.OwnerId = bob.Id;
        
        update opp;
        Test.stopTest();

        Opportunity oppnew = [SELECT Id, AccountId, Primary_Contact__c,Primary_Contact__r.primary_contact__c FROM Opportunity WHERE Id = :opp.Id];
       Account acc = [SELECT id, recordtype.name,recordtypeId,PersonContactId, owner.name FROM Account where id = :oppnew.AccountId];
       Contact newPrim = [SELECT Id, recordtype.name, primary_contact__c from Contact where primary_contact__c = :con.id];
      //  System.debug('Opp ' + oppnew);
      //  System.debug('acc ' + acc);
     //  System.debug('newPrim ' + newPrim);
     //      System.debug('newPrim ' + newPrim.recordtype.name );
           System.assertEquals(oppnew.Primary_Contact__c, newPrim.Id);
                   System.assertEquals(oppnew.Primary_Contact__r.primary_contact__c, con.Id);
  


    }
    
        @IsTest
    static void OpportunityChangedOwnership_Test() {
               Id individualId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();
        Id CorporateId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate').getRecordTypeId();
        Id individualPrimaryId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual_Golden_Record').getRecordTypeId();
        Id CorporatePrimaryId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate_Golden_Record').getRecordTypeId();
        
        Opportunity opp = new Opportunity();
        opp = createOpportunity(true);
        User bob = createPortaluser();
   Account acc1 = [SELECT id, recordtype.name,recordtypeId, owner.name FROM Account where id = :opp.AccountId];
     //  System.debug('acc1 ' + acc1);
        Test.startTest();
        opp.OwnerId = bob.Id;
        
        update opp;
        Test.stopTest();

        Opportunity oppnew = [SELECT Id, AccountId, Primary_Contact__c FROM Opportunity WHERE Id = :opp.Id];
       Account acc = [SELECT id, recordtype.name,recordtypeId,PersonContactId, owner.name FROM Account where id = :oppnew.AccountId];
       
      //  System.debug('Opp ' + oppnew);
     //   System.debug('acc ' + acc);
         System.assertEquals(individualPrimaryId, acc1.RecordTypeId);
           System.assertEquals(oppnew.Primary_Contact__c, acc.PersonContactId);
        System.assertEquals(individualId, acc.RecordTypeId);


    }
    
      @IsTest
    static void OpportunityChangedOwnership_TestNotes() {
               Id individualId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();
        Id CorporateId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate').getRecordTypeId();
        Id individualPrimaryId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual_Golden_Record').getRecordTypeId();
        Id CorporatePrimaryId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate_Golden_Record').getRecordTypeId();
        
        Opportunity opp = new Opportunity();
        opp = createOpportunity(true);
        User bob = createPortaluser();
   Account acc1 = [SELECT id, recordtype.name,recordtypeId, owner.name FROM Account where id = :opp.AccountId];
       System.debug('acc1 ' + acc1);
        Test.startTest();
        opp.OwnerId = bob.Id;
        
        update opp;
        Test.stopTest();

        Note oppnewnote = [SELECT Id, Body FROM Note WHERE ParentId = :opp.Id limit 1];
     
         
           System.assertEquals('dsdds', oppnewnote.Body);
       


    }
    

    public static void addOppLineItemToOpp(Opportunity opp) {

        Vehicle_Specification__c brand1 = TestClass_VehicleSpecificationBuilder.BuildMake();

        OpportunityLineItem opportunityLineItem1 = TestClass_OppLineItemCreator.CreateOppLineItem(opp.Id, brand1.Id, null);
        insert opportunityLineItem1;
    }

    public static User createTestUser() {
        User testUser = new User();
        testUser.Phone = '07681102495';
        testUser.Email = 'test@test.test';
        testUser.ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard Sales User' LIMIT 1].Id;
        testUser.Username = 'test@test.test.retailer';
        testUser.Alias = 'TTT';
        testUser.FirstName = 'Test';
        testUser.LastName = 'Test';
        testUser.LanguageLocaleKey = 'en_US';
        testUser.LocaleSidKey = 'en_US';
        testUser.TimeZoneSidKey = 'America/Chicago';
        testUser.EmailEncodingKey = 'UTF-8';
        insert testUser;
        return testUser;
    }

    public static Opportunity createOpportunity(boolean isPerson) {
                       Id individualId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();
        Id CorporateId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate').getRecordTypeId();
        Id individualPrimaryId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual_Golden_Record').getRecordTypeId();
        Id CorporatePrimaryId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate_Golden_Record').getRecordTypeId();
        Opportunity opp = new Opportunity();
        opp.Name = 'test';
        opp.StageName = 'Contacted';
        Account testAccount = new Account();
        if(isPerson){
             testAccount.LastName = 'Test Account Name';
        testAccount.RecordTypeId = individualPrimaryId;
        testAccount.PersonEmail = 'tesat@teast.teast';
        }else{
              testAccount.Name = 'Test Account Name';
        testAccount.RecordTypeId = CorporatePrimaryId;
        testAccount.Retailer_Email__c = 'tessat@teast.tesat';
        }
       
        testAccount.Description = 'dsdds';
        testAccount.Customer_Journey_Stage__c = 'Take the Keys';
        insert testAccount;
        opp.AccountId = testAccount.Id;
        Vehicle_Specification__c vehicleSpec1 = new Vehicle_Specification__c();
        vehicleSpec1.RecordType = [SELECT Id FROM RecordType WHERE Name = 'Make' AND SobjectType = 'Vehicle_Specification__c' LIMIT 1];
        vehicleSpec1.Name = 'Jaguar';
        insert vehicleSpec1;
        opp.Brand__c = vehicleSpec1.Id;
        opp.CloseDate = Date.parse('12/12/2016');
        insert opp;
        return opp;
    }

    public static Opportunity createOpportunityWithStageAndName(String stageName, String name) {
        Opportunity opp = new Opportunity();
        opp.Name = name;
        opp.StageName = stageName;
        Account testAccount = new Account();
        testAccount.LastName = 'Test Account Name';
        testAccount.RecordType = [SELECT Id FROM RecordType WHERE Name = 'Individual' AND SobjectType = 'Account' LIMIT 1];
        testAccount.PersonEmail = 'test@test.test';
          testAccount.Description = 'dsdds';
        insert testAccount;
        opp.AccountId = testAccount.Id;
        Vehicle_Specification__c vehicleSpec1 = new Vehicle_Specification__c();
        vehicleSpec1.RecordType = [SELECT Id FROM RecordType WHERE Name = 'Make' AND SobjectType = 'Vehicle_Specification__c' LIMIT 1];
        vehicleSpec1.Name = 'Jaguar';
        insert vehicleSpec1;
        opp.Brand__c = vehicleSpec1.Id;
        opp.CloseDate = Date.parse('12/12/2016');
        insert opp;
        return opp;
    }
     public static Id individualRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();
    public static Id corporateRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate').getRecordTypeId();
    public static User createPortaluser(){
        Account retailerAccount = new Account();
        retailerAccount.Name = 'Test Account';
        retailerAccount.RecordTypeId = AccountUtilities.RecordTypes.get('Retailer').Id;
        insert retailerAccount;
        Profile salesExecutiveProfile = [select Id from Profile where Name LIKE '%Sales Executive AUS%' limit 1];     
        
        Contact testCommContact = new Contact();
        testCommContact.LastName = 'Test Name';
        testCommContact.AccountID = retailerAccount.Id;    
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
         commUser.Country_iso_code__c = 'AU';
        commUser.LanguageLocaleKey = 'en_US';
        commUser.LocaleSidKey = 'en_US';
        commUser.TimeZoneSidKey = 'America/Chicago';
        commUser.EmailEncodingKey = 'UTF-8';
        commUser.DefaultCurrencyIsoCode ='AUD';
        commUser.Market__c = 'Australia';
        System.RunAs(new User(Id=userinfo.getUserId())){
        insert commUser;
        }
        return commUser;
    }

    
}