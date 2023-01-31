@isTest(SeeAllData=false)
public class Batch_MenaFinanceContractInsert_Test {
    public static testmethod void testContract() {
        Account personAccount = TestClass_AccountCreator.createPersonAccount();
        personAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();
        personAccount.Owner_Retailer__c = '1234567';
        personAccount.Country_ISO_Code__c='AE';
        personAccount.Country_ISO_Code__pc='AE';
        personAccount.Is_Primary__c = false;
        update personAccount;
        
        Asset newAsset = TestClass_AssetBuilder.BuildVehicle();
        newAsset.Vehicle_Initial_Registration_Date__c = system.today()-4;
        newAsset.AccountId=personAccount.Id;
        newAsset.Handover_Date__c = system.today()-1;
        newAsset.VIN__c = '11AABB';
        insert newAsset;
        
        Finance_Contract_Import__c newFinContract = new Finance_Contract_Import__c(APR__c=29.0, VIN__c='11AABB', Market__c='JO', FS_Product_Name__c='Financial Leasing', Term_Tenor__c=06);
        insert newFinContract;
        
        Test.startTest();
        
        Database.executeBatch(new Batch_MenaFinanceContractInsert(), 200);
        
        Test.stopTest();
    }
}