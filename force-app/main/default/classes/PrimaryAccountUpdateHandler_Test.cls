@isTest
public class PrimaryAccountUpdateHandler_Test {
    
    @isTest
    public static void TestCorporateAccount(){
        Account primaryAccIns = TestCorporateAccount('Corporate',null);
        Account accIns = TestCorporateAccount('Corporate',primaryAccIns.Id);
        Test.startTest();
        accIns.Name = 'Test Corporate NAME';
        update accIns;
        Test.stopTest();
    }
    
    @isTest
    public static void TestIndividualAccount(){
        Account primaryAccIns = TestIndividualAccount('Individual',null);
        Account accIns = TestIndividualAccount('Individual',primaryAccIns.Id);
        Test.startTest();
        accIns.FirstName = 'Test F NAME';
        accIns.LastName = 'Test L NAME';
        update accIns;
        Test.stopTest();
    }
    
    public static Account TestCorporateAccount(String recordTypeName,Id primaryAccount){
        Account account = new Account();
        account.RecordTypeId = AccountUtilities.RecordTypes.get(recordTypeName).Id;
        String chars = 'abcdefghijklmnopqrstuvwxyz123';
        account.Name = '';
        account.Primary_Account__c = primaryAccount;
        account.BillingStreet = 'Valid Street';
        account.BillingPostalCode = 'Valid PostalCode';
        account.BillingState = 'Valid State';
        account.BillingCity = 'Valid City';
        account.Retailer_Email__c = 'test@test.com';
        account.Country_ISO_Code__c = 'AU';
        account.Corporate_Code__c = '';
        for (Integer i = 0; i < 10; i++) {
            Integer randomNum = (Integer) (Math.random() * 26);
            account.Name += chars.substring(randomNum, randomNum + 1);
            account.BillingStreet += chars.substring(randomNum, randomNum + 1);
            account.BillingState += chars.substring(randomNum, randomNum + 1);
            account.BillingCity += chars.substring(randomNum, randomNum + 1);
            account.Retailer_Email__c += chars.substring(randomNum, randomNum + 1);
            if (Math.Mod(i, 2) == 0) account.Corporate_Code__c += chars.substring(randomNum, randomNum + 1);
        }
        insert account;
        return Account;
    }
    
    public static Account TestIndividualAccount(String recordTypeName,Id primaryAccount){
        Account account = new Account();
        account.RecordTypeId = AccountUtilities.RecordTypes.get(recordTypeName).Id;
        String chars = 'abcdefghijklmnopqrstuvwxyz123';
        account.Primary_Account__c = primaryAccount;
        account.BillingStreet = 'Valid Street';
        account.BillingPostalCode = 'Valid PostalCode';
        account.BillingState = 'Valid State';
        account.BillingCity = 'Valid City';
        account.Retailer_Email__c = 'test@test.com';
        account.Country_ISO_Code__c = 'AU';
        account.Corporate_Code__c = '';
        for (Integer i = 0; i < 10; i++) {
            Integer randomNum = (Integer) (Math.random() * 26);
            account.firstName += chars.substring(randomNum, randomNum + 1);
            account.PersonEmail = 'testdev12345'+chars.substring(randomNum, randomNum + 1)+'@testcxp.dev12345';
            account.LastName += chars.substring(randomNum, randomNum + 2);
            account.BillingStreet += chars.substring(randomNum, randomNum + 1);
            account.BillingState += chars.substring(randomNum, randomNum + 1);
            account.BillingCity += chars.substring(randomNum, randomNum + 1);
            account.Retailer_Email__c += chars.substring(randomNum, randomNum + 1);
            if (Math.Mod(i, 2) == 0) account.Corporate_Code__c += chars.substring(randomNum, randomNum + 1);
        }
        insert account;
        return Account;
    }
}