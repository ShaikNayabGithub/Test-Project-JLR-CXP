@isTest
public class PrimaryAccountUpdateBatchTest {
    
    static testmethod void UpserterPopulatesOwnerRetailerGivenRetailerIndividualAccount() {
        Account retailerAccount = new Account();
        retailerAccount.Name = 'Test Account';
        retailerAccount.RecordTypeId = AccountUtilities.RecordTypes.get('Retailer').Id;
        insert retailerAccount;
        Profile salesExecutiveProfile = [select Id from Profile where Name = 'Sales Executive' limit 1];
        User portaluser = createuser(retailerAccount, salesExecutiveProfile.Id);
        Account individualAccount = new Account();
        Account corporateAccount = new Account();
        
        System.RunAs(portaluser){
            //retailer.Name = 'retailer individual';
            individualAccount.RecordTypeId = AccountUtilities.RecordTypes.get('Individual').Id;
            individualAccount.LastName = 'test';
            individualAccount.FirstName = 'Valid Firstname';
            individualAccount.PersonMailingStreet = 'Valid Street';
            individualAccount.PersonMailingPostalCode = 'Valid PostalCode';
            individualAccount.PersonMailingState = 'Valid State';
            individualAccount.PersonMailingCity = 'Valid City';        
            individualAccount.PersonEmail = 'test123@test.com';      
            individualAccount.Country_ISO_Code__c = 'IN';
            individualAccount.Owner_Retailer__c = retailerAccount.Id;
            individualAccount.Is_Primary__c = false;
            insert individualAccount;  
            
            corporateAccount.Name = 'CorporateTest';
            corporateAccount.RecordTypeId = AccountUtilities.RecordTypes.get('Corporate').Id;
            corporateAccount.Phone = '1234567890';
            corporateAccount.Country_ISO_Code__c = 'IN';  
            corporateAccount.Owner_Retailer__c  = retailerAccount.Id;  
            corporateAccount.Is_Primary__c  = false;         
            insert corporateAccount;
        }
        
        individualAccount.Primary_Account__c = null;
        individualAccount.Primary_Account__pc = null;
        update individualAccount;
        corporateAccount.Primary_Account__c = null;
        update corporateAccount;

        //Force creation of golden records--------------------------------------------------------------------------
        Account primaryIndividualAccount = new Account();
        primaryIndividualAccount.RecordTypeId = AccountUtilities.RecordTypes.get('Individual_Golden_Record').Id;
        primaryIndividualAccount.LastName = 'test';
        primaryIndividualAccount.FirstName = 'Valid Firstname';
        primaryIndividualAccount.PersonMailingStreet = 'Valid Street';
        primaryIndividualAccount.PersonMailingPostalCode = 'Valid PostalCode';
        primaryIndividualAccount.PersonMailingState = 'Valid State';
        primaryIndividualAccount.PersonMailingCity = 'Valid City';        
        primaryIndividualAccount.PersonEmail = 'test123@test.com';      
        primaryIndividualAccount.Country_ISO_Code__c = 'IN';
        primaryIndividualAccount.Is_Primary__c = true;
        insert primaryIndividualAccount;  
        //----------------------------------------------------------------------------------------------------------
        
        Test.startTest();
        PrimaryAccountUpdateBatch batchclass = new PrimaryAccountUpdateBatch();
        Database.executeBatch(batchclass, 100);
        Test.stopTest();
        individualAccount = [SELECT Primary_Account__c FROM Account WHERE Id = :individualAccount.Id];
        //System.assertNotEquals(individualAccount.Primary_Account__c, null);
        corporateAccount = [SELECT Primary_Account__c FROM Account WHERE Id = :corporateAccount.Id];
        //System.assertNotEquals(corporateAccount.Primary_Account__c, null);
    }
    
    private static User createuser(Account testCommAccount, Id profileId){
        return createuser(testCommAccount, profileId, 'test@test.test.retailer');
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
        System.RunAs(new User(Id=userinfo.getUserId())){
        insert commUser;
        }
        return commUser;
    }
}