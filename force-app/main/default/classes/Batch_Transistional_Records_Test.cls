@IsTest
public class Batch_Transistional_Records_Test {
    private static final String retailerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Retailer').getRecordTypeId();
    private static final String corporateRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate').getRecordTypeId();
    private static final String individualRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();
    
    private static final String goldenCorporateRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate_Golden_Record').getRecordTypeId();
    private static final String goldenIndividualRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual_Golden_Record').getRecordTypeId();
    private static final String goldencorporateContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('JLR_Contact').getRecordTypeId();
    
    @isTest
    public static void testAccountGetsCorpCreatedWhenAssociatedToRetailerJustOneTrans(){
        //ARRANGE
        Account ret = [SELECT id FROM Account WHERE Recordtypeid = :retailerRecordTypeId limit 1];
        Transitional_Record__c tranRec = new Transitional_Record__c();
        
        tranRec.Surname_Field_1__c = 'Pacman';
        tranRec.Current_Asset_Account__c = ret.id;
       
        tranRec.Company_Name__c = 'enterprise';
        tranRec.Country_Code__c  = 'SA';
        tranRec.Email_Address_1__c  = 'joe.Pacman@bob.com';
        tranRec.First_Name__c  = 'Joe';
        tranRec.Gender__c  = 'Male';
        tranRec.Manufacturer__c  = 'Jaguar';
        tranRec.Status__c  = 'New';
        tranRec.Title__c  = 'Master';
        tranRec.Mobile_Telephone_Number__c = '07548441542';
        tranRec.Business_Telephone_Number__c = '07528441542';
        tranRec.Home_Telephone_Number__c = '07548441242';
        insert tranRec;
        Transitional_Record__c trans = [SELECT Id, Name FROM Transitional_Record__c WHERE Id = :tranRec.Id ];  
        //ACT
        Test.startTest();//(string limitInput, string name)
        Database.executebatch(new Batch_Transitional_Records('2',trans.Name), 20);
        Test.stopTest();
        //ASSERT
     Transitional_Record__c transResult = [SELECT Id, Name, New_Created_Account__c FROM Transitional_Record__c WHERE Id = :tranRec.Id ]; 
        System.assert( transResult.New_Created_Account__c != null );
        
    }     
    
    @isTest
    public static void testAccountGetsCorpCreatedWhenAssociatedToRetailer(){
        //ARRANGE
        Account ret = [SELECT id FROM Account WHERE Recordtypeid = :retailerRecordTypeId limit 1];
        Transitional_Record__c tranRec = new Transitional_Record__c();
        
        tranRec.Surname_Field_1__c = 'Pacman';
        tranRec.Current_Asset_Account__c = ret.id;
        tranRec.Company_Name__c = 'enterprise';
        tranRec.Country_Code__c  = 'SA';
        tranRec.Email_Address_1__c  = 'joe.Pacman@bob.com';
        tranRec.First_Name__c  = 'Joe';
        tranRec.Gender__c  = 'Male';
        tranRec.Manufacturer__c  = 'Jaguar';
        tranRec.Status__c  = 'New';
        tranRec.Title__c  = 'Master';
        tranRec.Mobile_Telephone_Number__c = '07548441542';
        insert tranRec;
        //ACT
        Test.startTest();
        Database.executebatch(new Batch_Transitional_Records('2'), 20);
        Test.stopTest();
        //ASSERT
       Transitional_Record__c transResult = [SELECT Id, Name, New_Created_Account__c FROM Transitional_Record__c WHERE Id = :tranRec.Id ]; 
        System.assert( transResult.New_Created_Account__c != null );  
        
    } 
    @isTest
    public static void testAccountGetsIndCreatedWhenAssociatedToRetailer(){
        //ARRANGE
        Account ret = [SELECT id FROM Account WHERE Recordtypeid = :retailerRecordTypeId limit 1];
        Transitional_Record__c tranRec = new Transitional_Record__c();
        
        tranRec.Surname_Field_1__c = 'Pacman';
        tranRec.Current_Asset_Account__c = ret.id;
        tranRec.Company_Name__c = null;
        tranRec.Country_Code__c  = 'SA';
        tranRec.Email_Address_1__c  = 'joe.Pacman@bob.com';
        tranRec.First_Name__c  = 'Joe';
        tranRec.Gender__c  = 'Male';
        tranRec.Manufacturer__c  = 'Jaguar';
        tranRec.Status__c  = 'New';
        tranRec.Title__c  = 'Master';
        tranRec.Mobile_Telephone_Number__c = '07548441542';
        insert tranRec;
        //ACT
        Test.startTest();
        Database.executebatch(new Batch_Transitional_Records('2'), 20);
        Test.stopTest();
        //ASSERT
        Transitional_Record__c trnResult= [Select Status__c, Matched_Existing_Account__c, New_Created_Account__c, Matched_Existing_Account__r.name, New_Created_Account__r.name From Transitional_Record__c Where id = :tranRec.id];
        
        system.assert(trnResult.New_Created_Account__c != null);
        
        
    }
    
    @isTest
    public static void testIndAccountGetsDetectedWhenAssociatedToRetailer(){
        //ARRANGE
        Account ret = [SELECT id FROM Account WHERE Recordtypeid = :retailerRecordTypeId limit 1];
        User usr = [Select Id from User where name like '%DummyIMPORTER%' limit 1];
        Account person = new Account();
        person.LastName = 'Pacman';
        person.FirstName = 'Joe';
        person.PersonMobilePhone = '07548441542';
        person.PersonOtherPhone = '07548441542';
        person.country_iso_code__c = 'SA';
        person.recordtypeid = individualRecordTypeId;
        System.runAs(usr)
        {
            insert person;
        }
        Transitional_Record__c tranRec = new Transitional_Record__c();
        
        tranRec.Surname_Field_1__c = 'Pacman';
        tranRec.Current_Asset_Account__c = ret.id;
        tranRec.Company_Name__c = 'enterprise';
        tranRec.Country_Code__c  = 'SA';
        tranRec.Email_Address_1__c  = 'joe.Pacman@bob.com';
        tranRec.First_Name__c  = 'Joe';
        tranRec.Gender__c  = 'Male';
        tranRec.Manufacturer__c  = 'Jaguar';
        tranRec.Status__c  = 'New';
        tranRec.Title__c  = 'Master';
        tranRec.Mobile_Telephone_Number__c = '07548441542';
        insert tranRec;
        //ACT
        Test.startTest();
        Database.executebatch(new Batch_Transitional_Records('2'), 20);
        Test.stopTest();
        //ASSERT
        List<Account> createdAccounts = [SELECT id from Account where Name = 'enterprise'];
        Transitional_Record__c trnResult= [Select Status__c, Matched_Existing_Account__c, New_Created_Account__c, Matched_Existing_Account__r.name, New_Created_Account__r.name From Transitional_Record__c Where id = :tranRec.id];
        system.debug('trnResult '+trnResult.Status__c);
        system.debug('trnResult '+ json.serializePretty(trnResult));
        System.assertEquals(0, createdAccounts.size());  
        
    }
     @isTest
    public static void testIndWithPhoneIsoAccountGetsDetectedWhenAssociatedToRetailer(){
        //ARRANGE
        Account ret = [SELECT id FROM Account WHERE Recordtypeid = :retailerRecordTypeId limit 1];
        User usr = [Select Id from User where name like '%DummyIMPORTER%' limit 1];
        Account person = new Account();
        person.LastName = 'Pacman';
        person.FirstName = 'Joe';
        person.PersonMobilePhone = '027548441542';
        person.PersonOtherPhone = '66607548441542';
        person.country_iso_code__c = 'SA';
        person.recordtypeid = individualRecordTypeId;
        System.runAs(usr)
        {
            insert person;
        }
        Transitional_Record__c tranRec = new Transitional_Record__c();
        
        tranRec.Surname_Field_1__c = 'Pacman';
        tranRec.Current_Asset_Account__c = ret.id;
        tranRec.Company_Name__c = 'enterprise';
        tranRec.Country_Code__c  = 'SA';
        tranRec.Email_Address_1__c  = 'joe.Pacman@bob.com';
        tranRec.First_Name__c  = 'Joe';
        tranRec.Gender__c  = 'Male';
        tranRec.Manufacturer__c  = 'Jaguar';
        tranRec.Status__c  = 'New';
        tranRec.Title__c  = 'Master';
        tranRec.Mobile_Telephone_Number__c = '07548441542';
        insert tranRec;
        //ACT
        Test.startTest();
        Database.executebatch(new Batch_Transitional_Records('2'), 20);
        Test.stopTest();
        //ASSERT
        List<Account> createdAccounts = [SELECT id from Account where Name = 'enterprise'];
        Transitional_Record__c trnResult= [Select Status__c, Matched_Existing_Account__c, New_Created_Account__c, Matched_Existing_Account__r.name, New_Created_Account__r.name From Transitional_Record__c Where id = :tranRec.id];
        system.debug('trnResult '+trnResult.Status__c);
        system.debug('trnResult '+ json.serializePretty(trnResult));
        System.assertEquals(0, createdAccounts.size());  
        
    }
    @isTest
    public static void testCorpAccountGetsDetectedWhenAssociatedToRetailer(){
        //ARRANGE
        Account ret = [SELECT id FROM Account WHERE Recordtypeid = :retailerRecordTypeId limit 1];
        User usr = [Select Id from User where name like '%DummyIMPORTER%' limit 1];
        Account comp = new Account();
        comp.Name = 'enterprise';
        comp.Phone = '07548441542';
        comp.country_iso_code__c = 'SA';
        comp.recordtypeid = corporateRecordTypeId;
        System.runAs(usr)
        {
            insert comp;
        }
        Contact con = new Contact();
        con.FirstName = 'Joe';
        con.LastName = 'Pacman';
        con.email = 'notPacman@gmail.com';
        con.MobilePhone = '07548441542';
        con.AccountId = comp.Id;
        System.runAs(usr)
        {
            insert con;
        }
        Transitional_Record__c tranRec = new Transitional_Record__c();
        
        tranRec.Surname_Field_1__c = 'Pacman';
        tranRec.Current_Asset_Account__c = ret.id;
        tranRec.Company_Name__c = 'enterprise';
        tranRec.Country_Code__c  = 'SA';
        tranRec.Email_Address_1__c  = 'joe.Pacman@bob.com';
        tranRec.First_Name__c  = 'Joe';
        tranRec.Gender__c  = 'Male';
        tranRec.Manufacturer__c  = 'Jaguar';
        tranRec.Status__c  = 'New';
        tranRec.Title__c  = 'Master';
        tranRec.Mobile_Telephone_Number__c = '07548441542';
        insert tranRec;
        //ACT
        Test.startTest();
        Database.executebatch(new Batch_Transitional_Records('2'), 20);
        Test.stopTest();
        //ASSERT
        List<Account> createdAccounts = [SELECT id from Account where Name = 'enterprise'];
        Transitional_Record__c trnResult= [Select Status__c, Matched_Existing_Account__c, New_Created_Account__c, Matched_Existing_Account__r.name, New_Created_Account__r.name From Transitional_Record__c Where id = :tranRec.id];
        system.debug('trnResult '+trnResult.Status__c);
        system.debug('trnResult '+ json.serializePretty(trnResult));
        System.assert(trnResult.Matched_Existing_Account__c != null);  
        
    }
    @isTest
    public static void testIndAccountGetsUpdatedWhenAssociatedToCustomer(){
        //ARRANGE
        Account ret = [SELECT id FROM Account WHERE Recordtypeid = :retailerRecordTypeId limit 1];
        User usr = [Select Id from User where name like '%DummyIMPORTER%' limit 1];
        Account person = new Account();
        person.LastName = 'Pacman';
        person.FirstName = 'Joe';
        person.PersonMobilePhone = '07548441542';
        person.PersonOtherPhone = '07548441542';
        person.country_iso_code__c = 'SA';
        person.recordtypeid = individualRecordTypeId;
        System.runAs(usr)
        {
            insert person;
        }
        Transitional_Record__c tranRec = new Transitional_Record__c();
        
        tranRec.Surname_Field_1__c = 'Pacman';
        tranRec.Current_Asset_Account__c = person.id;
        tranRec.Company_Name__c = 'enterprise';
        tranRec.Country_Code__c  = 'SA';
        tranRec.Email_Address_1__c  = 'joe.Pacman@bob.com';
        tranRec.First_Name__c  = 'Joe';
        tranRec.Gender__c  = 'Male';
        tranRec.Manufacturer__c  = 'Jaguar';
        tranRec.Status__c  = 'New';
        tranRec.Title__c  = 'Master';
        tranRec.Mobile_Telephone_Number__c = '07548441542';
        insert tranRec;
        //ACT
        Test.startTest();
        Database.executebatch(new Batch_Transitional_Records('2'), 20);
        Test.stopTest();
        //ASSERT
        
        Transitional_Record__c trnResult= [Select Status__c, Matched_Existing_Account__c, New_Created_Account__c, Matched_Existing_Account__r.name, New_Created_Account__r.name From Transitional_Record__c Where id = :tranRec.id];
        system.debug('trnResult '+trnResult.Status__c);
        system.debug('trnResult '+ json.serializePretty(trnResult));
        System.assertEquals('Name Matched Email Updated', trnResult.Status__c);  
        
    }
    
     @isTest
    public static void testCorpAccountGetsUpdatedWhenAssociatedToCustomer(){
        //ARRANGE
        Account ret = [SELECT id FROM Account WHERE Recordtypeid = :retailerRecordTypeId limit 1];
        User usr = [Select Id from User where name like '%DummyIMPORTER%' limit 1];
        Account comp = new Account();
        comp.Name = 'enterprise';
        comp.Phone = '07548441542';
        comp.country_iso_code__c = 'SA';
        comp.recordtypeid = corporateRecordTypeId;
        System.runAs(usr)
        {
            insert comp;
        }
        Contact con = new Contact();
        con.FirstName = 'Joe';
        con.LastName = 'Pacman';
        con.email = 'notPacman@gmail.com';
        con.MobilePhone = '07548441542';
        con.AccountId = comp.Id;
        System.runAs(usr)
        {
            insert con;
        }
        Transitional_Record__c tranRec = new Transitional_Record__c();
        
        tranRec.Surname_Field_1__c = 'Pacman';
        tranRec.Current_Asset_Account__c = comp.id;
        tranRec.Company_Name__c = 'enterprise';
        tranRec.Country_Code__c  = 'SA';
        tranRec.Email_Address_1__c  = 'joe.Pacman@bob.com';
        tranRec.First_Name__c  = 'Joe';
        tranRec.Gender__c  = 'Male';
        tranRec.Manufacturer__c  = 'Jaguar';
        tranRec.Status__c  = 'New';
        tranRec.Title__c  = 'Master';
        tranRec.Mobile_Telephone_Number__c = '07548441542';
        insert tranRec;
        //ACT
        Test.startTest();
        Database.executebatch(new Batch_Transitional_Records('2'), 20);
        Test.stopTest();
        //ASSERT
        
        Transitional_Record__c trnResult= [Select Status__c, Matched_Existing_Account__c, New_Created_Account__c, Matched_Existing_Account__r.name, New_Created_Account__r.name From Transitional_Record__c Where id = :tranRec.id];
        system.debug('trnResult '+trnResult.Status__c);
        system.debug('trnResult '+ json.serializePretty(trnResult));
        System.assertEquals('Name Matched Email Updated', trnResult.Status__c);  
        
    }
    
    @testSetup static void setup(){
        aop_NationalityToISOCode__c apco = new aop_NationalityToISOCode__c();
        apco.aop_ISO_Code__c = 'SA';
        apco.Dialing_Code__c = '666';
        apco.Name = 'Saudi Arabia';
        apco.aop_Checkfront_Instance__c = 'abc.com';
        insert apco;
        
        Account retailerAccount = TestClass_AccountCreator.CreateRetailer();
        retailerAccount.Retailer_Type__c = 'Importer';
         retailerAccount.country_iso_code__c = 'SA';
        update retailerAccount;
     
        Profile salesExecutiveProfile = [SELECT Id FROM Profile WHERE Name = 'Sales Executive' LIMIT 1];
        User portalUser = createuser(retailerAccount, salesExecutiveProfile.Id, 'tsest@teast.teast.retailer');
    }
    
    
    private static User createuser(Account testCommAccount, Id profileId, String userUsername)
    {
        Contact testCommContact = new Contact();
        testCommContact.LastName = 'DummyIMPORTER';
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
        commUser.LastName = 'DummyIMPORTER';
        commUser.LanguageLocaleKey = 'en_US';
        commUser.Market__c = 'MENA';
        commUser.Country_ISO_Code__c = 'SA';
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
}