@isTest
public class OpportunityAccountUpdateBatchTest {
    
    static testmethod void TestOpportunityAccountUpdateBatch() {
        
        Test.startTest();
        Opportunity opp = [select id,accountId,Primary_Account__c,account.recordtypeId,account.country_ISO_code__c, account.is_Primary__c from opportunity];
        system.debug(opp);
        account acc = [Select id, Is_Primary__c, RecordTypeId,country_ISO_code__c FROM Account where id = :opp.AccountId];
        system.debug(acc);
        system.debug('%%%%%%%%%%%%%%%%%%%');
        Database.executebatch(new OpportunityAccountUpdateBatch(), 1);
        Test.stopTest();
    }
    
    
    @testSetup static void setup() {
        Account retailerAccount = new Account();
        retailerAccount.Name = 'Test Account';
        retailerAccount.RecordTypeId = AccountUtilities.RecordTypes.get('Retailer').Id;
        insert retailerAccount;
        Profile salesExecutiveProfile = [select Id from Profile where Name = 'Sales Executive' limit 1];
        // Test.startTest();
        User portaluser = createuser(retailerAccount, salesExecutiveProfile.Id,'test@test.test.retailer');
        //Test.stopTest();
        // system.runAs(portaluser){
        Vehicle_Specification__c vehicleSpec1 = new Vehicle_Specification__c();
        vehicleSpec1.RecordType = [SELECT Id FROM RecordType WHERE Name = 'Make' AND SobjectType = 'Vehicle_Specification__c' LIMIT 1];
        vehicleSpec1.Name = 'Jaguar';
        insert vehicleSpec1;
        TriggerFramework__c  tf= new TriggerFramework__c();
        tf.SetupOwnerId = userinfo.getUserId();
        tf.Account_PreInsert__c = false;
        tf.Account_PreUpdate__c = false;
        tf.Account_PostInsert__c = false;
        tf.Account_PostUpdate__c = false;
        upsert tf;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'test';
        opp.StageName = 'Contacted';
        Account testAccount = new Account();
        testAccount.Name = 'Test Account Name';
        testAccount.OwnerId = portaluser.Id;  
        testAccount.Country_ISO_Code__c = 'AU';
        testAccount.RecordType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Corporate_Golden_Record' AND SobjectType = 'Account' LIMIT 1];
        // testAccount.PersonEmail = 'test@test.test';
        testAccount.Customer_Journey_Stage__c = 'Take Ownership';
        testAccount.Is_Primary__c = true;
        insert testAccount;
        opp.AccountId = testAccount.Id;
        opp.Brand__c = vehicleSpec1.Id;
        opp.ownerId = portaluser.Id;
        opp.Country_ISO_Code__c = 'AU';
        opp.CloseDate = Date.parse('12/12/2016');
        insert opp;
        
        
        
        // }
        // return opp;
    }
    private static User createuser(Account testCommAccount,Id profileId,String userUsername)
    {
        Contact testCommContact = new Contact();
        testCommContact.LastName = 'Test Name';
        testCommContact.AccountID = testCommAccount.Id;
        //testCommContact.RecordTypeId = [select Id from RecordType where SObjectType = 'Contact' and Name = 'Employee Contact' limit 1].Id;
        testCommContact.RecordTypeId =  Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Employee_Contact').getRecordTypeId();
        testCommContact.Email = 'test123@test.test';
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
        commUser.LocaleSidKey = 'en_US';
        commUser.TimeZoneSidKey = 'America/Chicago';
        commUser.EmailEncodingKey = 'UTF-8';
        commUser.Market__c = 'AU';
        System.RunAs(new User(Id=userinfo.getUserId())){  
            insert commUser;
        }
        return commUser;
    }
    
}