@isTest
public with sharing class OpportunityProductOptionHandler_Tests {
    
    @TestSetup
    static void makeData(){
        //create list of OpportunityLineItem to test
        //create list of Opportunities (for the same Account using Utility methods)
        Opportunity opp1 = TestClass_ValidOpportunityBuilder.Build();
        opp1.Name = 'test1';
        opp1.CurrencyIsoCode = 'KRW';
        Opportunity opp2 = TestClass_ValidOpportunityBuilder.Build();
        opp2.Name = 'test2';
        opp2.CurrencyIsoCode = 'KRW';
        List<Opportunity> oppList = new List<Opportunity>{opp1, opp2};
        insert oppList;
        //Pricebook2 pb = TestClass_PricebookCreator.CreatePricebook('Korea'); 
        //create OpportunityLineItems
        Vehicle_Specification__c  make = TestClass_VehicleSpecificationBuilder.BuildMake();
        
        TestClass_ProductBuilder.insertImmediately = false;
        Product2  model = TestClass_ProductBuilder.BuildModel(make);
        model.Enable_Automatic_Product_Add_Ons__c = true;

        Product2 option = TestClass_ProductBuilder.BuildAccessoryOption('option');
        List<Product2> products = new List<Product2>{model, option};
        insert products;

        PricebookEntry  pbeModel = new PricebookEntry();
        pbeModel.Pricebook2Id = Test.getStandardPricebookId();
        pbeModel.UnitPrice = 100;
        pbeModel.CurrencyIsoCode = 'KRW';
        pbeModel.IsActive = true;
        pbeModel.product2Id = model.Id;

        PricebookEntry  pbeOption = new PricebookEntry();
        pbeOption.Pricebook2Id = Test.getStandardPricebookId();
        pbeOption.UnitPrice = 10;
        pbeOption.CurrencyIsoCode = 'KRW';
        pbeOption.IsActive = true;
        pbeOption.product2Id = option.Id;

        List<PricebookEntry> pbes = new List<PricebookEntry>{pbeModel,  pbeOption};
        insert pbes;

        Boolean mandatoryOption  = true;
        Decimal priceOverride = 150;
        Product_Option_Mapping__c pom = TestClass_ProductOptionMapping.buildProductOptionMapping(model, option, mandatoryOption, priceOverride);
        insert pom;


        
        
        /*
        
        
        Set<Id> oliIds = new Set<Id>{oli1.Id, oli2.Id}; //j[]
            //run OpportunityProductLookupSetter SetMakeAndModel method passing in list of Opportunity Line Items
            OpportunityProductLookupSetter opls = new OpportunityProductLookupSetter();
        oliList = [SELECT Product2Id, Product2.Make__c FROM OpportunityLineItem WHERE Id IN :oliIds];
        */
        
    }

    public static OpportunityLineItem buildLineItem(Opportunity opportunity, PriceBookEntry pbe, Product2  product ) {
        OpportunityLineItem opportunityLineItem = new OpportunityLineItem();
        
        opportunityLineItem.PricebookEntryId = pbe.Id;
        opportunityLineItem.OpportunityId = opportunity.Id;   
        opportunityLineItem.Quantity = 1;
        opportunityLineItem.TotalPrice = 50;
        
        
        return opportunityLineItem;
    }

    
    
    @isTest 
    public static void Test_MandatoryOptionIsAppliedAutomaticallyNew() {

        Product2 product = [SELECT Id FROM Product2 WHERE Name = 'test model' LIMIT 1];
        Product2 option = [SELECT Id FROM Product2 WHERE Name = 'option' LIMIT 1];
        Opportunity opp1 = [SELECT Id FROM Opportunity WHERE Name = 'test1' LIMIT 1];

        PriceBookEntry pbeOption = [SELECT Id FROM PricebookEntry WHERE Product2Id = :option.Id LIMIT 1];
        PriceBookEntry pbeProduct = [SELECT Id FROM PricebookEntry WHERE Product2Id = :product.Id LIMIT 1];


        OpportunityLineItem oli1 = buildLineItem(opp1, pbeProduct, product);
        
        List<OpportunityLineItem> olis = new List<OpportunityLineItem>{oli1};

        Test.startTest();
        insert olis;
        //OpportunityProductOptionHandler.setMandatoryProductOptions(olis);
        Test.stopTest();

        //List<OpportunityLineItem> olis_out = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :opp1.Id];
        //Assert.areEqual(2, olis_out.size());

    }

    @isTest 
    public static void Test_MandatoryOptionRemovedAutomatically() {

        Product2 product = [SELECT Id FROM Product2 WHERE Name = 'test model' LIMIT 1];
        Product2 option = [SELECT Id FROM Product2 WHERE Name = 'option' LIMIT 1];
        Opportunity opp1 = [SELECT Id FROM Opportunity WHERE Name = 'test1' LIMIT 1];

        PriceBookEntry pbeOption = [SELECT Id FROM PricebookEntry WHERE Product2Id = :option.Id LIMIT 1];
        PriceBookEntry pbeProduct = [SELECT Id FROM PricebookEntry WHERE Product2Id = :product.Id LIMIT 1];


        OpportunityLineItem oli1 = buildLineItem(opp1, pbeProduct, product);
        
        List<OpportunityLineItem> olis = new List<OpportunityLineItem>{oli1};
        insert olis;

        Test.startTest();
        delete oli1;
        //OpportunityProductOptionHandler.setMandatoryProductOptions(olis);
        Test.stopTest();

        //List<OpportunityLineItem> olis_out = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId = :opp1.Id];
        //Assert.areEqual(2, olis_out.size());

    }


}