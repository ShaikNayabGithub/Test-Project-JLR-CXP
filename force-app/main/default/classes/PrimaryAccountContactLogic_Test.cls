@IsTest
public class PrimaryAccountContactLogic_Test {
    
    private static final String corporateRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate').getRecordTypeId();
    private static final String goldenCorporateRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate_Golden_Record').getRecordTypeId();
    private static final String goldenIndividualRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual_Golden_Record').getRecordTypeId();
    private static final String goldencorporateContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('JLR_Contact').getRecordTypeId();
    
    static testmethod void  testFirstNameLastNameContact(){
        //Arrange
        Account retailerAccount = TestClass_AccountCreator.CreateRetailer();
        Profile salesExecutiveProfile = [SELECT Id FROM Profile WHERE Name = 'Sales Executive' LIMIT 1];
        User portalUser = createuser(retailerAccount, salesExecutiveProfile.Id, 'test@test.test.retailer');
        
        
        Account acc1 = buildCorporateAccountWithoutInsert('corpTest');
        acc1.RecordTypeId = goldenCorporateRecordTypeId;
        acc1.Is_Primary__c = true;   
        insert acc1;
        Contact con1 = buildContactWithoutInsert(acc1);
        con1.RecordTypeId = goldencorporateContactRecordTypeId;
        con1.MobilePhone = '07454512351535';
        con1.Email = 'asasassd@fdf.com';
        con1.Email2__c = 'asadassdassd@fdf.com';
        insert con1;
        
        AccountShare ash = new AccountShare(AccountId=acc1.Id, UserOrGroupId=portalUser.id, AccountAccessLevel='edit', OpportunityAccessLevel='none', CaseAccessLevel='none');
        insert ash;
        
        List<Account> accs = new List<Account>();
        
        //Act
        System.runAs(portalUser)
        {
            Account acc2 = buildCorporateAccountWithoutInsert('corpTest');
            acc2.RecordTypeId = corporateRecordTypeId;
            
            insert acc2;
            
            Contact con = buildContactWithoutInsert(acc2);
            con.OtherPhone = '07454512351535';
            
            insert con;
            
            Contact con2 = buildContactWithoutInsert(acc2);
            con2.LastName = 'bobby';
            con2.OtherPhone = '0745454512351535';
            
            insert con2;
            
            
            
            
        }
        
        
        
        PrimaryAccountContactGateway gate = new PrimaryAccountContactGateway();
        //Assert
        
        List<Account> results = [Select Id FROM Account where recordtypeId = :goldenCorporateRecordTypeId];
        system.assertEquals(1, results.size());
        
        
    }
         static testmethod void  testLastNameContactNoEmail(){
        //Arrange
        Account retailerAccount = TestClass_AccountCreator.CreateRetailer();
        Profile salesExecutiveProfile = [SELECT Id FROM Profile WHERE Name = 'Sales Executive' LIMIT 1];
        User portalUser = createuser(retailerAccount, salesExecutiveProfile.Id, 'test@test.test.retailer');
        
        
        Account acc1 = buildCorporateAccountWithoutInsert('corpTest');
        acc1.RecordTypeId = goldenCorporateRecordTypeId;
        acc1.Is_Primary__c = true;   
        insert acc1;
        Contact con1 = buildContactWithoutInsert(acc1);
             con1.FirstName = null;
        con1.RecordTypeId = goldencorporateContactRecordTypeId;
        con1.MobilePhone = '07454512351535';
        con1.Email = null;
        con1.Email2__c = null;
        insert con1;
        
        AccountShare ash = new AccountShare(AccountId=acc1.Id, UserOrGroupId=portalUser.id, AccountAccessLevel='edit', OpportunityAccessLevel='none', CaseAccessLevel='none');
        insert ash;
        
        List<Account> accs = new List<Account>();
        
        //Act
        System.runAs(portalUser)
        {
            Account acc2 = buildCorporateAccountWithoutInsert('corpTest');
            acc2.RecordTypeId = corporateRecordTypeId;
            
            insert acc2;
            
            Contact con = buildContactWithoutInsert(acc2);
               con.FirstName = null;
            con.OtherPhone = '07454512351535';
            
            insert con;
            
            Contact con2 = buildContactWithoutInsert(acc2);
            con2.LastName = 'bobby';
            con2.OtherPhone = '0745454512351535';
            
            insert con2;
            
            
            
            
        }
        
        
        
        //Assert
        
        List<Account> results = [Select Id FROM Account where recordtypeId = :goldenCorporateRecordTypeId];
        system.assertEquals(1, results.size());
        
        
    }
    
    
     static testmethod void  testFirstNameLastNameContactNoEmail(){
        //Arrange
        Account retailerAccount = TestClass_AccountCreator.CreateRetailer();
        Profile salesExecutiveProfile = [SELECT Id FROM Profile WHERE Name = 'Sales Executive' LIMIT 1];
        User portalUser = createuser(retailerAccount, salesExecutiveProfile.Id, 'test@test.test.retailer');
        
        
        Account acc1 = buildCorporateAccountWithoutInsert('corpTest');
        acc1.RecordTypeId = goldenCorporateRecordTypeId;
        acc1.Is_Primary__c = true;   
        insert acc1;
        Contact con1 = buildContactWithoutInsert(acc1);
        con1.RecordTypeId = goldencorporateContactRecordTypeId;
        con1.MobilePhone = '07454512351535';
        con1.Email = null;
        con1.Email2__c = null;
        insert con1;
        
        AccountShare ash = new AccountShare(AccountId=acc1.Id, UserOrGroupId=portalUser.id, AccountAccessLevel='edit', OpportunityAccessLevel='none', CaseAccessLevel='none');
        insert ash;
        
        List<Account> accs = new List<Account>();
        
        //Act
        System.runAs(portalUser)
        {
            Account acc2 = buildCorporateAccountWithoutInsert('corpTest');
            acc2.RecordTypeId = corporateRecordTypeId;
            
            insert acc2;
            
            Contact con = buildContactWithoutInsert(acc2);
            con.OtherPhone = '07454512351535';
            
            insert con;
            
            Contact con2 = buildContactWithoutInsert(acc2);
            con2.LastName = 'bobby';
            con2.OtherPhone = '0745454512351535';
            
            insert con2;
            
            
            
            
        }
        
        
        
        //Assert
        
        List<Account> results = [Select Id FROM Account where recordtypeId = :goldenCorporateRecordTypeId];
        system.assertEquals(1, results.size());
        
        
    }
    
    
    
    
    static testmethod void  testTitleMatchingContact(){
        //Arrange
        Account retailerAccount = TestClass_AccountCreator.CreateRetailer();
        Profile salesExecutiveProfile = [SELECT Id FROM Profile WHERE Name = 'Sales Executive' LIMIT 1];
        User portalUser = createuser(retailerAccount, salesExecutiveProfile.Id, 'test@test.test.retailer');
        
        
        Account acc1 = buildCorporateAccountWithoutInsert('corpTest');
        acc1.RecordTypeId = goldenCorporateRecordTypeId;
        acc1.Is_Primary__c = true;   
        insert acc1;
        Contact con1 = buildContactWithoutInsert(acc1);
        con1.RecordTypeId = goldencorporateContactRecordTypeId;
        con1.MobilePhone = '07454512351535';
        con1.Title = 'Mr';
        con1.FirstName = null;
        con1.Email = 'asasassd@fdf.com';
        con1.Email2__c = 'asadassdassd@fdf.com';
        insert con1;
        
        AccountShare ash = new AccountShare(AccountId=acc1.Id, UserOrGroupId=portalUser.id, AccountAccessLevel='edit', OpportunityAccessLevel='none', CaseAccessLevel='none');
        insert ash;
        
        List<Account> accs = new List<Account>();
        
        //Act
        System.runAs(portalUser)
        {
            Account acc2 = buildCorporateAccountWithoutInsert('corpTest');
            acc2.RecordTypeId = corporateRecordTypeId;
            
            insert acc2;
            
            Contact con = buildContactWithoutInsert(acc2);
            con.OtherPhone = '0745451235133535';
            con.Title = 'Mr';
            con.FirstName = null;
             con.Email = 'asasassd@fdf.com';
            insert con;
            
            
            
             Contact con2 = buildContactWithoutInsert(acc2);
           
             con2.Email = 'anullsasassd@fdf.com';
            con2.Title = 'Mr';
            con2.FirstName = null;
            con2.LastName = 'null';
            insert con2;
            
            
            
        }
        
        PrimaryAccountContactGateway gate = new PrimaryAccountContactGateway();
        //Assert
        
          List<Account> results = [Select Id FROM Account where recordtypeId = :goldenCorporateRecordTypeId];
        List<Contact> conresults = [SELECT ID, name, email FROM CONTACT where primary_contact__c != null];
       system.debug('conresults' +conresults);
        system.assertEquals(1, results.size());
        system.assertEquals(2, conresults.size());
        
    }
    
    
    
    
    static testmethod void  testFirstThreeDigitMatchingContact(){
        //Arrange
        Account retailerAccount = TestClass_AccountCreator.CreateRetailer();
        Profile salesExecutiveProfile = [SELECT Id FROM Profile WHERE Name = 'Sales Executive' LIMIT 1];
        User portalUser = createuser(retailerAccount, salesExecutiveProfile.Id, 'test@test.test.retailer');
        
        
        Account acc1 = buildCorporateAccountWithoutInsert('corpTest');
        acc1.RecordTypeId = goldenCorporateRecordTypeId;
        acc1.Is_Primary__c = true;   
        insert acc1;
        Contact con1 = buildContactWithoutInsert(acc1);
        con1.RecordTypeId = goldencorporateContactRecordTypeId;
        con1.MobilePhone = '07454512351535';
        
        con1.FirstName = 'Robert';
        con1.Email = 'asasassd@fdf.com';
        con1.Email2__c = 'asadassdassd@fdf.com';
        insert con1;
        
        AccountShare ash = new AccountShare(AccountId=acc1.Id, UserOrGroupId=portalUser.id, AccountAccessLevel='edit', OpportunityAccessLevel='none', CaseAccessLevel='none');
        insert ash;
        
        List<Account> accs = new List<Account>();
        
        //Act
        System.runAs(portalUser)
        {
            Account acc2 = buildCorporateAccountWithoutInsert('corpTest');
            acc2.RecordTypeId = corporateRecordTypeId;
            
            insert acc2;
            
            Contact con = buildContactWithoutInsert(acc2);
            con.OtherPhone = '0745451235133535';
            
            con.FirstName = 'Rob';
            insert con;
            
            
            
            
            
            
        }
        
        PrimaryAccountContactGateway gate = new PrimaryAccountContactGateway();
        //Assert
        
        List<Account> results = gate.getPotentialPrimaryAccountDetails(accs);
        
        
    }
    
    
    
    static testmethod void  testNoPrimaryAccountMatchingContact(){
        //Arrange
        Account retailerAccount = TestClass_AccountCreator.CreateRetailer();
        Profile salesExecutiveProfile = [SELECT Id FROM Profile WHERE Name = 'Sales Executive' LIMIT 1];
        User portalUser = createuser(retailerAccount, salesExecutiveProfile.Id, 'test@test.test.retailer');
        
        /*
Account acc1 = buildCorporateAccountWithoutInsert('corpTest');
acc1.RecordTypeId = goldenCorporateRecordTypeId;
acc1.Is_Primary__c = true;   
insert acc1;
Contact con1 = buildContactWithoutInsert(acc1);
con1.RecordTypeId = goldencorporateContactRecordTypeId;
con1.MobilePhone = '07454512351535';

con1.FirstName = 'Robert';
con1.Email = 'asasassd@fdf.com';
con1.Email2__c = 'asadassdassd@fdf.com';
con1.LA_Opt_In__c = 'LY';
insert con1;

AccountShare ash = new AccountShare(AccountId=acc1.Id, UserOrGroupId=portalUser.id, AccountAccessLevel='edit', OpportunityAccessLevel='none', CaseAccessLevel='none');
insert ash;

List<Account> accs = new List<Account>();
*/
        //Act
        System.runAs(portalUser)
        {
            Account acc2 = buildCorporateAccountWithoutInsert('corpTest');
            acc2.RecordTypeId = corporateRecordTypeId;
            
            insert acc2;
            
            Contact con = buildContactWithoutInsert(acc2);
            con.OtherPhone = '0745451235133535';
            
            con.FirstName = 'Rob';
            insert con;
            
            
            
            
            
            
        }
        
        
        //Assert
        
        
        
    }
    
    
    
    
    
    
    
  
        
        
        private static User createuser(Account testCommAccount, Id profileId, String userUsername)
    {
        Contact testCommContact = new Contact();
        testCommContact.LastName = 'Test Name';
        testCommContact.AccountID = testCommAccount.Id;
        //testCommContact.RecordTypeId = [select Id from RecordType where SObjectType = 'Contact' and Name = 'Employee Contact' limit 1].Id;
        testCommContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Employee_Contact').getRecordTypeId();
        testCommContact.Email = 'test@test.test';
        insert testCommContact;
        User commUser = new User();
        commUser.Phone = '07681102495';
        commUser.Email = 'test123@test.test';
        commUser.ProfileId = profileId;
        commUser.UserName = userUsername;
        commUser.Alias = 'TTT';
        commUser.ContactID = testCommContact.Id;
        commUser.FirstName = 'Test';
        commUser.LastName = 'Test';
        commUser.LanguageLocaleKey = 'en_US';
        commUser.Market__c = 'Australia';
        commUser.Country_ISO_Code__c = 'AU';
        commUser.LocaleSidKey = 'en_US';
        commUser.TimeZoneSidKey = 'America/Chicago';
        commUser.EmailEncodingKey = 'UTF-8';
        User usrAdmin = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs(usrAdmin)
        {
            insert commUser;
        }
        return commUser;
    }
    
    private static Contact buildContactWithoutInsert(Account acc)
    {
        Contact contact = new Contact();
        
        if (acc != null)
        {
            contact.AccountId = acc.Id;
        }
        contact.FirstName = 'name';
        contact.LastName = 'testLastName';
        contact.Email = 'test@1email.com';
        
        return contact;
    }
    
    private static Account buildCorporateAccountWithoutInsert(String name)
    {
        Account account = new Account();
        account.RecordTypeId = AccountUtilities.RecordTypes.get('Corporate').Id;
        String chars = 'abcdefghijklmnopqrstuvwxyz123';
        account.Name = name;
        account.BillingStreet = 'Valid Street';
        account.BillingPostalCode = 'Valid PostalCode';
        account.BillingState = 'Valid State';
        account.BillingCity = 'Valid City';
        account.Retailer_Email__c = 'test@test.com';
        account.Country_ISO_Code__c = 'AU';
        account.Corporate_Code__c = '';
        for (Integer i = 0; i < 10; i++)
        {
            Integer randomNum = (Integer) (Math.random() * 26);
            account.BillingStreet += chars.substring(randomNum, randomNum + 1);
            account.BillingState += chars.substring(randomNum, randomNum + 1);
            account.BillingCity += chars.substring(randomNum, randomNum + 1);
            account.Retailer_Email__c += chars.substring(randomNum, randomNum + 1);
            if (Math.mod(i, 2) == 0) account.Corporate_Code__c += chars.substring(randomNum, randomNum + 1);
        }
        return account;
    }
    
    
}