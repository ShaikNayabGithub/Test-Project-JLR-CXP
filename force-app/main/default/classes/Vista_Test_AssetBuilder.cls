@isTest
public class Vista_Test_AssetBuilder {
    /*
    static testMethod void createBasicAsset_ReturnsAssetWithVINMatchingRecordGroupVIN()
    {
        Vista_RecordGroup recGroup = new Vista_RecordGroup();
        recGroup.VistaVehicleOrder = new Vista_OrderService.VehicleOrder();
        recGroup.VistaVehicleOrder.MetaOrderNumber = 'ORNUM';
        recGroup.VistaVehicleOrder.Vehicle = new Vista_OrderService.Vehicle();
        recGroup.VistaVehicleOrder.Specification = new Vista_OrderService.Specification();
        recGroup.VistaVehicleOrder.Specification.DescriptionGroupId = 'descgroupid';
        recGroup.VistaVehicleOrder.Vehicle.VIN = 'TESTVIN';
        recGroup.VistaVehicleOrder.Vehicle.ChassisNumber = 'chasnum';
        recGroup.VistaVehicleOrder.Misc  = new  Vista_OrderService.Misc();
        recGroup.VistaVehicleOrder.Misc.CommonStatusPoint = 'status';
        Account testAcc = new Account(Name = 'newAcc');
        insert testAcc;
        
        Vista_AssetBuilder assetBuilder = new Vista_AssetBuilder();
        Asset result = assetBuilder.createBasicAsset(recGroup, testAcc.Id, null, null);
        
        system.assertEquals('TESTVIN', result.VIN__c);
        
    }
    
    static testMethod void addAssetFeatures_PutsValueInColourField_IfMappingExists()
    {
        Vista_RecordGroup recGroup = new Vista_RecordGroup();
        recGroup.VistaVehicleOrder = new Vista_OrderService.VehicleOrder();
        recGroup.VistaVehicleOrder.Specification = new Vista_OrderService.Specification();
        List<Vista_OrderService.Feature> featureList = new List<Vista_OrderService.Feature>();
        Vista_OrderService.Feature newFeature = new Vista_OrderService.Feature();
        newFeature.FeatureCode = 'code';
        newFeature.FeatureType = 'PCOL';
        featureList.add(newFeature);
        recGroup.VistaVehicleOrder.Specification.Features = featureList;
        BRS_FeatureGroupFieldMappingByCode__c fieldNameMapping = new BRS_FeatureGroupFieldMappingByCode__c();
        fieldNameMapping.Field_Name__c = 'Colour';
        fieldNameMapping.Name = 'PCOL';
        Asset newAsset = new Asset();
        
        insert fieldNameMapping;
        
        Vista_AssetBuilder assetBuilder = new Vista_AssetBuilder();
        Asset result = assetBuilder.addAssetFeatures(newAsset, recGroup);
        
        system.assertEquals('code', result.Colour__c);
    }
    
    static testMethod void updateAssetDetailsFromRequest_UpdatesChassisNumber()
    {
        Vista_RecordGroup recGroup = new Vista_RecordGroup();
        recGroup.VistaVehicleOrder = new Vista_OrderService.VehicleOrder();
        recGroup.VistaVehicleOrder.MetaOrderNumber = 'ORNUM';
        recGroup.VistaVehicleOrder.Vehicle = new Vista_OrderService.Vehicle();
        recGroup.VistaVehicleOrder.Specification = new Vista_OrderService.Specification();
        recGroup.VistaVehicleOrder.Specification.DescriptionGroupId = 'descgroupid';
        recGroup.VistaVehicleOrder.Vehicle.VIN = 'TESTVIN';
        recGroup.VistaVehicleOrder.Vehicle.ChassisNumber = 'chasnum';
        recGroup.VistaVehicleOrder.Misc  = new  Vista_OrderService.Misc();
        recGroup.VistaVehicleOrder.Misc.CommonStatusPoint = 'status';
        Account testAcc = new Account(Name = 'newAcc');
        insert testAcc;
        List<RecordType> recType = [SELECT Id FROM RecordType WHERE sObjectType = 'Vehicle_Specification__c' AND DeveloperName = 'Make'];
        Vehicle_Specification__c vehSpec = new Vehicle_Specification__c(name = 'brand', RecordTypeId = recType[0].Id);
        insert vehSpec;
        Asset newAsset = new Asset(Name =  'assetName', AccountId = testAcc.Id, Brand__c = vehSpec.Id);
        insert newAsset;
        
        Vista_AssetBuilder assetBuilder = new Vista_AssetBuilder();
        Asset result = assetBuilder.updateAssetDetailsFromRequest(newAsset, recGroup, null);
        
        system.assertEquals('chasnum', result.Chassis_Number__c);
    }
    
    static testMethod void BuildHandoverAsset_UpdatesHannndoverDate_IfDateSupplied()
    {
        Vista_RecordGroup recGroup = new Vista_RecordGroup();
        recGroup.VistaVehicleOrder = new Vista_OrderService.VehicleOrder();
        recGroup.VistaVehicleOrder.Registration = new Vista_OrderService.Registration();
        recGroup.VistaVehicleOrder.Customer = new  Vista_OrderService.Customer();
        recGroup.VistaVehicleOrder.Registration.RegistrationNo = 'newReg';
        recGroup.VistaVehicleOrder.Customer.CustomerHandoverDate = '2016-01-02';
        
        Asset newAsset = new Asset();
        Vista_AssetBuilder assetBuilder = new Vista_AssetBuilder();
        
        Asset result = assetBuilder.buildHandoverAsset(newAsset, recGroup, null);
        Date expected = Date.newInstance(2016, 01, 02);
        
        system.assertEquals(expected, result.Handover_Date__c);
    }
    
    static testMethod void addAssetFeaturesFromDerivative_CopiesEngineValue_OntoAsset()
    {
        Product2 newProduct = new Product2(Body_Style__c = 'bsytle', Engine__c = 'eng', 
                                         	Wheel_Base__c = 'wbase', Wheel_Driven__c =  'wheeldrive',
                                         	Transmission__c = 'transmish');
        Asset blankAsset = new Asset();
        
        Vista_AssetBuilder assetBuilder = new Vista_AssetBuilder();
        Asset result = assetBuilder.addAssetFeaturesFromDerivative(blankAsset, newProduct);
        
        system.assertEquals('eng', result.Engine__c);
    }
    
    static testMethod void addAssetFeaturesFromDerivative_DoesntUpdateColour_IfColourPrePopulated()
    {
        Product2 newProduct = new Product2(Body_Style__c = 'bsytle', Engine__c = 'eng', 
                                         	Wheel_Base__c = 'wbase', Wheel_Driven__c =  'wheeldrive',
                                         	Transmission__c = 'transmish',
                                          	Exterior_Colour__c = 'newcol');
        Asset blankAsset = new Asset(Colour__c = 'PCOL');
        
        Vista_AssetBuilder assetBuilder = new Vista_AssetBuilder();
        Asset result = assetBuilder.addAssetFeaturesFromDerivative(blankAsset, newProduct);
        
        system.assertEquals('PCOL', result.Colour__c);
    }*/
}