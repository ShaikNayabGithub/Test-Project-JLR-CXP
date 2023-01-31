@isTest
public class Vista_Test_BatchProcessor {
    /*
    @testSetup static void insertTestProductData()
    {
        Id standardBook = test.getStandardPricebookId();
        PriceBook2 pBook = new PriceBook2(Name = 'Testing11');
        insert pBook;
        Product2 newProd = new Product2(Name = 'newprod11', ProductCode = 'a11', Description = 'desc');
        TestClass_LockableRecordInserter.AttemptInsert(newProd,5);  //insert newProd;
        PriceBookEntry standardPBE = new PriceBookEntry(Product2Id = newProd.Id, PriceBook2Id = standardBook, UnitPrice = 1234, IsActive = true, UseStandardPrice = false);
        TestClass_LockableRecordInserter.AttemptInsert(standardpBE, 5); //insert standardPBE;
        PriceBookEntry pBE = new PriceBookEntry(IsActive = true, UseStandardPrice = false, Product2Id = newProd.Id, PriceBook2Id = pBook.Id, UnitPrice = 1.0);
        TestClass_LockableRecordInserter.AttemptInsert(pBE, 5);//insert pBE;
    }
    
    static Account MakeTestAccount()
    {
        Account testAcc = new Account(Name = 'newAcc', Primary_Dealer_Code__c = 'uniqueid',RecordTypeId = AccountUtilities.RecordTypes.get('Retailer').Id);
        insert testAcc;
        return testAcc;
    }
    
    static Order MakeTestOrder(Account testAcc)
    {
        Order newOrder = new Order(AccountId = testAcc.Id, status = 'Deleted', EffectiveDate = Date.today(), Vista_Order_Number__c = '4');
        insert newOrder;
        return newOrder;
    }
        
    static testMethod void populateRequestIdMaps_AddsRequestToRecGroupsMappedToOrderNumber()
    {
        Vista_Request__c vReq = new Vista_Request__c(Name = 'req');
        insert vReq;
        Vista_RecordGroup recGroup = new Vista_RecordGroup();
        recGroup.request = vReq;
        recGroup.VistaVehicleOrder = new Vista_OrderService.VehicleOrder();
        recGroup.VistaVehicleOrder.MetaOrderNumber = '1';
        recGroup.VistaVehicleOrder.Vehicle = new Vista_OrderService.Vehicle();
        recGroup.VistaVehicleOrder.Specification = new Vista_OrderService.Specification();
        recGroup.VistaVehicleOrder.Specification.DescriptionGroupId = 'descgroupid';
        recGroup.VistaVehicleOrder.Distribution = new Vista_OrderService.Distribution();
        recGroup.VistaVehicleOrder.Distribution.DistributionChannel = new Vista_OrderService.DistributionChannel();
        recGroup.VistaVehicleOrder.Distribution.DistributionChannel.PartnerUniqueId = 'uniqueid';
        List<Vista_RecordGroup> recGroups = new List<Vista_RecordGroup>();
        recGroups.add(recGroup);
        
        Vista_BatchProcessor processor = new Vista_BatchProcessor();
        processor.populateRequestIdMaps(recGroups);
        Map<string, List<Id>> resultMap = processor.recordGroupsMappedToOrderNumber;
        
        system.assert(resultMap.containsKey('1'));
    }
    
    static testMethod void populateAccountsMappedToDealerCodes_ContainsOneAccountGivenRequestWithDealerCode()
    {
        Vista_Request__c vReq = new Vista_Request__c(Name = 'req');
        insert vReq;
        Vista_RecordGroup recGroup = new Vista_RecordGroup();
        recGroup.request = vReq;
        recGroup.VistaVehicleOrder = new Vista_OrderService.VehicleOrder();
        recGroup.VistaVehicleOrder.MetaOrderNumber = '2';
        recGroup.VistaVehicleOrder.Vehicle = new Vista_OrderService.Vehicle();
        recGroup.VistaVehicleOrder.Specification = new Vista_OrderService.Specification();
        recGroup.VistaVehicleOrder.Specification.DescriptionGroupId = 'descgroupid';
        recGroup.VistaVehicleOrder.Distribution = new Vista_OrderService.Distribution();
        recGroup.VistaVehicleOrder.Distribution.DistributionChannel = new Vista_OrderService.DistributionChannel();
        recGroup.VistaVehicleOrder.Distribution.DistributionChannel.PartnerUniqueId = 'uniqueid';
        List<Vista_RecordGroup> recGroups = new List<Vista_RecordGroup>();
        recGroups.add(recGroup);
        Account testAcc = Vista_Test_BatchProcessor.MakeTestAccount();
        
        Vista_BatchProcessor processor = new Vista_BatchProcessor();
        processor.populateRequestIdMaps(recGroups);
        processor.populateAccountsMappedToDealerCodes();
        
        Map<string, Account> resultMap = processor.AccountsMappedToDealerCodes;
        
        system.assert(resultMap.containsKey('uniqueid'));
    }
    
    static testMethod void getOrderAccountId_ReturnsDealerIdIfNoMatchingOpp()
    {
        Vista_Request__c vReq = new Vista_Request__c(Name = 'req');
        insert vReq;
        Vista_RecordGroup recGroup = new Vista_RecordGroup();
        recGroup.request = vReq;
        recGroup.VistaVehicleOrder = new Vista_OrderService.VehicleOrder();
        recGroup.VistaVehicleOrder.MetaOrderNumber = '3';
        recGroup.VistaVehicleOrder.Vehicle = new Vista_OrderService.Vehicle();
        recGroup.VistaVehicleOrder.Specification = new Vista_OrderService.Specification();
        recGroup.VistaVehicleOrder.Specification.DescriptionGroupId = 'descgroupid';
        recGroup.VistaVehicleOrder.Distribution = new Vista_OrderService.Distribution();
        recGroup.VistaVehicleOrder.Distribution.DistributionChannel = new Vista_OrderService.DistributionChannel();
        recGroup.VistaVehicleOrder.Distribution.DistributionChannel.PartnerUniqueId = 'uniqueid';
        List<Vista_RecordGroup> recGroups = new List<Vista_RecordGroup>();
        recGroups.add(recGroup);
        Account testAcc = Vista_Test_BatchProcessor.MakeTestAccount();
        Order newOrder = new Order();
        
        Vista_BatchProcessor processor = new Vista_BatchProcessor();
        processor.populateRequestIdMaps(recGroups);
        processor.populateAccountsMappedToDealerCodes();
        processor.OpportunitiesMappedToOrderNumber =  new Map<string, Opportunity>();
        
        Order result = processor.getOrderAccountId(newOrder, recGroup);
        
        system.assertEquals(testAcc.Id, result.AccountId);
    }
    
    static testMethod void addOrderIdsToAssets_AddsOrderIdToAsset()
    {
        Account testAcc = Vista_Test_BatchProcessor.MakeTestAccount();
        Order newOrder = Vista_Test_BatchProcessor.MakeTestOrder(testAcc);
        Asset newAsset = new Asset(Order_Number__c = '4');
        
        Vista_BatchProcessor processor = new Vista_BatchProcessor();
        processor.OrdersMappedToOrderNumber = new Map<String, Order>{'4'=>newOrder};
        processor.ordersToInsert.add(newOrder);
        processor.assetsToInsert.add(newAsset);
        
        processor.addOrderIdsToAssets(new List<Asset>{newAsset}, new List<Order>{newOrder});
        
        system.assertEquals(newOrder.Id, processor.assetsToInsert[0].Order__c);
    }
    
    static testMethod void addSaveResultInfoToRequest_AddsToErrorLogIfResultIsError()
    {
        Order newOrder = new Order();
        Database.SaveResult orderInsertResult = database.insert(newOrder, false);
        Vista_Request__c vReq = new Vista_Request__c();
        
        Vista_BatchProcessor processor = new Vista_BatchProcessor();
        Vista_Request__c result = processor.addSaveResultInfoToRequest(vReq, orderInsertResult);
        
        system.assertNotEquals(null, result.Error_Log__c);
    }
    
    static testMethod void appendErrorToProcessedRequest_SetStatusToUnprocessed_ErrorsPassedIn()
    {
        Vista_Request__c vReq = new Vista_Request__c(Error_Log__c = 'existing errors');
        insert vReq;
        Vista_BatchProcessor processor = new Vista_BatchProcessor();
        processor.RequestsMappedToIDs.put(vReq.Id, vReq);
        
        processor.requestsToUpdate.add(vReq);
        processor.requestUpdateCheck.put(vReq.Id, vReq);
        
        Vista_Request__c newReq = new Vista_Request__c(Id = vReq.Id, Error_Log__c = 'existing errors oh no');
        processor.appendErrorToProcessedRequest(newReq);
        
        Vista_Request__c result = processor.requestsToUpdate[0];
        system.assertEquals('Unprocessed', result.Status__c);
    }
    
    static testMethod void processVistaErrors_AddsErrorToRequest()
    {
        Vista_Request__c vReq = new Vista_Request__c();
        insert vReq;
        Order newOrder = new Order(Vista_Order_Number__c = '1234');
        List<Order> orderList = new List<Order>{newOrder};
        Database.SaveResult[] orderInsertResults = database.insert(orderList, false);
        List<Id> idList = new List<Id>{vReq.Id};
        
        Vista_BatchProcessor processor = new Vista_BatchProcessor();
        processor.RequestsMappedToIDs.put(vReq.Id, vReq);
        processor.recordGroupsMappedToOrderNumber.put('1234', idList);
        processor.processVistaErrors(orderInsertResults, orderList);
        
        Vista_Request__c result = processor.requestsToUpdate[0];
        system.assertNotEquals(null, result.Error_Log__c);
    }
    
    static testMethod void commitChanges_UpdatesOrderInOrdertoUpdate()
    {
        Account testAcc = Vista_Test_BatchProcessor.MakeTestAccount();
        Order newOrder = Vista_Test_BatchProcessor.MakeTestOrder(testAcc);
        Vista_Request__c vReq = new Vista_Request__c();
        insert vReq;
        
        Order updateOrder = new Order(Id = newOrder.Id, status = 'Draft');
        Vista_BatchProcessor processor = new Vista_BatchProcessor();
        List<Id> idList = new List<Id>{vReq.Id};
        processor.recordGroupsMappedToOrderNumber.put('4', idList);
        processor.ordersToBeUpdated.put('4', updateOrder);
        processor.eventCodesMappedToOrderNumbers = new Map<string, string>();
        processor.OpportunitiesMappedToOrderNumber = new Map<string, Opportunity>();
        processor.eventCodesMappedToOrderNumbers.put('4', 'NONSPEC');
        
        processor.commitChanges();
        
        Order result = [SELECT Status FROM Order WHERE Id =: newOrder.Id];
        system.assertEquals('Draft', result.Status);
    }
    
    static testMethod void processRequestForUpdate_AddsOrderToOrdersToUpdateIfDelete()
    {
        Account testAcc = Vista_Test_BatchProcessor.MakeTestAccount();
        Order newOrder = Vista_Test_BatchProcessor.MakeTestOrder(testAcc);
        newOrder.Status = 'Draft';
        Vista_RecordGroup recGroup = new Vista_RecordGroup();
        recGroup.VistaVehicleOrder = new Vista_OrderService.VehicleOrder();
        recGroup.VistaVehicleOrder.MetaOrderNumber = '4';
        recGroup.VistaVehicleOrder.EventCode = 'DELETE';
        
        Vista_BatchProcessor processor = new Vista_BatchProcessor();
        processor.AssetsMappedToOrderNumbers =  new Map<string, Asset>();
        processor.OrdersMappedToOrderNumber  = new Map<string, Order>();
        processor.processRequestForUpdate(recGroup, newOrder, null);
        
        Order result = processor.ordersToBeUpdated.get('4');
        system.assertEquals('Deleted', result.Status);
    }
    
    static testMethod void processRequestForUpdate_AddsOrderToOrdersToUpdateIfHandover()
    {
        Account testAcc = Vista_Test_BatchProcessor.MakeTestAccount();
        Order newOrder = Vista_Test_BatchProcessor.MakeTestOrder(testAcc);
        List<RecordType> recType = [SELECT Id FROM RecordType WHERE sObjectType = 'Vehicle_Specification__c' AND DeveloperName = 'Make'];
        Vehicle_Specification__c vehSpec = new Vehicle_Specification__c(name = 'brand', RecordTypeId = recType[0].Id);
        insert vehSpec;
        Asset newAsset = new Asset(Name = 'asset', AccountId = testAcc.Id, Order_Number__c = '4', Brand__c = vehSpec.Id);
        insert newAsset;
        
        Vista_RecordGroup recGroup = new Vista_RecordGroup();
        recGroup.VistaVehicleOrder = new Vista_OrderService.VehicleOrder();
        recGroup.VistaVehicleOrder.MetaOrderNumber = '4';
        recGroup.VistaVehicleOrder.EventCode = 'HANDOVER';
        
        Vista_BatchProcessor processor = new Vista_BatchProcessor();
        processor.AssetsMappedToOrderNumbers =  new Map<string, Asset>();
        processor.OrdersMappedToOrderNumber  = new Map<string, Order>();
        processor.processRequestForUpdate(recGroup, newOrder, newAsset);
        
        Order result = processor.ordersToBeUpdated.get('4');
        system.assertEquals('Fulfilled', result.Status);
        
    }
    
    static testMethod void processRequestForUpdate_ChangesDateOnOrderForNONSPEC()
    {
        Account testAcc = Vista_Test_BatchProcessor.MakeTestAccount();
        Order newOrder = Vista_Test_BatchProcessor.MakeTestOrder(testAcc);
        Vista_RecordGroup recGroup = new Vista_RecordGroup();
        recGroup.VistaVehicleOrder = new Vista_OrderService.VehicleOrder();
        recGroup.VistaVehicleOrder.EventCode = 'NONSPEC';
        recGroup.VistaVehicleOrder.MetaOrderNumber = 'Num';
        recGroup.VistaVehicleOrder.Manufacture = new Vista_OrderService.Manufacture();
        recGroup.VistaVehicleOrder.Manufacture.LastDayForSpecificationChange = '2016-07-07';
        recGroup.VistaVehicleOrder.Manufacture.Scheduling = new Vista_OrderService.Scheduling();
        recGroup.VistaVehicleOrder.Manufacture.Scheduling.CurrentPlannedDeliveryDate = '2016-08-12';
        recGroup.VistaVehicleOrder.Distribution = new Vista_OrderService.Distribution();
        recGroup.VistaVehicleOrder.Distribution.DistributionChannel = new Vista_OrderService.DistributionChannel();
        recGroup.VistaVehicleOrder.Distribution.DistributionChannel.PartnerUniqueId = 'dealercode';
        
        Vista_BatchProcessor processor = new Vista_BatchProcessor();
        processor.AccountsMappedToDealerCodes.put('dealercode', testAcc);
        processor.OpportunitiesMappedToOrderNumber = new Map<string, Opportunity>();
        processor.AssetsMappedToOrderNumbers =  new Map<string, Asset>();
        processor.OrdersMappedToOrderNumber  = new Map<string, Order>();
        processor.processRequestForUpdate(recGroup, newOrder, null);
        
        Order result = processor.ordersToBeUpdated.get('Num');
        Date expected = Date.newInstance(2016, 08, 12);
        
        system.assertEquals(expected, result.Planned_Delivery_Date__c);      
    }
    
    static testMethod void processRequestForUpdate_UpdatesAssetVINIfSPECMEND()
    {
        Account testAcc = Vista_Test_BatchProcessor.MakeTestAccount();
        Order newOrder = Vista_Test_BatchProcessor.MakeTestOrder(testAcc);
        List<RecordType> recType = [SELECT Id FROM RecordType WHERE sObjectType = 'Vehicle_Specification__c' AND DeveloperName = 'Make'];
        Vehicle_Specification__c vehSpec = new Vehicle_Specification__c(name = 'brand', RecordTypeId = recType[0].Id);
        insert vehSpec;
        Asset newAsset = new Asset(Name = 'asset', AccountId = testAcc.Id, Order_Number__c = '4', Brand__c = vehSpec.Id);
        insert newAsset;
        Vista_RecordGroup recGroup = new Vista_RecordGroup();
        recGroup.VistaVehicleOrder = new Vista_OrderService.VehicleOrder();
        recGroup.VistaVehicleOrder.EventCode = 'SPECMEND';
        recGroup.VistaVehicleOrder.Vehicle = new Vista_OrderService.Vehicle();
        recGroup.VistaVehicleOrder.Vehicle.VIN = 'newVIN';
        recGroup.VistaVehicleOrder.Distribution = new Vista_OrderService.Distribution();
        recGroup.VistaVehicleOrder.Distribution.DistributionChannel = new Vista_OrderService.DistributionChannel();
        recGroup.VistaVehicleOrder.Distribution.DistributionChannel.PartnerUniqueId = 'dealercode';
        recGroup.VistaVehicleOrder.Specification = new Vista_OrderService.Specification();
        recGroup.VistaVehicleOrder.Specification.DescriptionGroupId = 'dgid';
        
        Vista_BatchProcessor processor = new Vista_BatchProcessor();
        processor.AccountsMappedToDealerCodes.put('dealercode', testAcc);
        processor.OpportunitiesMappedToOrderNumber = new Map<string, Opportunity>();
        processor.productsMappedToProductCode  = new Map<string, Product2>();
        processor.processRequestForUpdate(recGroup, newOrder, newAsset);
        
        Asset result = processor.assetsToUpdate[0];
        system.assertEquals('newVIN', result.VIN__c);
    }
    
    static testMethod void createOrderLineItem_AddsLineItemToOrdersToInsert()
    {
        
        Vista_RecordGroup recGroup = new Vista_RecordGroup();
        recGroup.VistaVehicleOrder = new Vista_OrderService.VehicleOrder();
        recGroup.VistaVehicleOrder.EventCode = 'SPECMEND';
        recGroup.VistaVehicleOrder.Vehicle = new Vista_OrderService.Vehicle();
        recGroup.VistaVehicleOrder.Vehicle.VIN = 'newVIN';
        recGroup.VistaVehicleOrder.Distribution = new Vista_OrderService.Distribution();
        recGroup.VistaVehicleOrder.Distribution.DistributionChannel = new Vista_OrderService.DistributionChannel();
        recGroup.VistaVehicleOrder.Distribution.DistributionChannel.PartnerUniqueId = 'dealercode';
        recGroup.VistaVehicleOrder.Specification = new Vista_OrderService.Specification();
        recGroup.VistaVehicleOrder.Specification.DescriptionGroupId = 'a11';
        PriceBookEntry standardPBE = [SELECT Id, Product2Id, UnitPrice, ProductCode, PriceBook2Id, PriceBook2.Name FROM PriceBookEntry WHERE UnitPrice = 1234];
        Product2 newProd = [SELECT Id, Name, ProductCode, Description FROM Product2 WHERE Name = 'newprod11'];
        
        Vista_BatchProcessor processor = new Vista_BatchProcessor();
        processor.priceBooks = new List<PriceBookEntry>{standardPBE};
        processor.productsMappedToProductCode = new Map<string, Product2>();    
        processor.productsMappedToProductCode.put('a11', newProd);
        processor.createOrderLineItem(recGroup, null);
        
        OrderItem result = processor.createOrderLineItem(recGroup, null);
        system.assertEquals('desc', result.Description);
    }
    
    static testMethod void processRequestForCreate_AddsOrderToOrderToInsert()
    {
        Account testAcc = Vista_Test_BatchProcessor.MakeTestAccount();
        Vista_RecordGroup recGroup = new Vista_RecordGroup();
        recGroup.VistaVehicleOrder = new Vista_OrderService.VehicleOrder();
        recGroup.VistaVehicleOrder.EventCode = 'SPECMEND';
        recGroup.VistaVehicleOrder.Vehicle = new Vista_OrderService.Vehicle();
        recGroup.VistaVehicleOrder.Vehicle.VIN = 'newVIN';
        recGroup.VistaVehicleOrder.Distribution = new Vista_OrderService.Distribution();
        recGroup.VistaVehicleOrder.Distribution.DistributionChannel = new Vista_OrderService.DistributionChannel();
        recGroup.VistaVehicleOrder.Distribution.DistributionChannel.PartnerUniqueId = 'dealercode';
        recGroup.VistaVehicleOrder.Specification = new Vista_OrderService.Specification();
        recGroup.VistaVehicleOrder.Specification.DescriptionGroupId = 'a';
        PriceBookEntry standardPBE = [SELECT Id, Product2Id, UnitPrice, ProductCode, PriceBook2Id, PriceBook2.Name FROM PriceBookEntry WHERE UnitPrice = 1234];
        Product2 newProd = [SELECT Id, Name, ProductCode, Make__c, Model__c, Description FROM Product2 WHERE Name = 'newprod11'];
        
        Vista_BatchProcessor processor = new Vista_BatchProcessor();
        processor.AccountsMappedToDealerCodes.put('dealercode', testAcc);
        processor.OpportunitiesMappedToOrderNumber = new Map<string, Opportunity>();
        processor.priceBooks = new List<PriceBookEntry>{standardPBE};
        processor.productsMappedToProductCode = new Map<string, Product2>();    
        processor.productsMappedToProductCode.put('a', newProd);
        processor.assetsMappedToOrderNumbers = new Map<string, Asset>();
        
        processor.processRequestForCreate(recGroup);
        
        system.assertNotEquals(true, processor.ordersToInsert.isEmpty());
    }
    
    static testMethod void addIdsToUpdateLists_AddsIdToAsset()
    {
        Account testAcc = Vista_Test_BatchProcessor.MakeTestAccount();
        Order newOrder = Vista_Test_BatchProcessor.MakeTestOrder(testAcc);
        List<RecordType> recType = [SELECT Id FROM RecordType WHERE sObjectType = 'Vehicle_Specification__c' AND DeveloperName = 'Make'];
        Vehicle_Specification__c vehSpec = new Vehicle_Specification__c(name = 'brand', RecordTypeId = recType[0].Id);
        insert vehSpec;
        Asset newAsset = new Asset(Name = 'asset', AccountId = testAcc.Id, Order_Number__c = '4', Brand__c = vehSpec.Id);
        insert newAsset;
        
        Vista_BatchProcessor processor = new Vista_BatchProcessor();
        processor.ordersToInsert.add(newOrder);
        processor.assetsToInsert.add(newAsset);
        processor.assetsToUpdate.add(new Asset(Order_Number__c = '4'));
        processor.addIdsToUpdateLists();
        
        Asset result = processor.assetsToUpdate[0];
        system.assertEquals(newAsset.Id, result.Id);
    }
    
    static testMethod void updateSecondUpdateRequestWithDeferral_AddsRequestToRequestsToUpdateStatusUnprocessed_GivenRecordGroupWithRequest()
    {
        Vista_BatchProcessor processor = new Vista_BatchProcessor();
        Vista_RecordGroup recGroup = new Vista_RecordGroup();
        Vista_Request__c vRequest = new Vista_Request__c(Status__c = 'Processed');
        insert vRequest;
        recGroup.request = vRequest;
        
        processor.updateSecondUpdateRequestWithDeferral(recGroup);
        
        Vista_Request__c result = processor.requestsToUpdate[0];
        system.assertEquals('Unprocessed', result.Status__c);   
    }
    
    static testMethod void processRequestsIntoUpsertMethods_AddsRequestToRequestsToUpdateStatusUnprocessed_IfRecordWithSameOrderNumberIntoUpdateList()
    {
        Vista_Request__c vRequest = new Vista_Request__c(Status__c = 'Processed');
        insert vRequest;
        Vista_RecordGroup recGroup = new vista_RecordGroup();
        recGroup.VistaVehicleOrder = new Vista_OrderService.VehicleOrder();
        recGroup.VistaVehicleOrder.EventCode = 'SPECMEND';
        recGroup.VistaVehicleOrder.MetaOrderNumber = 'ornum';
        recGroup.request = vRequest;
        
        Vista_BatchProcessor processor = new Vista_BatchProcessor();
        processor.OrdersMappedToOrderNumber = new Map<string, Order>();
        processor.OrdersMappedToOrderNumber.put('ornum', new Order());
        processor.ordersToBeUpdated.put('ornum', new Order());
        
        List<Vista_RecordGroup> requests = new List<Vista_RecordGroup>{recGroup};
        
        processor.processRequestsIntoUpsertMethods(requests);
        
        Vista_Request__c result = processor.requestsToUpdate[0];
        system.assertEquals('Unprocessed', result.Status__c); 
    }
    
    static testMethod void activateCreatedOrders_setsOrderStatusToFulfilled_IfCodeIsHandover()
    {
        Account testAcc = Vista_Test_BatchProcessor.MakeTestAccount();
        Order newOrder = Vista_Test_BatchProcessor.MakeTestOrder(testAcc);
        
        Vista_BatchProcessor processor = new Vista_BatchProcessor();
        processor.eventCodesMappedToOrderNumbers = new Map<string, string>();
        processor.eventCodesMappedToOrderNumbers.put('4', 'HANDOVER');
        processor.OpportunitiesMappedToOrderNumber = new Map<string, Opportunity>();
        processor.activateCreatedOrders(new List<Order>{newOrder});
        
        Order result = processor.ordersToActivate[0];
        system.assertEquals('Fulfilled', result.Status);
    }
    
    static testMethod void populateRequestMappedToIds_Adds2IdsAndMaps_GivenTwoInsertedRequests()
    {
        Vista_Request__c req1 = new Vista_Request__c();
        Vista_Request__c req2 = new Vista_Request__c();
        List<Vista_Request__c> vReqs = new List<Vista_Request__c>{req1, req2};
        insert vReqs;
        
        Vista_RecordGroup group1 = new Vista_RecordGroup();
        group1.request = req1;
        Vista_RecordGroup group2 = new Vista_RecordGroup();
        group2.request = req2;
        List<Vista_RecordGroup> groupList = new List<Vista_RecordGroup>{group1, group2};
        
        Vista_BatchProcessor processor = new Vista_BatchProcessor();
        processor.populateRequestMappedToIds(groupList);
        Map<Id, Vista_Request__c> resultMap = processor.RequestsMappedToIDs;
            
        system.assertEquals(2, resultMap.size());
    }
        */
}