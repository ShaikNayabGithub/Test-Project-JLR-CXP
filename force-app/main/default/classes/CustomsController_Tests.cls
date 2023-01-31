@isTest
public with sharing class CustomsController_Tests {
    
    @isTest 
    public static void Test_getAssets() {
        Test.startTest();
        List<Asset> output = CustomsController.getAssets();
        Test.stopTest();

        Assert.isNotNull(output);
    }

    @isTest 
    public static void Test_submitCustoms() {
        
        Boolean buildForPersonAccount = false;
        Asset myAsset = TestClass_AssetBuilder.BuildAndInsertVehicle(buildForPersonAccount);
        String assetData = '[{"Id": "' + myAsset.Id + '", "Name": "updatedName"}]';

        Test.startTest();
        String output = CustomsController.submitCustoms(assetData);
        Test.stopTest();

        Assert.isNotNull(output);
    }

    @isTest 
    public static void Test_getPdiRequests() {
        Test.startTest();
        List<PDI_Request__c> output = CustomsController.getPdiRequests();
        Test.stopTest();

        Assert.isNotNull(output);
    }

    @isTest 
    public static void Test_submitPdi() {
        
        Boolean buildForPersonAccount = false;
        Asset myAsset = TestClass_AssetBuilder.BuildAndInsertVehicle(buildForPersonAccount);
        myAsset.Arrival_Date__c = System.today();
        myAsset.Customs_Clearance_Status__c = 'Clearance Completed';
        update myAsset;
        PDI_Request__c pdiReq = TestClass_PdiRequestBuilder.buildAndInsertPdiRequest(myAsset.Id);

        String pdiData = '[{"Id": "' + pdiReq.Id + '", "PDI_Status__c": "Approved"}]';

        Test.startTest();
        String output = CustomsController.submitPdi(pdiData);
        Test.stopTest();

        Assert.isNotNull(output);
    }

    @isTest 
    public static void Test_getUserPermissions() {
        Test.startTest();
        String output = CustomsController.getUserPermissions();
        Test.stopTest();

        Assert.isNotNull(output);
    }
}