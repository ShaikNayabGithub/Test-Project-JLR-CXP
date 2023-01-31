@isTest
public class VerifyContactDataBatchTest {
    private static final String individualRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();
    
    @testSetup
    static void createData() {
        Lead le = new Lead();
        le.Email = 'test123@test.com';
        le.FirstName = 'First';
        le.LastName = 'Last';
        insert le;
        
        et4ae5__SendDefinition__c sd = new et4ae5__SendDefinition__c();
        insert sd;
        
        et4ae5__IndividualEmailResult__c ier = new et4ae5__IndividualEmailResult__c();
        ier.et4ae5__SendDefinition__c = sd.Id;
        ier.et4ae5__Lead__c = le.Id;
        ier.et4ae5__Opened__c = true;
        ier.et4ae5__DateOpened__c = System.now() - 1;
        insert ier;
        
        et4ae5__IndividualEmailResult__c ier2 = new et4ae5__IndividualEmailResult__c();
        ier2.et4ae5__SendDefinition__c = sd.Id;
        ier2.et4ae5__Lead__c = le.Id;
        ier2.et4ae5__Opened__c = true;
        ier2.et4ae5__DateOpened__c = System.now();
        insert ier2;
        
        Account retailer1 = new Account();
        retailer1.RecordTypeId = AccountUtilities.RecordTypes.get('Individual').Id;
        retailer1.LastName = 'test';
        retailer1.FirstName = 'Valid Firstname';
        retailer1.PersonMailingStreet = 'Valid Street';
        retailer1.PersonMailingPostalCode = 'Valid PostalCode';
        retailer1.PersonMailingState = 'Valid State 2';
        retailer1.PersonMailingCity = 'Valid City';        
        retailer1.PersonEmail = 'test123@test.com';        
        retailer1.Email2__pc = 'test123@test.com';        
        retailer1.Email3__pc = 'test123@test.com';
        retailer1.PersonMobilePhone = '7654321890';    
        retailer1.Country_ISO_Code__c = 'IN';
        insert retailer1; 
    }
    
    @isTest
    static void testMethod1() {
        Test.startTest();
        	Database.executeBatch(new VerifyContactDataBatch(), 10);
        Test.stopTest();
    }
}