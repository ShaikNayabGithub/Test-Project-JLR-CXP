@IsTest
public with sharing class ProcessExtendedWarrantyBatchRecordsTest {
    @isTest
    public static void testWarrantyTransactions(){
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
        newAsset.Handover_Date__c = system.today()-83;
        newAsset.VIN__c = '11AABB';
        insert newAsset;
        
        Extended_Warranty_Staging__c staging = new Extended_Warranty_Staging__c(Policy_Number__c = '1234',
                                                                                Code__c = '1234',
                                                                               VIN__c = newAsset.Id);

        insert staging;
        
        
        test.startTest();
            Database.executeBatch(new ProcessExtendedWarrantyBatchRecords());
        test.stopTest();

    }
 
}