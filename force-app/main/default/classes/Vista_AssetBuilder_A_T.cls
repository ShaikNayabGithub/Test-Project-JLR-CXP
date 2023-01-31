@isTest
public class Vista_AssetBuilder_A_T {
    static testmethod void Build_DoesNothing_GivenAssetFoundAndVehicleNull()
    {
        Vista_AssetBuilder_A assetBuilder = CreateAssetBuilder();
        
        
        String orderNumber = 'o1';
        Asset asset1 = new Asset(Original_Handover_Date__c=NULL);
        
        String marketString = 'IN';
        String hddateString = '2016-12-18';
        String regdateString = '2015-12-18';
        
        Vista_RequestCollection requestCollection = CreateEmptyCollection();
        requestCollection.Assets.put(orderNumber, asset1);
        
        Vista_RecordGroup recordGroup = CreateEmptyRecordGroup();
        
        recordGroup.VistaVehicleOrder.MetaOrderNumber = orderNumber;
        
        recordGroup.VistaVehicleOrder.Eventcode = 'HANDOVER';
        recordGroup.VistaVehicleOrder.Customer = new Vista_OrderService.Customer();
        recordGroup.VistaVehicleOrder.Customer.CustomerHandoverDate = hddateString;
        recordGroup.Request.Market__c= marketString;
        recordGroup.VistaVehicleOrder.Registration = new Vista_OrderService.Registration();
        recordGroup.VistaVehicleOrder.Registration.RegistrationDate = regdateString;
        recordGroup.VistaVehicleOrder.Contract = new Vista_OrderService.Contract();
        recordGroup.VistaVehicleOrder.Contract.Salesman = '';
        
        
        assetBuilder.Build(recordGroup, requestCollection, null);
        
        System.assert(true);
    }
    
    static testmethod void Build_AddsAssetWithStatusCreated_GivenAssetDoesntExist()
    {
        Vista_AssetBuilder_A assetBuilder = CreateAssetBuilder();
        
        
        String orderNumber = 'o1';
        
        Vista_RequestCollection requestCollection = CreateEmptyCollection();
        
        Vista_RecordGroup recordGroup = CreateEmptyRecordGroup();
        recordGroup.VistaVehicleOrder.MetaOrderNumber = orderNumber;
        
        
        assetBuilder.Build(recordGroup, requestCollection, null);
        
        System.assertEquals(System.label.Asset_ForSaleStatus, requestCollection.Assets.get(orderNumber).Status);
    }
    
    static testmethod void Build_AddsAssetWithNameO1_GivenAssetDoesntExist()
    {
        Vista_AssetBuilder_A assetBuilder = CreateAssetBuilder();
        
        
        String orderNumber = 'o1';
        
        Vista_RequestCollection requestCollection = CreateEmptyCollection();
        
        Vista_RecordGroup recordGroup = CreateEmptyRecordGroup();
        recordGroup.VistaVehicleOrder.MetaOrderNumber = orderNumber;
        
        
        assetBuilder.Build(recordGroup, requestCollection, null);
        
        System.assertEquals(orderNumber, requestCollection.Assets.get(orderNumber).Name);
    }
    
    static testmethod void Build_AddsAssetWithNOrderNumberO1_GivenAssetDoesntExist()
    {
        Vista_AssetBuilder_A assetBuilder = CreateAssetBuilder();
        
        
        String orderNumber = 'o1';
        
        Vista_RequestCollection requestCollection = CreateEmptyCollection();
        
        Vista_RecordGroup recordGroup = CreateEmptyRecordGroup();
        recordGroup.VistaVehicleOrder.MetaOrderNumber = orderNumber;
        
        
        assetBuilder.Build(recordGroup, requestCollection, null);
        
        System.assertEquals(orderNumber, requestCollection.Assets.get(orderNumber).Order_Number__c);
    }
    
    static testmethod void Build_AddsAssetWithRetailerAccountId_GivenAssetDoesntExistAndRetailerFound()
    {
        Vista_AssetBuilder_A assetBuilder = CreateAssetBuilder();
        
        
        String orderNumber = 'o1';
        Account retailer = TestClass_AccountCreator.CreateRetailer();
        
        Vista_RequestCollection requestCollection = CreateEmptyCollection();
        requestCollection.Retailers.put(retailer.Primary_Dealer_Code__c, retailer);
        
        Vista_RecordGroup recordGroup = CreateEmptyRecordGroup();
        recordGroup.VistaVehicleOrder.MetaOrderNumber = orderNumber;
        recordGroup.VistaVehicleOrder.Distribution.DistributionChannel.PartnerUniqueID = 
            retailer.Primary_Dealer_Code__c;
        
        
        assetBuilder.Build(recordGroup, requestCollection, null);
        
        System.assertEquals(retailer.Id, requestCollection.Assets.get(orderNumber).AccountId);
    }
    
    static testmethod void Build_AddsAssetWithOpportunityAccountId_GivenAssetDoesntExistAndOpportunityFound()
    {
        Vista_AssetBuilder_A assetBuilder = CreateAssetBuilder();
        
        
        String orderNumber = 'o1';
        Account retailer = TestClass_AccountCreator.CreateRetailer();
        
        Vista_RequestCollection requestCollection = CreateEmptyCollection();
        requestCollection.OpportunityLineItems.put(orderNumber, new OpportunityLineItem(
            Opportunity=new Opportunity(AccountId=retailer.Id,stageName='Handover')));
        
        Vista_RecordGroup recordGroup = CreateEmptyRecordGroup();
        recordGroup.VistaVehicleOrder.MetaOrderNumber = orderNumber;
        
        
        assetBuilder.Build(recordGroup, requestCollection, null);
        
        System.assertEquals(retailer.Id, requestCollection.Assets.get(orderNumber).AccountId);
    }
    
    static testmethod void Build_AddsAssetWithOpportunityAccountId_GivenAssetDoesntExistAndOpportunityAndRetailerFound()
    {
        Vista_AssetBuilder_A assetBuilder = CreateAssetBuilder();
        
        String orderNumber = 'o1';
        Account customerAccount = TestClass_AccountCreator.CreateRetailer();
        
        Account retailer = new Account();
        retailer.Name = 'test retailer';
        retailer.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Retailer').getRecordTypeId(); 
        retailer.Dealer_CI_Code__c = 'test retailer';
        retailer.Primary_Dealer_Code__c = 'test retailer';
        retailer.Secondary_Dealer_Code__c = 'test retailer';
        retailer.Alternative_Key__c = 'test retailer';
        insert retailer;
        
        Vista_RequestCollection requestCollection = CreateEmptyCollection();
        requestCollection.OpportunityLineItems.put(orderNumber, new OpportunityLineItem(
            Opportunity=new Opportunity(AccountId=customerAccount.Id,stagename='Handover')));
        requestCollection.Retailers.put(retailer.Primary_Dealer_Code__c, retailer);
        
        Vista_RecordGroup recordGroup = CreateEmptyRecordGroup();
        recordGroup.VistaVehicleOrder.MetaOrderNumber = orderNumber;
        recordGroup.VistaVehicleOrder.Distribution.DistributionChannel.PartnerUniqueID = 
            retailer.Primary_Dealer_Code__c;
        
        
        assetBuilder.Build(recordGroup, requestCollection, null);
        System.assertEquals(customerAccount.Id, requestCollection.Assets.get(orderNumber).AccountId);
    }
    
    static testmethod void Build_SetsAssetVin_GivenVehicleNotNull()
    {
        Vista_AssetBuilder_A assetBuilder = CreateAssetBuilder();
        
        
        String orderNumber = 'o1';
        String vin = 'v1';
        Asset asset1 = new Asset();
        
        Vista_RequestCollection requestCollection = CreateEmptyCollection();
        requestCollection.Assets.put(orderNumber, asset1);
        
        Vista_RecordGroup recordGroup = CreateEmptyRecordGroup();
        recordGroup.VistaVehicleOrder.MetaOrderNumber = orderNumber;
        recordGroup.VistaVehicleOrder.Vehicle = new Vista_OrderService.Vehicle();
        recordGroup.VistaVehicleOrder.Vehicle.VIN = vin;
        
        
        assetBuilder.Build(recordGroup, requestCollection, null);
        
        System.assertEquals(vin, asset1.VIN__c);
    }
    
    static testmethod void Build_SetsAssetName_GivenVehicleNotNull()
    {
        Vista_AssetBuilder_A assetBuilder = CreateAssetBuilder();
        
        
        String orderNumber = 'o1';
        String vin = 'v1';
        Asset asset1 = new Asset();
        
        Vista_RequestCollection requestCollection = CreateEmptyCollection();
        requestCollection.Assets.put(orderNumber, asset1);
        
        Vista_RecordGroup recordGroup = CreateEmptyRecordGroup();
        recordGroup.VistaVehicleOrder.MetaOrderNumber = orderNumber;
        recordGroup.VistaVehicleOrder.Vehicle = new Vista_OrderService.Vehicle();
        recordGroup.VistaVehicleOrder.Vehicle.VIN = vin;
        
        
        assetBuilder.Build(recordGroup, requestCollection, null);
        
        System.assertEquals(vin, asset1.Name);
    }
    
    static testmethod void Build_SetsAssetShortVin_GivenVehicleWithShortVin()
    {
        Vista_AssetBuilder_A assetBuilder = CreateAssetBuilder();
        
        
        String orderNumber = 'o1';
        String shortVin = 'v1';
        Asset asset1 = new Asset();
        
        Vista_RequestCollection requestCollection = CreateEmptyCollection();
        requestCollection.Assets.put(orderNumber, asset1);
        
        Vista_RecordGroup recordGroup = CreateEmptyRecordGroup();
        recordGroup.VistaVehicleOrder.MetaOrderNumber = orderNumber;
        recordGroup.VistaVehicleOrder.Vehicle = new Vista_OrderService.Vehicle();
        recordGroup.VistaVehicleOrder.Vehicle.ShortVIN = shortVin;
        
        
        assetBuilder.Build(recordGroup, requestCollection, null);
        
        System.assertEquals(shortVin, asset1.Short_VIN__c);
    }
    
    static testmethod void Build_SetsAssetEngineNumber_GivenVehicleWithEngineNumber()
    {
        Vista_AssetBuilder_A assetBuilder = CreateAssetBuilder();
        
        
        String orderNumber = 'o1';
        String engineNumber = 'e1';
        Asset asset1 = new Asset();
        
        Vista_RequestCollection requestCollection = CreateEmptyCollection();
        requestCollection.Assets.put(orderNumber, asset1);
        
        Vista_RecordGroup recordGroup = CreateEmptyRecordGroup();
        recordGroup.VistaVehicleOrder.MetaOrderNumber = orderNumber;
        recordGroup.VistaVehicleOrder.Vehicle = new Vista_OrderService.Vehicle();
        recordGroup.VistaVehicleOrder.Vehicle.EngineNumber = engineNumber;
        
        
        assetBuilder.Build(recordGroup, requestCollection, null);
        
        System.assertEquals(engineNumber, asset1.Engine_Number__c);
    }
    
    static testmethod void Build_SetsAssetChassisNumber_GivenVehicleWithChassisNumber()
    {
        Vista_AssetBuilder_A assetBuilder = CreateAssetBuilder();
        
        
        String orderNumber = 'o1';
        String chassisNumber = 'c1';
        Asset asset1 = new Asset();
        
        Vista_RequestCollection requestCollection = CreateEmptyCollection();
        requestCollection.Assets.put(orderNumber, asset1);
        
        Vista_RecordGroup recordGroup = CreateEmptyRecordGroup();
        recordGroup.VistaVehicleOrder.MetaOrderNumber = orderNumber;
        recordGroup.VistaVehicleOrder.Vehicle = new Vista_OrderService.Vehicle();
        recordGroup.VistaVehicleOrder.Vehicle.ChassisNumber = chassisNumber;
        
        
        assetBuilder.Build(recordGroup, requestCollection, null);
        
        System.assertEquals(chassisNumber, asset1.Chassis_Number__c);
    }
    
    
    static testmethod void Build_SetsAssetName_GivenVehicleWithManufacture()
    {
        Vista_AssetBuilder_A assetBuilder = CreateAssetBuilder();
        
        
        
        Asset assetIns = TestClass_AssetBuilder.BuildVehicle(false);
        assetIns.Order_Number__c = 'SAL123456789';
        assetIns.VIN__c = 'SAL123456789';
        insert assetIns;
        
        
        String orderNumber = assetIns.Order_Number__c;
        String vin = assetIns.VIN__c;
        
        Vista_RequestCollection requestCollection = CreateEmptyCollection();
        requestCollection.Assets.put(orderNumber, assetIns);
        
        Vista_Request__c vistaReq =  new Vista_Request__c();
        vistaReq.Vin__c = vin;
        
        Vista_RecordGroup recordGroup = CreateEmptyRecordGroup();
        recordGroup.VistaVehicleOrder.MetaOrderNumber = orderNumber;
        recordGroup.VistaVehicleOrder.Vehicle = new Vista_OrderService.Vehicle();
        recordGroup.VistaVehicleOrder.Vehicle.VIN = vin;
        recordGroup.Request = vistaReq;
        
        requestCollection.RecordGroups.put(orderNumber, new List<Vista_RecordGroup>{recordGroup});
        
        Vista_OrderService.Manufacture manufactIns = new Vista_OrderService.Manufacture();
        Vista_OrderService.Scheduling schIns = new Vista_OrderService.Scheduling();
        schIns.CurrentPlannedDeliveryDate = String.valueof(system.today());
        manufactIns.Scheduling = schIns;
        recordGroup.VistaVehicleOrder.Manufacture = manufactIns;
        
        Vista_OrderService.Contract contIns = new Vista_OrderService.Contract();       
        contIns.ContractDate = String.valueof(system.today());
        recordGroup.VistaVehicleOrder.Contract = contIns;
        
        assetBuilder.Build(recordGroup, requestCollection, null);
        
        Vista_AssetRetriever assetRet = new Vista_AssetRetriever();
        assetRet.Retrieve(requestCollection);
    }
    
    
    private static Vista_RequestCollection CreateEmptyCollection()
    {
        Vista_RequestCollection requestCollection = new Vista_RequestCollection();
        
        requestCollection.RecordGroups = new Map<String, List<Vista_RecordGroup>>();
        requestCollection.Assets = new Map<String, Asset>();
        requestCollection.Orders = new Map<String, Order>();
        requestCollection.OpportunityLineItems = new Map<String, OpportunityLineItem>();
        requestCollection.Retailers = new Map<String, Account>();
        requestCollection.Derivatives = new Map<String, Product2>();
        requestCollection.migratedVehicles = new Map<String, Account>();
        
        return requestCollection;
    }
    
    private static Vista_RecordGroup CreateEmptyRecordGroup()
    {
        Vista_RecordGroup recordGroup = new Vista_RecordGroup();
        
        recordGroup.Request = new Vista_Request__c();
        recordGroup.VistaVehicleOrder = new Vista_OrderService.VehicleOrder();
        recordGroup.VistaVehicleOrder.Specification = new Vista_OrderService.Specification();
        recordGroup.VistaVehicleOrder.Specification.Features = new List<Vista_OrderService.Feature>();
        recordGroup.VistaVehicleOrder.Distribution = new Vista_OrderService.Distribution();
        recordGroup.VistaVehicleOrder.Manufacture = new Vista_OrderService.Manufacture();
        recordGroup.VistaVehicleOrder.Manufacture.Scheduling = new Vista_OrderService.Scheduling();
        recordGroup.VistaVehicleOrder.Distribution.DistributionChannel = new Vista_OrderService.DistributionChannel();
        
        return recordGroup;
    }
    
    private static Vista_AssetBuilder_A CreateAssetBuilder()
    {
        Vista_Date_Adapter dateAdapter = new Vista_Date_Adapter();
        Vista_AssetNonSpecSetter nonSpecSetter = new Vista_AssetNonSpecSetter(dateAdapter);
        Vista_AssetSpecSetter specSetter = new Vista_AssetSpecSetter();
        
        return new Vista_AssetBuilder_Dummy(nonSpecSetter, specSetter);
    }
    
    
    private class Vista_AssetBuilder_Dummy extends Vista_AssetBuilder_A {
        public Vista_AssetBuilder_Dummy(Vista_AssetNonSpecSetter nonSpecSetter, Vista_AssetSpecSetter specSetter)
        {
            super(nonSpecSetter, specSetter);
        }
        
        
        protected override void Build(Asset asset, Vista_RecordGroup request, Vista_RequestCollection requestCollection)
        {
            //do nothing
        }
    }
}