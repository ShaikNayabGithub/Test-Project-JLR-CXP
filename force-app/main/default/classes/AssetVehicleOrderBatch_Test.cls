@isTest 
public class AssetVehicleOrderBatch_Test {
    
    @isTest static void TestAssetVehicle(){
        Test.setMock(HttpCalloutMock.class, new AssetVehicleOrderApiMockController(200,200,'ValidOrder'));
        Product2 derivative = TestClass_AssetBuilder.buildDerivative();
        derivative.ProductCode = '5000529105';
        update derivative;
        
        Asset assetIns = TestClass_AssetBuilder.BuildAndInsertVehicle();
        assetIns.Order_Number__c = 'Order123456';
        assetIns.VIN__c = 'Vin123456';
        assetIns.Product2Id = derivative.Id;
        update assetIns;
        
        Vista_API_Asset_Align_Record__c vehOrder =  new Vista_API_Asset_Align_Record__c();
        vehOrder.Order_Number__c = 'Order123456';
        vehOrder.Status__c = 'Un Processed';
        insert vehOrder;
        
        Test.startTest();
        database.executeBatch(new AssetVehicleOrderBatch(),1);
        Test.stopTest();
    }
    
    @isTest static void TestAssetVehicleTokenBadRequest(){
        Test.setMock(HttpCalloutMock.class, new AssetVehicleOrderApiMockController(200,400,'ValidOrder'));
        Product2 derivative = TestClass_AssetBuilder.buildDerivative();
        derivative.ProductCode = '5000529105';
        update derivative;
        
        Asset assetIns = TestClass_AssetBuilder.BuildAndInsertVehicle();
        assetIns.Order_Number__c = 'Order123456';
        assetIns.VIN__c = 'Vin123456';
        assetIns.Product2Id = derivative.Id;
        update assetIns;
        
        Vista_API_Asset_Align_Record__c vehOrder =  new Vista_API_Asset_Align_Record__c();
        vehOrder.Order_Number__c = 'Order123456';
        vehOrder.Status__c = 'Un Processed';
        insert vehOrder;
        
        Test.startTest();
        database.executeBatch(new AssetVehicleOrderBatch(),1);
        Test.stopTest();
    }
}