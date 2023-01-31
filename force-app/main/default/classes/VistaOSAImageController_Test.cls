@isTest
public class VistaOSAImageController_Test {
    
    @isTest public static void getcurrentRecordDataTest(){
        Test.setMock(HttpCalloutMock.class, new VistaOSAImageControllerMock(true));
        Asset assetIns = TestClass_AssetBuilder.BuildAndInsertVehicle();
        assetIns.Order_Number__c = 'Order123456';
        assetIns.VIN__c = 'Vin123456';
        update assetIns;
        Test.startTest();
        VistaOSAImageController.getcurrentRecordData(assetIns.Id,'https://vehicleimage.jlrext.com','https://vehicleimage.jlrext.com');
        Test.stopTest();
    }
    
    @isTest public static void getcurrentRecordDataTestInvalid(){
        Test.setMock(HttpCalloutMock.class, new VistaOSAImageControllerMock(false));
        Asset assetIns = TestClass_AssetBuilder.BuildAndInsertVehicle();
        assetIns.Order_Number__c = 'Order123456';
        assetIns.VIN__c = 'Vin123456';
        update assetIns;
        Test.startTest();
        VistaOSAImageController.getcurrentRecordData(assetIns.Id,'https://vehicleimage.jlrext.com','https://vehicleimage.jlrext.com');
        Test.stopTest();
    }
    
    @isTest public static void getcurrentRecordDataTestNullVal(){
        Test.startTest();
        VistaOSAImageController.getcurrentRecordData(null,null,null);
        Test.stopTest();
    }
    @isTest public static void getcurrentRecordDataTestNewAsset(){
        Test.startTest();
        Asset assetIns = TestClass_AssetBuilder.BuildAndInsertVehicle();
        VistaOSAImageController.getcurrentRecordData(assetIns.Id,'https://vehicleimage.jlrext.com','https://vehicleimage.jlrext.com');
        Test.stopTest();
    }
}