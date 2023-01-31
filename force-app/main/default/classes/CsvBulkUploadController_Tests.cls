@isTest
public with sharing class CsvBulkUploadController_Tests {
    
    @isTest 
    public static void Test_Import_Insert() {
        String recordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Accessories').getRecordTypeId();
        
        
        String jsonConfigObject = '{"objectApiName": "Product2", "operation": "insert", "updateKey": "Id"}';
        String jsonRecordData = '[{"Name": "MyNewAccessory", "RecordTypeId": "' + recordTypeId + '"}]';
        Test.startTest();
        CsvBulkUploadController.importCsv(jsonRecordData, jsonConfigObject);
        Test.stopTest();

        List<Product2> newProducts = [SELECT Id FROM Product2 WHERE Name = 'MyNewAccessory'];
        Assert.areEqual(1, newProducts.size());
    }

    @isTest 
    public static void Test_Import_Update() {
        String recordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('Accessories').getRecordTypeId();
        Product2 myAccessory = new Product2();
        myAccessory.RecordTypeId = recordTypeId;
        myAccessory.Name = 'MyNewAccessory';
        insert myAccessory;
        
        String jsonConfigObject = '{"objectApiName": "Product2", "operation": "update", "updateKey": "Id"}';
        String jsonRecordData = '[{"Id": "' +  myAccessory.Id + '", "Name": "myUpdatedAccessory"}]'; 
        
        Test.startTest();
        CsvBulkUploadController.importCsv(jsonRecordData, jsonConfigObject);
        Test.stopTest();

        List<Product2> newProducts = [SELECT Id FROM Product2 WHERE Name = 'MyNewAccessory'];
        Assert.areEqual(0, newProducts.size());

        List<Product2> updatedProducts = [SELECT Id FROM Product2 WHERE Name = 'myUpdatedAccessory'];
        Assert.areEqual(1, updatedProducts.size());
    }

    @isTest 
    public static void Test_Import_Upsert() {
        Account secondaryIndvidiual = TestClass_AccountCreator.createPersonAccount();
        secondaryIndvidiual.External_ID_SF__c = 'CsvBulkUploadController_Tests.externalId';
        update secondaryIndvidiual;

        String jsonConfigObject = '{"objectApiName": "Account", "operation": "upsert", "updateKey": "External_ID_SF__c"}';
        String jsonRecordData = '[{"External_ID_SF__c": "CsvBulkUploadController_Tests.externalId", "LastName": "myUpsertedAccount"}]'; 
        
        Test.startTest();
        CsvBulkUploadController.importCsv(jsonRecordData, jsonConfigObject);
        Test.stopTest();

        List<Account> upsertedAccounts = [SELECT Id FROM Account WHERE LastName = 'myUpsertedAccount'];
        Assert.areEqual(1, upsertedAccounts.size());

    }
}