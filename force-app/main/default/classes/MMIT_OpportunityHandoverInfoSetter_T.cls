@isTest
public class MMIT_OpportunityHandoverInfoSetter_T {
	static testmethod void SetVehicleInfo_DoesNothing_GivenEmptyOpportunityList()
    {
    	MMIT_OpportunityHandoverInfoSetter handoverInfoSetter = new MMIT_OpportunityHandoverInfoSetter();

    	Opportunity opportunity1 = TestClass_ValidOpportunityBuilder.buildOpportunityWithCorporateAccount();
    	insert opportunity1;
    	OpportunityLineItem opportunityLineItem1 = TestClass_OppLineItemCreator.CreateOppLineItem(opportunity1.Id, null, null);

    	Asset asset1 = new Asset(Order__r = new Order(OpportunityId = opportunity1.Id));
    	List<Asset> assets = new List<Asset>{ asset1 };

    	Map<String, List<Asset>> assetsByOpportunityId = new Map<String, List<Asset>> {
    			opportunity1.Id => assets };
    	List<OpportunityLineItem> opportunityLineItems = new List<OpportunityLineItem> { opportunityLineItem1 };
    	List<Opportunity> opportunities = new List<Opportunity>();


    	handoverInfoSetter.SetVehicleInfo(assetsByOpportunityId, opportunityLineItems, opportunities);


    	System.assert(true);
    }

    static testmethod void SetVehicleInfo_DoesNothing_GivenEmptyAssetAndLineItemLists()
    {
    	MMIT_OpportunityHandoverInfoSetter handoverInfoSetter = new MMIT_OpportunityHandoverInfoSetter();

    	Opportunity opportunity1 = TestClass_ValidOpportunityBuilder.buildOpportunityWithCorporateAccount();
    	insert opportunity1;

    	List<Asset> assets = new List<Asset>{ };

    	Map<String, List<Asset>> assetsByOpportunityId = new Map<String, List<Asset>> { };
    	List<OpportunityLineItem> opportunityLineItems = new List<OpportunityLineItem> { };
    	List<Opportunity> opportunities = new List<Opportunity> { opportunity1 };


    	handoverInfoSetter.SetVehicleInfo(assetsByOpportunityId, opportunityLineItems, opportunities);


    	System.assert(true);
    }

    static testmethod void SetVehicleInfo_SetsBrandToAsset1Brand_GivenAssetAndLineItemsWithDifferentBrands()
    {
    	MMIT_OpportunityHandoverInfoSetter handoverInfoSetter = new MMIT_OpportunityHandoverInfoSetter();

    	Vehicle_Specification__c brand1 = TestClass_VehicleSpecificationBuilder.BuildMake();
    	Vehicle_Specification__c brand2 = TestClass_VehicleSpecificationBuilder.BuildMake();

    	
    	OpportunityLineItem opportunityLineItem1 = TestClass_OppLineItemCreator.CreateOppLineItem();
    	insert opportunityLineItem1;
    	opportunityLineItem1.Brand__c = brand2.Id;
    	Opportunity opportunity1 = new Opportunity(Id = opportunityLineItem1.OpportunityId,
    			StageName = 'Handover');

    	Asset asset1 = new Asset(Order__r = new Order(OpportunityId = opportunity1.Id),
    			Brand__c = brand1.Id);
    	List<Asset> assets = new List<Asset>{ asset1 };

    	Map<String, List<Asset>> assetsByOpportunityId = new Map<String, List<Asset>> { 
    			opportunity1.Id => assets };
    	List<OpportunityLineItem> opportunityLineItems = new List<OpportunityLineItem> { opportunityLineItem1 };
    	List<Opportunity> opportunities = new List<Opportunity> { opportunity1 };


    	handoverInfoSetter.SetVehicleInfo(assetsByOpportunityId, opportunityLineItems, opportunities);


    	System.assertEquals(brand1.Id, opportunity1.Handover_Brand__c);
    }

    static testmethod void SetVehicleInfo_SetsBrandToLineItem1Brand_GivenLineItemWithBrandAndNoAsset()
    {
    	MMIT_OpportunityHandoverInfoSetter handoverInfoSetter = new MMIT_OpportunityHandoverInfoSetter();

    	Vehicle_Specification__c brand1 = TestClass_VehicleSpecificationBuilder.BuildMake();
    	Vehicle_Specification__c brand2 = TestClass_VehicleSpecificationBuilder.BuildMake();

    	
    	OpportunityLineItem opportunityLineItem1 = TestClass_OppLineItemCreator.CreateOppLineItem();
    	insert opportunityLineItem1;
    	opportunityLineItem1.Brand__c = brand2.Id;
    	Opportunity opportunity1 = new Opportunity(Id = opportunityLineItem1.OpportunityId,
    			StageName = 'Handover');

    	List<Asset> assets = new List<Asset>{ };

    	Map<String, List<Asset>> assetsByOpportunityId = new Map<String, List<Asset>> { };
    	List<OpportunityLineItem> opportunityLineItems = new List<OpportunityLineItem> { opportunityLineItem1 };
    	List<Opportunity> opportunities = new List<Opportunity> { opportunity1 };


    	handoverInfoSetter.SetVehicleInfo(assetsByOpportunityId, opportunityLineItems, opportunities);


    	System.assertEquals(brand2.Id, opportunity1.Handover_Brand__c);
    }

    static testmethod void SetVehicleInfo_SetsModelToAsset1Model_GivenAssetAndLineItemsWithDifferentModels()
    {
    	MMIT_OpportunityHandoverInfoSetter handoverInfoSetter = new MMIT_OpportunityHandoverInfoSetter();

    	Vehicle_Specification__c brand1 = TestClass_VehicleSpecificationBuilder.BuildMake();
    	Product2 model1 = TestClass_ProductBuilder.BuildModel(brand1);
    	Product2 model2 = TestClass_ProductBuilder.BuildModel(brand1);
    	
    	OpportunityLineItem opportunityLineItem1 = TestClass_OppLineItemCreator.CreateOppLineItem();
    	insert opportunityLineItem1;
    	opportunityLineItem1.Model__c = model2.Id;
    	Opportunity opportunity1 = new Opportunity(Id = opportunityLineItem1.OpportunityId,
    			StageName = 'Handover');

    	Asset asset1 = new Asset(Order__r = new Order(OpportunityId = opportunity1.Id),
    			Model__c = model1.Id);
    	List<Asset> assets = new List<Asset>{ asset1 };

    	Map<String, List<Asset>> assetsByOpportunityId = new Map<String, List<Asset>> { 
    			opportunity1.Id => assets };
    	List<OpportunityLineItem> opportunityLineItems = new List<OpportunityLineItem> { opportunityLineItem1 };
    	List<Opportunity> opportunities = new List<Opportunity> { opportunity1 };


    	handoverInfoSetter.SetVehicleInfo(assetsByOpportunityId, opportunityLineItems, opportunities);


    	System.assertEquals(model1.Id, opportunity1.Handover_Model__c);
    }

    static testmethod void SetVehicleInfo_SetsModelToLineItem1Model_GivenLineItemWithModelAndNoAsset()
    {
    	MMIT_OpportunityHandoverInfoSetter handoverInfoSetter = new MMIT_OpportunityHandoverInfoSetter();

    	Vehicle_Specification__c brand1 = TestClass_VehicleSpecificationBuilder.BuildMake();
    	Product2 model1 = TestClass_ProductBuilder.BuildModel(brand1);
    	
    	OpportunityLineItem opportunityLineItem1 = TestClass_OppLineItemCreator.CreateOppLineItem();
    	insert opportunityLineItem1;
    	opportunityLineItem1.Model__c = model1.Id;
    	Opportunity opportunity1 = new Opportunity(Id = opportunityLineItem1.OpportunityId,
    			StageName = 'Handover');

    	Map<String, List<Asset>> assetsByOpportunityId = new Map<String, List<Asset>> { };
    	List<OpportunityLineItem> opportunityLineItems = new List<OpportunityLineItem> { opportunityLineItem1 };
    	List<Opportunity> opportunities = new List<Opportunity> { opportunity1 };


    	handoverInfoSetter.SetVehicleInfo(assetsByOpportunityId, opportunityLineItems, opportunities);


    	System.assertEquals(model1.Id, opportunity1.Handover_Model__c);
    }

    static testmethod void SetVehicleInfo_SetsDerivativeToAsset1Derivative_GivenAssetAndLineItemsWithDifferentDerivatives()
    {
    	MMIT_OpportunityHandoverInfoSetter handoverInfoSetter = new MMIT_OpportunityHandoverInfoSetter();

    	Vehicle_Specification__c brand1 = TestClass_VehicleSpecificationBuilder.BuildMake();
    	Product2 derivative1 = TestClass_ProductBuilder.BuildModel(brand1);
    	
    	OpportunityLineItem opportunityLineItem1 = TestClass_OppLineItemCreator.CreateOppLineItem();
    	insert opportunityLineItem1;
    	opportunityLineItem1 = [SELECT Brand__c, Model__c, Vista_Order_Number__c, OpportunityId, Product2Id 
    			FROM OpportunityLineItem WHERE Id =: opportunityLineItem1.Id];
    	Opportunity opportunity1 = new Opportunity(Id = opportunityLineItem1.OpportunityId,
    			StageName = 'Handover');

    	Asset asset1 = new Asset(Order__r = new Order(OpportunityId = opportunity1.Id),
    			Derivative__c = derivative1.Id);
    	List<Asset> assets = new List<Asset>{ asset1 };

    	Map<String, List<Asset>> assetsByOpportunityId = new Map<String, List<Asset>> { 
    			opportunity1.Id => assets };
    	List<OpportunityLineItem> opportunityLineItems = new List<OpportunityLineItem> { opportunityLineItem1 };
    	List<Opportunity> opportunities = new List<Opportunity> { opportunity1 };


    	handoverInfoSetter.SetVehicleInfo(assetsByOpportunityId, opportunityLineItems, opportunities);


    	System.assertEquals(derivative1.Id, opportunity1.Handover_Derivative__c);
    }

    static testmethod void SetVehicleInfo_SetsDerivativeToLineItem1Product_GivenLineItemAndNoAsset()
    {
    	MMIT_OpportunityHandoverInfoSetter handoverInfoSetter = new MMIT_OpportunityHandoverInfoSetter();

    	Vehicle_Specification__c brand1 = TestClass_VehicleSpecificationBuilder.BuildMake();
    	Product2 model1 = TestClass_ProductBuilder.BuildModel(brand1);
    	
    	OpportunityLineItem opportunityLineItem1 = TestClass_OppLineItemCreator.CreateOppLineItem();
    	insert opportunityLineItem1;
    	opportunityLineItem1 = [SELECT Brand__c, Model__c, Vista_Order_Number__c, OpportunityId, Product2Id 
    			FROM OpportunityLineItem WHERE Id =: opportunityLineItem1.Id];
    	Opportunity opportunity1 = new Opportunity(Id = opportunityLineItem1.OpportunityId,
    			StageName = 'Handover');

    	Map<String, List<Asset>> assetsByOpportunityId = new Map<String, List<Asset>> { };
    	List<OpportunityLineItem> opportunityLineItems = new List<OpportunityLineItem> { opportunityLineItem1 };
    	List<Opportunity> opportunities = new List<Opportunity> { opportunity1 };


    	handoverInfoSetter.SetVehicleInfo(assetsByOpportunityId, opportunityLineItems, opportunities);


    	System.assertEquals(opportunityLineItem1.Product2Id, opportunity1.Handover_Derivative__c);
    }

    static testmethod void SetVehicleInfo_SetsVINToAsset1VIN_GivenAssetVIN()
    {
    	MMIT_OpportunityHandoverInfoSetter handoverInfoSetter = new MMIT_OpportunityHandoverInfoSetter();

    	String vin1 = 'v1';

    	Vehicle_Specification__c brand1 = TestClass_VehicleSpecificationBuilder.BuildMake();
    	Product2 derivative1 = TestClass_ProductBuilder.BuildModel(brand1);
    	
    	OpportunityLineItem opportunityLineItem1 = TestClass_OppLineItemCreator.CreateOppLineItem();
    	insert opportunityLineItem1;
    	Opportunity opportunity1 = new Opportunity(Id = opportunityLineItem1.OpportunityId,
    			StageName = 'Handover');

    	Asset asset1 = new Asset(Order__r = new Order(OpportunityId = opportunity1.Id),
    			VIN__c = vin1);
    	List<Asset> assets = new List<Asset>{ asset1 };

    	Map<String, List<Asset>> assetsByOpportunityId = new Map<String, List<Asset>> { 
    			opportunity1.Id => assets };
    	List<OpportunityLineItem> opportunityLineItems = new List<OpportunityLineItem> { };
    	List<Opportunity> opportunities = new List<Opportunity> { opportunity1 };


    	handoverInfoSetter.SetVehicleInfo(assetsByOpportunityId, opportunityLineItems, opportunities);


    	System.assertEquals(vin1, opportunity1.VIN__c);
    }

    static testmethod void SetVehicleInfo_SetsOrderNumberToAssetOrderNumber_GivenAssetAndLineItemsWithDifferentOrderNumbers()
    {
    	MMIT_OpportunityHandoverInfoSetter handoverInfoSetter = new MMIT_OpportunityHandoverInfoSetter();

    	String orderNumber1 = 'o1';
    	String orderNumber2 = 'o2';

    	Vehicle_Specification__c brand1 = TestClass_VehicleSpecificationBuilder.BuildMake();
    	
    	OpportunityLineItem opportunityLineItem1 = TestClass_OppLineItemCreator.CreateOppLineItem();
    	insert opportunityLineItem1;
    	opportunityLineItem1.Vista_Order_Number__c = orderNumber2;
    	Opportunity opportunity1 = new Opportunity(Id = opportunityLineItem1.OpportunityId,
    			StageName = 'Handover');

    	Asset asset1 = new Asset(Order__r = new Order(OpportunityId = opportunity1.Id),
    			Order_Number__c = orderNumber1);
    	List<Asset> assets = new List<Asset>{ asset1 };

    	Map<String, List<Asset>> assetsByOpportunityId = new Map<String, List<Asset>> { 
    			opportunity1.Id => assets };
    	List<OpportunityLineItem> opportunityLineItems = new List<OpportunityLineItem> { opportunityLineItem1 };
    	List<Opportunity> opportunities = new List<Opportunity> { opportunity1 };


    	handoverInfoSetter.SetVehicleInfo(assetsByOpportunityId, opportunityLineItems, opportunities);


    	System.assertEquals(orderNumber1, opportunity1.Vista_Order_Number__c);
    }

    static testmethod void SetVehicleInfo_SetsOrderNumberToLineItemOrderNumber_GivenLineItemWithOrderNumbers()
    {
    	MMIT_OpportunityHandoverInfoSetter handoverInfoSetter = new MMIT_OpportunityHandoverInfoSetter();

    	String orderNumber1 = 'o1';

    	Vehicle_Specification__c brand1 = TestClass_VehicleSpecificationBuilder.BuildMake();
    	
    	OpportunityLineItem opportunityLineItem1 = TestClass_OppLineItemCreator.CreateOppLineItem();
    	insert opportunityLineItem1;
    	opportunityLineItem1.Vista_Order_Number__c = orderNumber1;
    	Opportunity opportunity1 = new Opportunity(Id = opportunityLineItem1.OpportunityId,
    			StageName = 'Handover');


    	Map<String, List<Asset>> assetsByOpportunityId = new Map<String, List<Asset>> { };
    	List<OpportunityLineItem> opportunityLineItems = new List<OpportunityLineItem> { opportunityLineItem1 };
    	List<Opportunity> opportunities = new List<Opportunity> { opportunity1 };


    	handoverInfoSetter.SetVehicleInfo(assetsByOpportunityId, opportunityLineItems, opportunities);


    	System.assertEquals(orderNumber1, opportunity1.Vista_Order_Number__c);
    }
}