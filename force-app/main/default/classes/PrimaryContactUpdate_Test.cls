@IsTest(SeeAllData=false)
public class PrimaryContactUpdate_Test {
    
    private static final String corporateRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate').getRecordTypeId();
    private static final String goldenCorporateRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate_Golden_Record').getRecordTypeId();
    private static final String goldenIndividualRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual_Golden_Record').getRecordTypeId();
    private static final String goldencorporateContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('JLR_Contact').getRecordTypeId();
    
    
    static testmethod void  testContactAddsMissingPhoneToPrimary(){
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
        insert con1;
        
        AccountShare ash = new AccountShare(AccountId=acc1.Id, UserOrGroupId=portalUser.id, AccountAccessLevel='edit', OpportunityAccessLevel='none', CaseAccessLevel='none');
        insert ash;
        
        
        //Act
        ///System.runAs(portalUser)
        ///{
            Account acc2 = buildCorporateAccountWithoutInsert('corpTest');
            acc2.RecordTypeId = corporateRecordTypeId;
            acc2.Primary_Account__c = acc1.Id;
            insert acc2;
            Contact con = buildContactWithoutInsert(acc2);
        system.debug('contact 1 id is ' + con.AccountId);
        	system.debug('contact id is ' + con.AccountId);
             con.Phone = '07454512351531';
             con.MobilePhone = '07454512351532';
             con.OtherPhone = '07454512351539';
            insert con;
            
            
            
       /// }
        
        
        //Assert
        List<Contact> contacts = [SELECT Id, Phone , MobilePhone,OtherPhone  FROM Contact where Phone != null];
              System.debug('Contacts TEST'+json.serializePretty(contacts));
        System.assert(contacts.size() == 2);
    }
    
    
     static testmethod void  testContactAddsMissingPhoneToPrimaryLastFiled(){
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
        con1.Phone = '074545121351535';
             con1.MobilePhone = '074514512351535';
         
         
         insert con1;
        
        AccountShare ash = new AccountShare(AccountId=acc1.Id, UserOrGroupId=portalUser.id, AccountAccessLevel='edit', OpportunityAccessLevel='none', CaseAccessLevel='none');
        insert ash;
        
        
        //Act
        System.runAs(portalUser)
        {
            Account acc2 = buildCorporateAccountWithoutInsert('corpTest');
            acc2.RecordTypeId = corporateRecordTypeId;
            acc2.Primary_Account__c = acc1.Id;
            insert acc2;
            Contact con = buildContactWithoutInsert(acc2);
             con.Phone = '0745451235133535';
           
            insert con;
            
            
            
        }
        
        
        //Assert
        List<Contact> contacts = [SELECT Id, Phone , MobilePhone,OtherPhone  FROM Contact where Phone != null];
              System.debug('Contacts TEST'+json.serializePretty(contacts));
        System.assert(contacts.size() == 2);
    }
    
    
    static testmethod void  testContactAddsMissingPhoneToPrimaryOtherPhone(){
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
        con1.Phone = '074545121351535';
             con1.MobilePhone = '074514512351535';
          con1.LA_Opt_In__c = 'LY';
         
         insert con1;
        
        AccountShare ash = new AccountShare(AccountId=acc1.Id, UserOrGroupId=portalUser.id, AccountAccessLevel='edit', OpportunityAccessLevel='none', CaseAccessLevel='none');
        insert ash;
        
        
        //Act
        System.runAs(portalUser)
        {
            Account acc2 = buildCorporateAccountWithoutInsert('corpTest');
            acc2.RecordTypeId = corporateRecordTypeId;
            acc2.Primary_Account__c = acc1.Id;
            insert acc2;
            Contact con = buildContactWithoutInsert(acc2);
             con.OtherPhone = '0745451235133535';
           con.LA_Opt_In__c = 'LN';
         
            insert con;
            
            
            
        }
        
        
        //Assert
        List<Contact> contacts = [SELECT Id, Phone , MobilePhone,OtherPhone  FROM Contact where Phone != null];
              System.debug('Contacts TEST'+json.serializePretty(contacts));
        System.assert(contacts.size() == 1);
    }
    
        static testmethod void  testContactAddsMissingPhoneToPrimaryMobilePhone(){
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
        con1.Phone = '074545121351535';
             con1.MobilePhone = '074514512351535';
         con1.LA_Opt_In__c = 'JY';
         
         insert con1;
        
        AccountShare ash = new AccountShare(AccountId=acc1.Id, UserOrGroupId=portalUser.id, AccountAccessLevel='edit', OpportunityAccessLevel='none', CaseAccessLevel='none');
        insert ash;
        
        
        //Act
        System.runAs(portalUser)
        {
            Account acc2 = buildCorporateAccountWithoutInsert('corpTest');
            acc2.RecordTypeId = corporateRecordTypeId;
            acc2.Primary_Account__c = acc1.Id;
            insert acc2;
            Contact con = buildContactWithoutInsert(acc2);
             con.MobilePhone = '0745451235133535';
              con.LA_Opt_In__c = 'JN';

            insert con;
            
            
            
        }
        
        
        //Assert
        List<Contact> contacts = [SELECT Id, Phone , MobilePhone,OtherPhone  FROM Contact where Phone != null];
              System.debug('Contacts TEST'+json.serializePretty(contacts));
        System.assert(contacts.size() == 1);
    }
    
    
    
    static testmethod void  testContactAddsMissingEmailToPrimary(){
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
        insert con1;
        
        AccountShare ash = new AccountShare(AccountId=acc1.Id, UserOrGroupId=portalUser.id, AccountAccessLevel='edit', OpportunityAccessLevel='none', CaseAccessLevel='none');
        insert ash;
        
        
        //Act
        System.runAs(portalUser)
        {
            Account acc2 = buildCorporateAccountWithoutInsert('corpTest');
            acc2.RecordTypeId = corporateRecordTypeId;
            acc2.Primary_Account__c = acc1.Id;
            insert acc2;
            Contact con = buildContactWithoutInsert(acc2);
            con.Phone = '07454512351535';
             con.Email = 'asasassd@fdf.com';
             con.Email2__c = 'asadassdassd@fdf.com';
              con.Email3__c = 'asasfsd@fdf.com';
            insert con;
            
            
            
        }
        
        
        //Assert
        List<Contact> contacts = [SELECT Id, phone, email, Email2__c, Email3__c FROM Contact where Phone != null];
        System.debug('EMAIL         Contacts TEST '+json.serializePretty(contacts));
        System.assert(contacts.size() == 2);
    }
    
       static testmethod void  testContactAddsMissingEmail1ToPrimary(){
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
        
        
        //Act
        System.runAs(portalUser)
        {
            Account acc2 = buildCorporateAccountWithoutInsert('corpTest');
            acc2.RecordTypeId = corporateRecordTypeId;
            acc2.Primary_Account__c = acc1.Id;
            insert acc2;
            Contact con = buildContactWithoutInsert(acc2);
            con.Phone = '07454512351535';
             con.Email = 'asasassd@fdf.com';
             con.Email3__c  = 'asassafsd@fdf.com';
           
            insert con;
            
            
            
        }
        
        
        //Assert
        List<Contact> contacts = [SELECT Id, phone, email, Email2__c, Email3__c FROM Contact where Phone != null];
        System.debug('EMAIL         Contacts TEST '+json.serializePretty(contacts));
        System.assert(contacts.size() == 2);
    }
      static testmethod void  testContactAddsMissingEmail3ToPrimary(){
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
        
        
        //Act
        System.runAs(portalUser)
        {
            Account acc2 = buildCorporateAccountWithoutInsert('corpTest');
            acc2.RecordTypeId = corporateRecordTypeId;
            acc2.Primary_Account__c = acc1.Id;
            insert acc2;
            Contact con = buildContactWithoutInsert(acc2);
            con.Phone = '07454512351535';
             con.Email  = 'asasfsd@fdf.com';
           
            insert con;
            
            
            
        }
        
        
        //Assert
        List<Contact> contacts = [SELECT Id, phone, email, Email2__c, Email3__c FROM Contact where Phone != null];
        System.debug('EMAIL         Contacts TEST '+json.serializePretty(contacts));
        System.assert(contacts.size() == 2);
    }
    
    
    
    static testmethod void  testContactDoesNotAddSamePhoneToPrimary(){
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
           con1.Phone = '07454512351535';
        con1.Email = null;
        insert con1;
        
        AccountShare ash = new AccountShare(AccountId=acc1.Id, UserOrGroupId=portalUser.id, AccountAccessLevel='edit', OpportunityAccessLevel='none', CaseAccessLevel='none');
        insert ash;
        
        
        //Act
        System.runAs(portalUser)
        {
            Account acc2 = buildCorporateAccountWithoutInsert('corpTest');
            acc2.RecordTypeId = corporateRecordTypeId;
            acc2.Primary_Account__c = acc1.Id;
            insert acc2;
            Contact con = buildContactWithoutInsert(acc2);
            con.Phone = '07454512351535';
            con.Email = 'test@1email.com';
            insert con;
            
            
            
        }
        
        
        //Assert
        List<Contact> contacts = [SELECT Id FROM Contact where Email != null];
           System.debug('Contacts '+json.serializePretty(contacts));
        System.assert(contacts.size() == 3);
    }
    
    static testmethod void  testContactDoesNotAddSameEmailToPrimary(){
        //Arrange
        //Act
        //Assert
    }
    
    
    
    /*
@testSetup static void testBehavior()
{
// ARRANGE
Account retailerAccount = TestClass_AccountCreator.CreateRetailer();
Profile salesExecutiveProfile = [SELECT Id FROM Profile WHERE Name = 'Sales Executive' LIMIT 1];
User portalUser = createuser(retailerAccount, salesExecutiveProfile.Id, 'test@test.test.retailer');


Account acc1 = buildCorporateAccountWithoutInsert('corpTest');
acc1.RecordTypeId = goldenCorporateRecordTypeId;
acc1.Is_Primary__c = true;   
insert acc1;
Contact con1 = buildContactWithoutInsert(acc1);
con1.RecordTypeId = goldencorporateContactRecordTypeId;
insert con1;

AccountShare ash = new AccountShare(AccountId=acc1.Id, UserOrGroupId=portalUser.id, AccountAccessLevel='edit', OpportunityAccessLevel='none', CaseAccessLevel='none');
insert ash;



System.runAs(portalUser)
{
Account acc2 = buildCorporateAccountWithoutInsert('corpTest');
acc2.RecordTypeId = corporateRecordTypeId;
acc2.Primary_Account__c = acc1.Id;
insert acc2;
Contact con = buildContactWithoutInsert(acc2);
insert con;



}



} */
    
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
        contact.LastName = 'testLastName123';
        contact.Email = 'test@1456email.com';
        
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