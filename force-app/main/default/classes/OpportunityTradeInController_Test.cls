@isTest
public class OpportunityTradeInController_Test {
    public static Id modelRecordType = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByDeveloperName().get('Model').getRecordTypeId();
    public static Id makeRecordType = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByDeveloperName().get('Make').getRecordTypeId();
 
    static testmethod void makeFromModel(){
        Vehicle_specification__c makeVehicle =new Vehicle_specification__c (Name='Land Rover', recordtypeId = makeRecordType);
        insert makeVehicle;
        Vehicle_specification__c modelVehicle =new Vehicle_specification__c (Name='F-Type', recordtypeId = modelRecordType, make__c =makeVehicle.Id,Is_Currently_Sold__c= true);
        insert modelVehicle;
        
        String retrievedId;
        Test.startTest();
            retrievedId = OpportunityTradeInController.getMakeFromModel(modelVehicle.Id);
        Test.stopTest();
       System.assertEquals(makeVehicle.Id, retrievedId);
    }
    
    static testmethod void preFilledData() {
        Opportunity currentOp = new Opportunity();
        currentOp = TestClass_OpportunityCreator.generateOpportunity();
        
        OpportunityTradeValues result = new OpportunityTradeValues();
        Test.startTest();
        result = OpportunityTradeInController.getPredoneData(currentOp.Id);
        Test.stopTest();
        System.assertNotEquals(null, result);
    }
    
    static testmethod void updateOpp() {
        Opportunity currentOp = new Opportunity();
        currentOp = TestClass_OpportunityCreator.generateOpportunity();
        Opportunity newOp = new Opportunity();
        Test.startTest();
	        OpportunityTradeInController.updateOpportunityTrade(currentOp.Id, 57, null, null, null, null, null, '2007', true, true);
        Test.stopTest();  
        newOp = [SELECT Id, Model_Year__c FROM Opportunity WHERE Id = :currentOp.Id];
        System.assertEquals('2007', newOp.Model_Year__c);
    }

    static testmethod void getAssetFromVin() {
        Account retailer = TestClass_AccountCreator.CreateRetailer();
        retailer.Country_iso_code__c = 'AU';
        update retailer;
              system.debug('retailer.Country_iso_code__c MICHAEL '+retailer.Country_iso_code__c);
        //set account to au
        string assetId = TestClass_AssetBuilder.generateAsset(retailer.Id);
        system.debug('assetId '+assetId);
        Asset currentAsset = new Asset();
        currentAsset = [SELECT Id, Vin__c, Brand__c, model__r.productCode FROM Asset WHERE Id = :assetId];
        
        Product2 derivative = [SELECT Id, productCode FROM Product2 WHERE ID = :currentAsset.Model__c];
        derivative.productCode = 'TEST';
        update derivative;
        system.debug('derivative.productCode '+derivative.productCode);
        
        
 //here set the details of the model vehicle spec so it matches search criteria of method, you may need to update the asset model related to asset to get coverage of line 26+
        Vehicle_specification__c modelVehicle =new Vehicle_specification__c (Name='F-Type', recordtypeId = modelRecordType, make__c =currentAsset.Brand__c,Is_Currently_Sold__c= true);
        modelVehicle.Model_Code__c = derivative.productCode;
        insert modelVehicle;
        
        system.debug('currentAsset '+currentAsset);
        OppTradeInVinResult result;
    	Test.startTest();
            result = OpportunityTradeInController.getVehicleFromVin(currentAsset.VIN__c);
    	Test.stopTest();
        OppTradeInVinResult createdForTestCoverage = new OppTradeInVinResult(result.vehicleId, result.modelId, result.makeId, result.modelYear);
     system.debug('result '+result);
     system.debug('result.makeId '+result.makeId);
     system.debug('currentAsset.Brand__c '+currentAsset.Brand__c);
       	System.assertEquals(currentAsset.Brand__c, result.makeId);
    }
    
}