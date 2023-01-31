@isTest
public class OpportunityToOrderLinker_Test {
    @isTest
    static void  linkOrderToOpp_UpdatesOrderWithOppAccount()
    {
        Id standardBook = test.getStandardPricebookId();
        PriceBook2 pBook = new PriceBook2(Name = 'Testing');
        TestClass_LockableRecordInserter.AttemptInsert(pBook, 10); //insert pBook;
        Product2 newProd = new Product2(Name = 'newprod', ProductCode = 'a', Description = 'desc');
        TestClass_LockableRecordInserter.AttemptInsert(newProd, 10); //insert newProd;
        PriceBookEntry standardPBE = new PriceBookEntry(Product2Id = newProd.Id, PriceBook2Id = standardBook, UnitPrice = 1, IsActive = true, UseStandardPrice = false );
        TestClass_LockableRecordInserter.AttemptInsert(standardpBE, 20); //insert standardPBE;
        PriceBookEntry pBE = new PriceBookEntry(IsActive = true, UseStandardPrice = false, Product2Id = newProd.Id, PriceBook2Id = pBook.Id, UnitPrice = 1.0);
        insert pBE;
        Account newAcc = new Account(Name = 'testAcc');
        Account oldAcc = new Account(Name = 'AccTest');
        Account testAcc = new Account(Name = 'newAcc');
        insert new list<Account>{newAcc, oldAcc, testAcc};
            Opportunity opp  = new Opportunity(Name = 'newOpp', CloseDate = Date.today(), AccountId = newAcc.Id, StageName = 'order');
        insert opp;
        Order newOrder = new Order(Vista_Order_Number__c = '12345678', AccountId = oldAcc.Id, status = 'Draft', EffectiveDate = Date.today());
        insert newOrder;
        
        List<RecordType> recType = [SELECT Id FROM RecordType WHERE sObjectType = 'Vehicle_Specification__c' AND DeveloperName = 'Make'];
        Vehicle_Specification__c vehSpec = new Vehicle_Specification__c(name = 'brand', RecordTypeId = recType[0].Id);
        insert vehSpec;
        Asset newAsset = new Asset(Name =  'assetName', Order_Number__c = '12345678', AccountId = testAcc.Id, Brand__c = vehSpec.Id);
        insert newAsset;
        
        OpportunityLineItem newItem = new OpportunityLineItem(OpportunityId = opp.Id, PriceBookEntryId = pBE.Id, Quantity = 1, TotalPrice = 1);
        insert newItem;
        
        newItem.Vista_Order_Number__c = '12345678';
        update newItem;
        
        Order result = [SELECT AccountId FROM Order WHERE Id  =: newOrder.Id];
        
        system.assertEquals(newAcc.Id, result.AccountId);
    }
    @isTest
    static  void   OpportunityLineItemOfNewOpp_AssociatedWithAsset_DoesPopulateOrderNumber(){
        Opportunity opp = new Opportunity();
        opp = createNewProductOpportunity();      
        Vehicle_Specification__c brand1 = TestClass_VehicleSpecificationBuilder.BuildMake();              
        OpportunityLineItem opportunityLineItem1 = TestClass_OppLineItemCreator.CreateOppLineItem(opp.Id, brand1.Id, null);
        
        TestClass_AssetBuilder tb = new TestClass_AssetBuilder();
        Asset ass = TestClass_AssetBuilder.BuildVehicle(true);
        ass.Order_Number__c='123456';
        insert ass;
        
        insert opportunityLineItem1;
        
        Test.startTest();
        opportunityLineItem1.Asset__c = ass.Id;     
        update opportunityLineItem1;
        Test.stopTest();
        OpportunityLineItem oppline  = [Select id, Asset__c,Vista_Order_Number__c  from OpportunityLineItem where id=:opportunityLineItem1.Id];
        System.assertEquals('123456', oppline.Vista_Order_Number__c);     
    }
    @isTest
    static  void  OpportunityLineItemOfUsedOpp_AssociatedWithAsset_DoesNotPopulateOrderNumber(){
        Opportunity opp = new Opportunity();
        opp = createUsedProductOpportunity();      
        Vehicle_Specification__c brand1 = TestClass_VehicleSpecificationBuilder.BuildMake();              
        OpportunityLineItem opportunityLineItem1 = TestClass_OppLineItemCreator.CreateOppLineItem(opp.Id, brand1.Id, null);
        
        TestClass_AssetBuilder tb = new TestClass_AssetBuilder();
        Asset ass = TestClass_AssetBuilder.BuildVehicle(true);
        insert ass;
        insert opportunityLineItem1;
        
        Test.startTest();
        opportunityLineItem1.Asset__c = ass.Id;     
        update opportunityLineItem1;
        Test.stopTest();
        OpportunityLineItem oppline  = [Select id, Asset__c,Vista_Order_Number__c  from OpportunityLineItem where id=:opportunityLineItem1.Id];
        System.assertEquals(null, oppline.Vista_Order_Number__c);     
    }
    
       @isTest
    static  void   OpportunityLineItemOfNewOpp_AssociatedWithAsset_DoesPopulateLicencePlate(){
        Id standardBook = test.getStandardPricebookId();
        PriceBook2 pBook = new PriceBook2(Name = 'Testing');
        TestClass_LockableRecordInserter.AttemptInsert(pBook, 10); //insert pBook;
        Product2 newProd = new Product2(Name = 'newprod', ProductCode = 'a', Description = 'desc');
        TestClass_LockableRecordInserter.AttemptInsert(newProd, 10); //insert newProd;
        PriceBookEntry standardPBE = new PriceBookEntry(Product2Id = newProd.Id, PriceBook2Id = standardBook, UnitPrice = 1, IsActive = true, UseStandardPrice = false );
        TestClass_LockableRecordInserter.AttemptInsert(standardpBE, 20); //insert standardPBE;
        PriceBookEntry pBE = new PriceBookEntry(IsActive = true, UseStandardPrice = false, Product2Id = newProd.Id, PriceBook2Id = pBook.Id, UnitPrice = 1.0);
        insert pBE;
        Opportunity opp = new Opportunity();
        opp = createNewProductOpportunity();      
        Vehicle_Specification__c brand1 = TestClass_VehicleSpecificationBuilder.BuildMake();              
        //OpportunityLineItem opportunityLineItem1 = TestClass_OppLineItemCreator.CreateOppLineItem(opp.Id, brand1.Id, null);
         OpportunityLineItem opportunityLineItem1 = new OpportunityLineItem(OpportunityId = opp.Id, PriceBookEntryId = pBE.Id, Quantity = 1, TotalPrice = 1);
        
        TestClass_AssetBuilder tb = new TestClass_AssetBuilder();
        Asset ass = TestClass_AssetBuilder.BuildVehicle(true);
       
        ass.Registration_Number__c = '16235172';
        insert ass;
        system.debug('ass'+ass.id);
       opportunityLineItem1.asset__c = null;
        insert opportunityLineItem1;
        
        system.debug('opportunityLineItem1.asset__c'+opportunityLineItem1.asset__c);
        Test.startTest();
       opportunityLineItem1.licence_plate__c = '16235172';
       update opportunityLineItem1;
        system.debug('opportunityLineItem1.asset__c'+opportunityLineItem1.asset__c);
        Test.stopTest();
        OpportunityLineItem oppline  = [Select id, Asset__c,Vista_Order_Number__c  from OpportunityLineItem where id=:opportunityLineItem1.Id];
       System.assertNotEquals(null, oppline.Asset__c);        
    }
           @isTest
    static  void   OpportunityLineItemOfNewOpp_AssociatedWithAssetDoesPopulateVistaOrderNumber(){
        Id standardBook = test.getStandardPricebookId();
        PriceBook2 pBook = new PriceBook2(Name = 'Testing');
        TestClass_LockableRecordInserter.AttemptInsert(pBook, 10); //insert pBook;
        Product2 newProd = new Product2(Name = 'newprod', ProductCode = 'a', Description = 'desc');
        TestClass_LockableRecordInserter.AttemptInsert(newProd, 10); //insert newProd;
        PriceBookEntry standardPBE = new PriceBookEntry(Product2Id = newProd.Id, PriceBook2Id = standardBook, UnitPrice = 1, IsActive = true, UseStandardPrice = false );
        TestClass_LockableRecordInserter.AttemptInsert(standardpBE, 20); //insert standardPBE;
        PriceBookEntry pBE = new PriceBookEntry(IsActive = true, UseStandardPrice = false, Product2Id = newProd.Id, PriceBook2Id = pBook.Id, UnitPrice = 1.0);
        insert pBE;
        Opportunity opp = new Opportunity();
        opp = createNewProductOpportunity();      
        Vehicle_Specification__c brand1 = TestClass_VehicleSpecificationBuilder.BuildMake();              
        //OpportunityLineItem opportunityLineItem1 = TestClass_OppLineItemCreator.CreateOppLineItem(opp.Id, brand1.Id, null);
         OpportunityLineItem opportunityLineItem1 = new OpportunityLineItem(OpportunityId = opp.Id, PriceBookEntryId = pBE.Id, Quantity = 1, TotalPrice = 1);
        
        TestClass_AssetBuilder tb = new TestClass_AssetBuilder();
        Asset ass = TestClass_AssetBuilder.BuildVehicle(true);
       
         ass.Order_Number__c='123456';
        insert ass;
        system.debug('ass'+ass.id);
       opportunityLineItem1.asset__c = null;
        insert opportunityLineItem1;
        
        system.debug('opportunityLineItem1.asset__c'+opportunityLineItem1.asset__c);
        Test.startTest();
       opportunityLineItem1.Vista_Order_Number__c = '123456';
       update opportunityLineItem1;
        system.debug('opportunityLineItem1.asset__c'+opportunityLineItem1.asset__c);
        Test.stopTest();
        OpportunityLineItem oppline  = [Select id, Asset__c,Vista_Order_Number__c  from OpportunityLineItem where id=:opportunityLineItem1.Id];
       System.assertNotEquals(null, oppline.Asset__c);     
    }
    
    
    public static Opportunity createNewProductOpportunity()
    {
        Opportunity opp = new Opportunity();
        opp.Name = 'test';
        opp.StageName = 'Contacted';
        Account testAccount = new Account();
        testAccount.LastName = 'Test Account Name';
        testAccount.RecordType = [select Id from RecordType where Name = 'Individual' and SobjectType = 'Account' limit 1];
        testAccount.PersonEmail = 'test@test.test';
           testAccount.Country_Iso_code__c = 'IN';
        insert testAccount;
        opp.AccountId = testAccount.Id;
        Vehicle_Specification__c vehicleSpec1 = new Vehicle_Specification__c();
        vehicleSpec1.RecordType = [select Id from RecordType where Name = 'Make' and SObjectType = 'Vehicle_Specification__c' limit 1];
        vehicleSpec1.Name = 'Jaguar';
        insert vehicleSpec1;
        opp.Brand__c = vehicleSpec1.Id;
        opp.CloseDate = date.parse('12/12/2016');
        opp.Type = 'Product';
        opp.Purchase_Type__c = 'New Vehicle';
        insert opp;
        return opp;
    }
    public static Opportunity createUsedProductOpportunity()
    {
        Opportunity opp = new Opportunity();
        opp.Name = 'test';
        opp.StageName = 'Contacted';
        Account testAccount = new Account();
        testAccount.LastName = 'Test Account Name';
        testAccount.RecordType = [select Id from RecordType where Name = 'Individual' and SobjectType = 'Account' limit 1];
        testAccount.PersonEmail = 'test@test.test';
        testAccount.Country_Iso_code__c = 'IN';
        insert testAccount;
        opp.AccountId = testAccount.Id;
        Vehicle_Specification__c vehicleSpec1 = new Vehicle_Specification__c();
        vehicleSpec1.RecordType = [select Id from RecordType where Name = 'Make' and SObjectType = 'Vehicle_Specification__c' limit 1];
        vehicleSpec1.Name = 'Jaguar';
        insert vehicleSpec1;
        opp.Brand__c = vehicleSpec1.Id;
        opp.CloseDate = date.parse('12/12/2016');
        opp.Type = 'Product';
        opp.Purchase_Type__c = 'Used Vehicle';
        insert opp;
        return opp;
    }
}