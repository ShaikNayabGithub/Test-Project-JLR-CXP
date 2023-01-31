/**
 * Created by Ethan Sargent on 5/5/20.
 * JP Modified 27/05
 * Note - Have got it creating the primary automatically, and in prepord the functionality for creating the primary contact & Primary account is working
 * However if this is deployed before the other work is, you will need to create the link between the primary account and secondary account manually (i believe both will be created but won't be linked)
 * you will also need to manually create the primary contact against the primary account.

 * 
 */

@IsTest
private class AccountContactMergeController_BatchTest
{
    private static final String corporateRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate').getRecordTypeId();
    private static final String goldenCorporateRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate_Golden_Record').getRecordTypeId();
    private static final String goldenIndividualRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual_Golden_Record').getRecordTypeId();
      private static final String goldencorporateContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('JLR_Contact').getRecordTypeId();

    @IsTest
    static void testBehavior()
    {
        // ARRANGE
        Account retailerAccount = TestClass_AccountCreator.CreateRetailer();
        Profile salesExecutiveProfile = [SELECT Id FROM Profile WHERE Name = 'Sales Executive' LIMIT 1];
        User portalUser = createuser(retailerAccount, salesExecutiveProfile.Id, 'test@test.test.retailer');

       
        Account acc1 = buildCorporateAccountWithoutInsert('.');
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
            Account acc2 = buildCorporateAccountWithoutInsert('.');
            acc2.RecordTypeId = corporateRecordTypeId;
            acc2.Primary_Account__c = acc1.Id;
            insert acc2;
            Contact con = buildContactWithoutInsert(acc2);
            insert con;

            // TODO - acc2 not being created with golden Corporate RecordTypeId, is inserted as corporate RecordTypeId
            acc2 = [SELECT Id, RecordType.name,Country_Iso_code__c, Primary_Account__c FROM Account WHERE Id = :acc2.Id];
            System.debug('acc2 : ' + JSON.serializePretty(acc2));
            System.debug('acc2 RecordTypeId: ' + acc2.RecordType.Name);
            System.debug('acc2 Primary_Account__c: ' + acc2.Primary_Account__c);
            System.debug('Corporate Golden RecordType ID: ' + goldenCorporateRecordTypeId);
            System.debug('Corporate RecordType ID: ' + corporateRecordTypeId);
            List<Account> all = [SELECT Id, RecordType.name,Country_Iso_code__c, Primary_Account__c FROM Account];
            system.debug('#################################');
            system.debug('all ' + JSON.serializePretty(all));
            system.debug('#################################');

        }
        
        

        System.debug('CONTACTS IN DB: ' + [SELECT COUNT() FROM Contact]);

        System.assertEquals(2, [SELECT COUNT() FROM Account WHERE Name = '.']);
        // ACT
        Test.startTest();
        System.assertEquals(1, [SELECT COUNT() FROM Account WHERE RecordTypeId = :goldenCorporateRecordTypeId]);
        AccountContactMergeController_Batch batchJob = new AccountContactMergeController_Batch();
        Id batchId = Database.executeBatch(batchJob);
        Test.stopTest();

        // ASSERT
        System.assertEquals(0, batchJob.failureIds.size());
        System.assertEquals(2, [SELECT COUNT() FROM Account WHERE IsPersonAccount = TRUE]);
        System.assertEquals(1, [SELECT COUNT() FROM Account WHERE IsPersonAccount = TRUE AND RecordTypeId = :goldenIndividualRecordTypeId]);
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
        contact.LastName = 'testLastName';
        contact.Email = 'test@email.com';

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