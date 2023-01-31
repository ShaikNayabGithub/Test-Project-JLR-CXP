@isTest
public class Vista_Test_DataMapRetriever {
    /*
    @testSetup static void insertTestProductData()
    {
        Id standardBook = test.getStandardPricebookId();
        PriceBook2 pBook = new PriceBook2(Name = 'Testing12');
        insert pBook;
        Product2 newProd = new Product2(Name = 'newprod12', ProductCode = 'a12', Description = 'desc');
        TestClass_LockableRecordInserter.AttemptInsert(newProd,5);  //insert newProd;
        PriceBookEntry standardPBE = new PriceBookEntry(Product2Id = newProd.Id, PriceBook2Id = standardBook, UnitPrice = 1234, IsActive = true, UseStandardPrice = false);
        TestClass_LockableRecordInserter.AttemptInsert(standardpBE, 5); //insert standardPBE;
        PriceBookEntry pBE = new PriceBookEntry(IsActive = true, UseStandardPrice = false, Product2Id = newProd.Id, PriceBook2Id = pBook.Id, UnitPrice = 7);
        TestClass_LockableRecordInserter.AttemptInsert(pBE, 5);//insert pBE;
    }
    
    static testMethod void retrievePriceBookEntries_ReturnsNonEmptyList_RequestPassedIn()
    {
       
        Vista_RecordGroup recGroup = new Vista_RecordGroup();
        recGroup.VistaVehicleOrder = new Vista_OrderService.VehicleOrder();
        recGroup.VistaVehicleOrder.Specification = new Vista_OrderService.Specification();
        recGroup.VistaVehicleOrder.Specification.DescriptionGroupId = 'a12';
        recGroup.request = new Vista_Request__c(Market_Description__c = 'Testing12');
        
        List<Vista_RecordGroup> groups = new List<Vista_RecordGroup>();
        groups.add(recGroup);
        
        Vista_DataMapRetriever mapRetriever = new Vista_DataMapRetriever();
        List<PriceBookEntry> result = mapRetriever.retrievePriceBookEntries(groups);
        
        system.assertEquals(false, result.isEmpty());
    }
    
    static testMethod void populateOrderToOrderMap_ReturnsMapWithExistingOrder()
    {
        Account testAcc = TestClass_AccountCreator.CreateRetailer();
        Order newOrder = new Order(Vista_Order_Number__c = 'myNumber', EffectiveDate = Date.today(), AccountId = testAcc.Id, status = 'draft');
        insert newOrder;
        
        Set<string> orderNumbers = new Set<string>();
        orderNumbers.add('myNumber');
        
        Vista_DataMapRetriever mapRetriever = new Vista_DataMapRetriever();      
        Map<string, Order> orderMap = mapRetriever.populateOrderToOrderNumberMap(orderNumbers);
        
        Order result = orderMap.get('myNumber');
        system.assertEquals(newOrder.Id, result.Id);
    }
    
    static testMethod void getOrderNumberFromSObject_ReturnsORderNumberFromAsset()
    {
        Asset newAsset = new Asset(Order_Number__c = 'mynum');
        Vista_DataMapRetriever mapRetriever = new Vista_DataMapRetriever();   
        
        string result = mapRetriever.getOrderNumberFromSObject(newAsset);
        
        system.assertEquals('mynum', result);
    }
    
    static testMethod void retrieveAssetsMappedToOrderNumber_ReturnsNonEmptyList_AssetExists()
    {
        Account testAcc = TestClass_AccountCreator.CreateRetailer();
        List<RecordType> recType = [SELECT Id FROM RecordType WHERE sObjectType = 'Vehicle_Specification__c' AND DeveloperName = 'Make'];
        Vehicle_Specification__c vehSpec = new Vehicle_Specification__c(name = 'brand', RecordTypeId = recType[0].Id);
        insert vehSpec;
        Asset newAsset = new Asset(Name = 'test', Order_Number__c = 'myNumber', AccountId = testAcc.Id, Brand__c = vehSpec.Id);
        insert newAsset;
        
        Set<string> orderNumbers = new Set<string>();
        orderNumbers.add('myNumber');
        
        Vista_DataMapRetriever mapRetriever = new Vista_DataMapRetriever();
        Map<String, Asset> result = mapRetriever.retrieveAssetsMappedToOrderNumber(orderNumbers);
        
        system.assert(result.containsKey('myNumber'));
    }
    
    static testMethod void retrieveProducts_ReturnsProduct_MappedToCode()
    {
        Vista_RecordGroup recGroup = new Vista_RecordGroup();
        recGroup.VistaVehicleOrder = new Vista_OrderService.VehicleOrder();
        recGroup.VistaVehicleOrder.Specification = new Vista_OrderService.Specification();
        recGroup.VistaVehicleOrder.Specification.DescriptionGroupId = 'a12';
        List<Vista_RecordGroup> groups = new List<Vista_RecordGroup>();
        groups.add(recGroup);
        
        Vista_DataMapRetriever mapRetriever = new Vista_DataMapRetriever();
        Map<string, Product2> result = mapRetriever.retrieveProducts(groups);
        
        system.assert(result.containsKey('a12'));

    }
    
    static testMethod void populateOppsMappedToOrderNumber_RetrunsOppMappedToCode_WhenOppExists()
    {
        Account testAcc = TestClass_AccountCreator.CreatePersonAccount();
        Opportunity opp = new Opportunity(AccountId = testAcc.Id, Name = 'opp', CloseDate = Date.today(), StageName = 'Order');
        insert opp;
        PriceBookEntry pBE = [SELECT Id, Product2Id, UnitPrice, ProductCode, PriceBook2Id, PriceBook2.Name FROM PriceBookEntry WHERE UnitPrice = 7];
        Product2 newProd = [SELECT Id, Name, ProductCode, Make__c, Model__c, Description FROM Product2 WHERE Name = 'newprod12'];

        OpportunityLineItem lineItem = new OpportunityLineItem(Vista_Order_Number__c = 'ordernum', OpportunityId = opp.Id, PricebookEntryId = pBE.ID, Quantity = 1,
                                                              TotalPrice = 1);
        insert lineItem;
        List<Id> idList = new List<Id>{opp.Id};
        Map<string, List<Id>> inputMap = new Map<string, List<Id>>();
        inputMap.put('ordernum', idList);
        
        Vista_DataMapRetriever mapRetriever = new Vista_DataMapRetriever();
        Map<string, Opportunity> result = mapRetriever.populateOpportunitiesMappedToOrderNumber(inputMap);
        
        system.assert(result.containsKey('ordernum'));
    }
*/
}