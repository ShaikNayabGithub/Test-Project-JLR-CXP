@IsTest
public class PrimaryAccountContact_Batch_Test {
    
    private static final String corporateRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate').getRecordTypeId();
    private static final String goldenCorporateRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate_Golden_Record').getRecordTypeId();
    private static final String goldenIndividualRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual_Golden_Record').getRecordTypeId();
    private static final String goldencorporateContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('JLR_Contact').getRecordTypeId();
    
    static testmethod void  testBatchMatchesOnExistingContactWhenCorporateLinked(){
        //Arrange
        Account retailerAccount = TestClass_AccountCreator.CreateRetailer();
        Profile salesExecutiveProfile = [SELECT Id FROM Profile WHERE Name = 'Sales Executive' LIMIT 1];
        User portalUser = createuser(retailerAccount, salesExecutiveProfile.Id, 'test@test.test.retailer');
        
        
        Account acc1 = buildCorporateAccountWithoutInsert('corpTest');
        acc1.RecordTypeId = goldenCorporateRecordTypeId;
        acc1.Is_Primary__c = true;   
        insert acc1;
        Contact con1 = buildContactWithoutInsert(acc1);
        Contact con;
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
            acc2.Primary_Account__c = acc1.Id;
            insert acc2;
            
            con = buildContactWithoutInsert(acc2);
            con.OtherPhone = '0745451235133535';
            
            insert con;
            
        }
        
        Contact conAfter = new Contact();
        conAfter.Id = con.Id;
        conAfter.Primary_Account__c = null;
        conAfter.Primary_Contact__c = null;
        update conAfter;
        
        Test.startTest();
        Database.executebatch(new PrimaryAccountContact_Batch('AU'), 20);
        Test.stopTest();
        List<Contact> contactsResult = [Select id, Recordtype.name, Primary_Account__c,Primary_Contact__c from contact where Primary_Contact__c != null];
        List<Account> primaryccs = [SELECT id from account where Recordtypeid = :goldenCorporateRecordTypeId];
        
        System.assertEquals(1,contactsResult.size());
        System.assertEquals(1,primaryccs.size());
        
        
        
    }
    static testmethod void  testBatchMatchesOnExistingContactWhenCorporateNotLinkedUsingDotTrueNoEmail(){
        //Arrange
        Contact con;
        Account acc2;
        Account retailerAccount = TestClass_AccountCreator.CreateRetailer();
        Profile salesExecutiveProfile = [SELECT Id FROM Profile WHERE Name = 'Sales Executive' LIMIT 1];
        User portalUser = createuser(retailerAccount, salesExecutiveProfile.Id, 'test@test.test.retailer');
        
        
        Account acc1 = buildCorporateAccountWithoutInsert('corpTest');
        acc1.RecordTypeId = goldenCorporateRecordTypeId;
        acc1.Is_Primary__c = true;   
        insert acc1;
        Contact con1 = buildContactWithoutInsert(acc1);
        con1.Title = 'Mr';
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
            acc2 = buildCorporateAccountWithoutInsert('corpTest');
            acc2.RecordTypeId = corporateRecordTypeId;
            
            insert acc2;
            
            con = buildContactWithoutInsert(acc2);
            con.OtherPhone = '07454512351535';
            con.Title = 'Mr';
            con.FirstName = null;
            
            insert con;
            
        }
        
        Contact conAfter = new Contact();
        conAfter.Id = con.Id;
        conAfter.Primary_Account__c = null;
        conAfter.Primary_Contact__c = null;
        conAfter.LastName = '.';
        conAfter.FirstName = null;
        update conAfter;
        acc2.Primary_Account__c = null;
        update acc2;
        Test.startTest();
        //PrimaryAccountContact_Batch(string countryCode,string name, string limitNum, boolean createNewAccounts, boolean dotMatch)
        Database.executebatch(new PrimaryAccountContact_Batch('AU', '1', true), 20);
        Test.stopTest();
        List<Contact> contactsResult = [Select id, Recordtype.name, Primary_Account__c,Primary_Contact__c, AccountId, Account.Primary_Account__c from contact where Primary_Contact__c != null];
        //  //System.debug(' RESULT '+contactsResult);
        //           System.debug(' acc2 '+acc2.Id);
        //          System.debug(' acc1 '+acc1.Id);//
        
        
        
        List<Account> primaryccs = [SELECT id, name from account where Recordtypeid = :goldenCorporateRecordTypeId];
        
        System.assertEquals(1,contactsResult.size());
        System.assertEquals(1,primaryccs.size());
    }
    static testmethod void  testBatchMatchesOnExistingContactWhenCorporateNotLinkedUsingDotTrueNoFirstName(){
        //Arrange
        Contact con;
        Account acc2;
        Account retailerAccount = TestClass_AccountCreator.CreateRetailer();
        Profile salesExecutiveProfile = [SELECT Id FROM Profile WHERE Name = 'Sales Executive' LIMIT 1];
        User portalUser = createuser(retailerAccount, salesExecutiveProfile.Id, 'test@test.test.retailer');
        
        
        Account acc1 = buildCorporateAccountWithoutInsert('corpTest');
        acc1.RecordTypeId = goldenCorporateRecordTypeId;
        acc1.Is_Primary__c = true;   
        insert acc1;
        Contact con1 = buildContactWithoutInsert(acc1);
        con1.Title = null;
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
            acc2 = buildCorporateAccountWithoutInsert('corpTest');
            acc2.RecordTypeId = corporateRecordTypeId;
            
            insert acc2;
            
            con = buildContactWithoutInsert(acc2);
            con.OtherPhone = '07454512351535';
            con.Title = null;
            con.FirstName = null;
            
            insert con;
            
        }
        
        Contact conAfter = new Contact();
        conAfter.Id = con.Id;
        conAfter.Primary_Account__c = null;
        conAfter.Primary_Contact__c = null;
        conAfter.LastName = '.';
        conAfter.FirstName = null;
        update conAfter;
        acc2.Primary_Account__c = null;
        update acc2;
        Test.startTest();
        //PrimaryAccountContact_Batch(string countryCode,string name, string limitNum, boolean createNewAccounts, boolean dotMatch)
        Database.executebatch(new PrimaryAccountContact_Batch('AU', '1', true), 20);
        Test.stopTest();
        List<Contact> contactsResult = [Select id, Recordtype.name, Primary_Account__c,Primary_Contact__c, AccountId, Account.Primary_Account__c from contact where Primary_Contact__c != null];
        //  //System.debug(' RESULT '+contactsResult);
        //           //System.debug(' acc2 '+acc2.Id);
        //          //System.debug(' acc1 '+acc1.Id);//
        
        
        
        List<Account> primaryccs = [SELECT id, name from account where Recordtypeid = :goldenCorporateRecordTypeId];
        
        System.assertEquals(1,contactsResult.size());
        System.assertEquals(1,primaryccs.size());
    }
    
     static testmethod void  testBatchMatchesOnExistingContactWhenCorporateNotLinkedUsingDotTrueFirst3Name(){
        //Arrange
        Contact con;
        Account acc2;
        Account retailerAccount = TestClass_AccountCreator.CreateRetailer();
        Profile salesExecutiveProfile = [SELECT Id FROM Profile WHERE Name = 'Sales Executive' LIMIT 1];
        User portalUser = createuser(retailerAccount, salesExecutiveProfile.Id, 'test@test.test.retailer');
        
        
        Account acc1 = buildCorporateAccountWithoutInsert('corpTest');
        acc1.RecordTypeId = goldenCorporateRecordTypeId;
        acc1.Is_Primary__c = true;   
        insert acc1;
        Contact con1 = buildContactWithoutInsert(acc1);
        con1.FirstName = 'asdfgh';
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
            acc2 = buildCorporateAccountWithoutInsert('corpTest');
            acc2.RecordTypeId = corporateRecordTypeId;
            
            insert acc2;
            
            con = buildContactWithoutInsert(acc2);
            con.FirstName = 'asdgh';
            con.OtherPhone = '07454512351535';
            
            insert con;
            
        }
        
        Contact conAfter = new Contact();
        conAfter.Id = con.Id;
        conAfter.Primary_Account__c = null;
        conAfter.Primary_Contact__c = null;
        conAfter.LastName = '.';
        conAfter.FirstName = null;
        update conAfter;
        acc2.Primary_Account__c = null;
        update acc2;
        Test.startTest();
        //PrimaryAccountContact_Batch(string countryCode,string name, string limitNum, boolean createNewAccounts, boolean dotMatch)
        Database.executebatch(new PrimaryAccountContact_Batch('AU', '1', true), 20);
        Test.stopTest();
        List<Contact> contactsResult = [Select id, Recordtype.name, Primary_Account__c,Primary_Contact__c, AccountId, Account.Primary_Account__c from contact where Primary_Contact__c != null];
        //  //System.debug(' RESULT '+contactsResult);
        //           //System.debug(' acc2 '+acc2.Id);
        //          //System.debug(' acc1 '+acc1.Id);//
        
        
        
        List<Account> primaryccs = [SELECT id, name from account where Recordtypeid = :goldenCorporateRecordTypeId];
        
        System.assertEquals(1,contactsResult.size());
        System.assertEquals(1,primaryccs.size());
    }
     static testmethod void  testBatchMatchesOnExistingContactWhenCorporateNotLinkedUsingDotTrueNoFirst3Name(){
        //Arrange
        Contact con;
        Account acc2;
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
        con1.Email = 'asasassd@fdf.com';
        con1.Email2__c = 'asadassdassd@fdf.com';
        insert con1;
        
        AccountShare ash = new AccountShare(AccountId=acc1.Id, UserOrGroupId=portalUser.id, AccountAccessLevel='edit', OpportunityAccessLevel='none', CaseAccessLevel='none');
        insert ash;
        
        List<Account> accs = new List<Account>();
        
        //Act
        System.runAs(portalUser)
        {
            acc2 = buildCorporateAccountWithoutInsert('corpTest');
            acc2.RecordTypeId = corporateRecordTypeId;
            
            insert acc2;
            
            con = buildContactWithoutInsert(acc2);
            con.FirstName = 'asdgh';
            con.OtherPhone = '07454512351535';
            
            insert con;
            
        }
        
        Contact conAfter = new Contact();
        conAfter.Id = con.Id;
        conAfter.Primary_Account__c = null;
        conAfter.Primary_Contact__c = null;
      
        conAfter.FirstName = null;
        update conAfter;
        acc2.Primary_Account__c = null;
        update acc2;
        Test.startTest();
        //PrimaryAccountContact_Batch(string countryCode,string name, string limitNum, boolean createNewAccounts, boolean dotMatch)
        Database.executebatch(new PrimaryAccountContact_Batch('AU', '1', true), 20);
        Test.stopTest();
        List<Contact> contactsResult = [Select id, Recordtype.name, Primary_Account__c,Primary_Contact__c, AccountId, Account.Primary_Account__c from contact where Primary_Contact__c != null];
        //  //System.debug(' RESULT '+contactsResult);
        //           //System.debug(' acc2 '+acc2.Id);
        //          //System.debug(' acc1 '+acc1.Id);//
        
        
        
        List<Account> primaryccs = [SELECT id, name from account where Recordtypeid = :goldenCorporateRecordTypeId];
        
        System.assertEquals(1,contactsResult.size());
        System.assertEquals(1,primaryccs.size());
    }
       static testmethod void  testBatchMatchesOnExistingContactWhenCorporateLinkedUsingDotTrueNoFirstNoeEmaile(){
        //Arrange
        Contact con;
        Account acc2;
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
         con1.Email3__c = null;
        insert con1;
        
        AccountShare ash = new AccountShare(AccountId=acc1.Id, UserOrGroupId=portalUser.id, AccountAccessLevel='edit', OpportunityAccessLevel='none', CaseAccessLevel='none');
        insert ash;
        
        List<Account> accs = new List<Account>();
        
        //Act
        System.runAs(portalUser)
        {
            acc2 = buildCorporateAccountWithoutInsert('corpTest');
            acc2.RecordTypeId = corporateRecordTypeId;
            
            insert acc2;
            
            con = buildContactWithoutInsert(acc2);
            con.FirstName = 'asdgh';
            con.OtherPhone = '07454512351535';
            
            insert con;
            
        }
        
        Contact conAfter = new Contact();
        conAfter.Id = con.Id;
        
        conAfter.Primary_Contact__c = null;
      
        conAfter.FirstName = null;
        update conAfter;
        acc2.Primary_Account__c = null;
        update acc2;
        Test.startTest();
        //PrimaryAccountContact_Batch(string countryCode,string name, string limitNum, boolean createNewAccounts, boolean dotMatch)
        Database.executebatch(new PrimaryAccountContact_Batch('AU', '1', true), 20);
        Test.stopTest();
        List<Contact> contactsResult = [Select id, Recordtype.name, Primary_Account__c,Primary_Contact__c, AccountId, Account.Primary_Account__c from contact where Primary_Contact__c != null];
        //  //System.debug(' RESULT '+contactsResult);
        //           //System.debug(' acc2 '+acc2.Id);
        //          //System.debug(' acc1 '+acc1.Id);//
        
        
        
        List<Account> primaryccs = [SELECT id, name from account where Recordtypeid = :goldenCorporateRecordTypeId];
        
        System.assertEquals(1,contactsResult.size());
        System.assertEquals(1,primaryccs.size());
    }
    
     static testmethod void  testBatchMatchesOnExistingContactWhenCorporateNotLinkedUsingDotTrueNoFirstNoeEmaile(){
        //Arrange
        Contact con;
        Account acc2;
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
         con1.Email3__c = null;
        insert con1;
        
        AccountShare ash = new AccountShare(AccountId=acc1.Id, UserOrGroupId=portalUser.id, AccountAccessLevel='edit', OpportunityAccessLevel='none', CaseAccessLevel='none');
        insert ash;
        
        List<Account> accs = new List<Account>();
        
        //Act
        System.runAs(portalUser)
        {
            acc2 = buildCorporateAccountWithoutInsert('corpTest');
            acc2.RecordTypeId = corporateRecordTypeId;
            
            insert acc2;
            
            con = buildContactWithoutInsert(acc2);
            con.FirstName = 'asdgh';
            con.OtherPhone = '07454512351535';
            
            insert con;
            
        }
        
        Contact conAfter = new Contact();
        conAfter.Id = con.Id;
        conAfter.Primary_Account__c = null;
        conAfter.Primary_Contact__c = null;
      
        conAfter.FirstName = null;
        update conAfter;
        acc2.Primary_Account__c = null;
        update acc2;
        Test.startTest();
        //PrimaryAccountContact_Batch(string countryCode,string name, string limitNum, boolean createNewAccounts, boolean dotMatch)
        Database.executebatch(new PrimaryAccountContact_Batch('AU', '1', true), 20);
        Test.stopTest();
        List<Contact> contactsResult = [Select id, Recordtype.name, Primary_Account__c,Primary_Contact__c, AccountId, Account.Primary_Account__c from contact where Primary_Contact__c != null];
        //  //System.debug(' RESULT '+contactsResult);
        //           //System.debug(' acc2 '+acc2.Id);
        //          //System.debug(' acc1 '+acc1.Id);//
        
        
        
        List<Account> primaryccs = [SELECT id, name from account where Recordtypeid = :goldenCorporateRecordTypeId];
        
        System.assertEquals(1,contactsResult.size());
        System.assertEquals(1,primaryccs.size());
    }
    
   
    static testmethod void  testBatchMatchesOnExistingContactWhenCorporateNotLinkedUsingDotTrue(){
        //Arrange
        Contact con;
        Account acc2;
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
            acc2 = buildCorporateAccountWithoutInsert('corpTest');
            acc2.RecordTypeId = corporateRecordTypeId;
            
            insert acc2;
            
            con = buildContactWithoutInsert(acc2);
            con.OtherPhone = '07454512351535';
            
            insert con;
            
        }
        
        Contact conAfter = new Contact();
        conAfter.Id = con.Id;
        conAfter.Primary_Account__c = null;
        conAfter.Primary_Contact__c = null;
        conAfter.LastName = '.';
        conAfter.FirstName = null;
        update conAfter;
        acc2.Primary_Account__c = null;
        update acc2;
        Test.startTest();
        //PrimaryAccountContact_Batch(string countryCode,string name, string limitNum, boolean createNewAccounts, boolean dotMatch)
        Database.executebatch(new PrimaryAccountContact_Batch('AU', '1', true), 20);
        Test.stopTest();
        List<Contact> contactsResult = [Select id, Recordtype.name, Primary_Account__c,Primary_Contact__c, AccountId, Account.Primary_Account__c from contact where Primary_Contact__c != null];
        //  //System.debug(' RESULT '+contactsResult);
        //           //System.debug(' acc2 '+acc2.Id);
        //          //System.debug(' acc1 '+acc1.Id);//
        
        
        
        List<Account> primaryccs = [SELECT id, name from account where Recordtypeid = :goldenCorporateRecordTypeId];
        
        System.assertEquals(1,contactsResult.size());
        System.assertEquals(1,primaryccs.size());
    }
    
    
    static testmethod void  testBatchMatchesOnExistingContactWhenCorporateNotLinkedUsingSpecifiedName(){
        //Arrange
        Contact con;
        Account acc2;
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
            acc2 = buildCorporateAccountWithoutInsert('corpTest');
            acc2.RecordTypeId = corporateRecordTypeId;
            
            insert acc2;
            
            con = buildContactWithoutInsert(acc2);
            con.OtherPhone = '07454512351535';
            
            insert con;
            
        }
        
        Contact conAfter = new Contact();
        conAfter.Id = con.Id;
        conAfter.Primary_Account__c = null;
        conAfter.Primary_Contact__c = null;
        update conAfter;
        acc2.Primary_Account__c = null;
        update acc2;
        Test.startTest();
        //PrimaryAccountContact_Batch(string countryCode,string name, string limitNum, boolean createNewAccounts, boolean dotMatch)
        Database.executebatch(new PrimaryAccountContact_Batch('AU', 'name testLastName','1', false), 20);
        Test.stopTest();
        List<Contact> contactsResult = [Select id, Recordtype.name, Primary_Account__c,Primary_Contact__c, AccountId, Account.Primary_Account__c from contact where Primary_Contact__c != null];
        //  //System.debug(' RESULT '+contactsResult);
        //           //System.debug(' acc2 '+acc2.Id);
        //          //System.debug(' acc1 '+acc1.Id);//
        
        
        
        List<Account> primaryccs = [SELECT id, name from account where Recordtypeid = :goldenCorporateRecordTypeId];
        
        System.assertEquals(1,contactsResult.size());
        System.assertEquals(1,primaryccs.size());
    }
    
    static testmethod void  testBatchMatchesOnExistingContactWhenCorporateNotLinked(){
        //Arrange
        Contact con;
        Account acc2;
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
            acc2 = buildCorporateAccountWithoutInsert('corpTest');
            acc2.RecordTypeId = corporateRecordTypeId;
            
            insert acc2;
            
            con = buildContactWithoutInsert(acc2);
            con.OtherPhone = '07454512351535';
            
            insert con;
            
        }
        
        Contact conAfter = new Contact();
        conAfter.Id = con.Id;
        conAfter.Primary_Account__c = null;
        conAfter.Primary_Contact__c = null;
        update conAfter;
        acc2.Primary_Account__c = null;
        update acc2;
        Test.startTest();
        
        Database.executebatch(new PrimaryAccountContact_Batch('AU'), 20);
        Test.stopTest();
        List<Contact> contactsResult = [Select id, Recordtype.name, Primary_Account__c,Primary_Contact__c, AccountId, Account.Primary_Account__c from contact where Primary_Contact__c != null];
        // //System.debug(' RESULT '+contactsResult);
        
        
        List<Account> primaryccs = [SELECT id, name from account where Recordtypeid = :goldenCorporateRecordTypeId];
        
        
        System.assertEquals(1,contactsResult.size());
        System.assertEquals(1,primaryccs.size());
    }
    
    
    
    
    static testmethod void  testBatchCreatesNewWhenNoPrimaryCorporateNotLinked(){
        //Arrange
        Contact con;
        Account acc2;
        Account retailerAccount = TestClass_AccountCreator.CreateRetailer();
        Profile salesExecutiveProfile = [SELECT Id FROM Profile WHERE Name = 'Sales Executive' LIMIT 1];
        User portalUser = createuser(retailerAccount, salesExecutiveProfile.Id, 'test@test.test.retailer');
        
        
        
        
        List<Account> accs = new List<Account>();
        
        //Act
        System.runAs(portalUser)
        {
            acc2 = buildCorporateAccountWithoutInsert('corpTest');
            acc2.RecordTypeId = corporateRecordTypeId;
            
            insert acc2;
            
            con = buildContactWithoutInsert(acc2);
            con.OtherPhone = '0745451235133535';
            
            insert con;
            
        }
        
        Contact conAfter = new Contact();
        conAfter.Id = con.Id;
        conAfter.Primary_Account__c = null;
        conAfter.Primary_Contact__c = null;
        update conAfter;
        List<Account> accounts = [Select Id FROM Account where RecordtypeId = :goldenCorporateRecordTypeId];
        delete accounts;
        Test.startTest();
        Database.executebatch(new PrimaryAccountContact_Batch('AU', '2'), 20);
        Test.stopTest();
        List<Contact> contactsResult = [Select id, Recordtype.name, Primary_Account__c,Primary_Contact__c, AccountId, Account.Primary_Account__c from contact where Primary_Contact__c != null];
        //System.debug(' RESULT '+contactsResult);
        
        List<Account> primaryccs = [SELECT id from account where Recordtypeid = :goldenCorporateRecordTypeId];
        
        System.assertEquals(1,contactsResult.size());
        System.assertEquals(1,primaryccs.size());
        
        
    }
    
    
    static testmethod void  testBatchCreatesNewWhenNoPrimaryCorporateNotLinkedMultipleCOntacts(){
        //Arrange
        Contact con;
        Contact conOther;
        Account acc2;
        Account retailerAccount = TestClass_AccountCreator.CreateRetailer();
        Profile salesExecutiveProfile = [SELECT Id FROM Profile WHERE Name = 'Sales Executive' LIMIT 1];
        User portalUser = createuser(retailerAccount, salesExecutiveProfile.Id, 'test@test.test.retailer');
        
        
        
        
        List<Account> accs = new List<Account>();
        
        //Act
        System.runAs(portalUser)
        {
            acc2 = buildCorporateAccountWithoutInsert('corpTest');
            acc2.RecordTypeId = corporateRecordTypeId;
            
            insert acc2;
            
            con = buildContactWithoutInsert(acc2);
            con.OtherPhone = '0745451235133535';
            conOther = buildContactWithoutInsert(acc2);
            conOther.LastName = 'SomethingDiff';
            conOther.OtherPhone = '0745451235133535';
            insert con;
            insert conOther;
        }
        List<Contact> updatesContacts = new List<Contact>();  
        Contact conAfter = new Contact();
        conAfter.Id = con.Id;
        conAfter.Primary_Account__c = null;
        conAfter.Primary_Contact__c = null;
        updatesContacts.add(conAfter);
        system.debug('con'+con);
        system.debug('conOther'+conOther);
        Contact conAfter2 = new Contact();
        conAfter2.Id = conOther.Id;
        conAfter2.Primary_Account__c = null;
        conAfter2.Primary_Contact__c = null;
        updatesContacts.add(conAfter2);
        update updatesContacts;
        
        List<Account> accounts = [Select Id FROM Account where RecordtypeId = :goldenCorporateRecordTypeId];
        delete accounts;
        Test.startTest();
        Database.executebatch(new PrimaryAccountContact_Batch('AU' ), 20);
        Test.stopTest();
        List<Contact> contactsResult1 = [Select id,lastname, Recordtype.name, Primary_Account__c,Primary_Contact__c, AccountId, Account.Primary_Account__c from contact WHere account.Recordtypeid = :corporateRecordTypeId ];
        //System.debug(' Filterless '+json.serializePretty(contactsResult1));
        //System.debug(' Filterless '+contactsResult1.size());
        List<Contact> contactsResult = [Select id, Recordtype.name, Primary_Account__c,Primary_Contact__c, AccountId, Account.Primary_Account__c from contact where Primary_Contact__c != null];
        //System.debug(' RESULT '+contactsResult);
        
        List<Account> primaryccs = [SELECT id from account where Recordtypeid = :goldenCorporateRecordTypeId];
        
        System.assertEquals(2,contactsResult.size());
        System.assertEquals(1,primaryccs.size());
        
        
    }
    static testmethod void  testBatchLinksNewWhenNoPrimaryCorporateNotLinkedMultipleCOntacts(){
        //Arrange
        Contact con;
        Contact conOther;
        Account acc2;
        Account retailerAccount = TestClass_AccountCreator.CreateRetailer();
        Profile salesExecutiveProfile = [SELECT Id FROM Profile WHERE Name = 'Sales Executive' LIMIT 1];
        User portalUser = createuser(retailerAccount, salesExecutiveProfile.Id, 'test@test.test.retailer');
        
        
        
        
        List<Account> accs = new List<Account>();
        
        //Act
        System.runAs(portalUser)
        {
            acc2 = buildCorporateAccountWithoutInsert('corpTest');
            acc2.RecordTypeId = corporateRecordTypeId;
            
            insert acc2;
            
            con = buildContactWithoutInsert(acc2);
            con.OtherPhone = '0745451235133535';
            conOther = buildContactWithoutInsert(acc2);
            conOther.LastName = 'SomethingDiff';
            conOther.OtherPhone = '0745451235133535';
            insert con;
            insert conOther;
        }
        List<Contact> updatesContacts = new List<Contact>();  
        Contact conAfter = new Contact();
        conAfter.Id = con.Id;
        conAfter.Primary_Account__c = null;
        conAfter.Primary_Contact__c = null;
        updatesContacts.add(conAfter);
        system.debug('con'+con);
        system.debug('conOther'+conOther);
        Contact conAfter2 = new Contact();
        conAfter2.Id = conOther.Id;
        conAfter2.Primary_Account__c = null;
        conAfter2.Primary_Contact__c = null;
        updatesContacts.add(conAfter2);
        update updatesContacts;
        Test.startTest();
        Database.executebatch(new PrimaryAccountContact_Batch('AU' ), 20);
        Test.stopTest();
        List<Contact> contactsResult1 = [Select id,lastname, Recordtype.name, Primary_Account__c,Primary_Contact__c, AccountId, Account.Primary_Account__c from contact WHere account.Recordtypeid = :corporateRecordTypeId ];
       // //System.debug(' Filterless '+json.serializePretty(contactsResult1));
       // //System.debug(' Filterless '+contactsResult1.size());
        List<Contact> contactsResult = [Select id, Recordtype.name, Primary_Account__c,Primary_Contact__c, AccountId, Account.Primary_Account__c from contact where Primary_Contact__c != null];
      //  //System.debug(' RESULT '+contactsResult);
        
        List<Account> primaryccs = [SELECT id from account where Recordtypeid = :goldenCorporateRecordTypeId];
        
        System.assertEquals(2,contactsResult.size());
        System.assertEquals(1,primaryccs.size());
        
        
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