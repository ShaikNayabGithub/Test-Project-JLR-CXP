@isTest
public with sharing class VistaProductSearchController_Test {

    static testMethod void Search_ValidSearchStringWithPricebook_ReturnsDerivativeByName(){
        Product2 derivative = new Product2(Name='TestDerivative', RecordTypeId=Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Derivative').getRecordTypeId());
        insert derivative;
        
        TestClass_PriceBookEntryBuilder.BuildPriceBookEntry(TestClass_PriceBookCreator.CreatePricebook(), derivative);

        VistaProductSearchController derivSearch = new VistaProductSearchController();
        derivSearch.searchString = 'TestDerivative';
        derivSearch.SetDerivativeSearch();
        derivSearch.Search();
        System.assertEquals(derivative.Id, derivSearch.SearchResults[0].Id);
    }
    
    static testMethod void Search_ValidWildcardSearchStringWithPricebook_ReturnsDerivativeByName(){
        Product2 derivative = new Product2(Name='TestDerivative', RecordTypeId=Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Derivative').getRecordTypeId());
        insert derivative;
        
        TestClass_PriceBookEntryBuilder.BuildPriceBookEntry(TestClass_PriceBookCreator.CreatePricebook(), derivative);

        VistaProductSearchController derivSearch = new VistaProductSearchController();
        derivSearch.searchString = 'Test';
        derivSearch.SetDerivativeSearch();
        derivSearch.Search();
        System.assertEquals(derivative.Id, derivSearch.SearchResults[0].Id);
    }
    
    static testMethod void Search_ValidSearchStringNoPricebook_ReturnsNoDerivatives(){
        Product2 derivative = new Product2(Name='TestDerivative', RecordTypeId=Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Derivative').getRecordTypeId());
        insert derivative;
        VistaProductSearchController derivSearch = new VistaProductSearchController();
        derivSearch.searchString = 'TestDerivative';
        derivSearch.SetDerivativeSearch();
        derivSearch.Search();
        System.assertEquals(0, derivSearch.SearchResults.size());
    }
    
    static testMethod void Search_ValidSearchStringWithPricebook_ReturnsMaxNumResults(){
        List<Product2> derivatives = new List<Product2>();
        derivatives.add(new Product2(Name='TestDerivative1', RecordTypeId=Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Derivative').getRecordTypeId()));
        derivatives.add(new Product2(Name='TestDerivative2', RecordTypeId=Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Derivative').getRecordTypeId()));
        derivatives.add(new Product2(Name='TestDerivative3', RecordTypeId=Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Derivative').getRecordTypeId()));
        insert derivatives;
        
        Pricebook2 pb = TestClass_PriceBookCreator.CreatePricebook();
        for(Product2 d : derivatives){
            TestClass_PriceBookEntryBuilder.BuildPriceBookEntry(pb, d);
        }
        
        VistaProductSearchController derivSearch = new VistaProductSearchController();
        derivSearch.SetMaxResults(2);
        derivSearch.searchString = 'TestDerivative';
        derivSearch.SetDerivativeSearch();
        derivSearch.Search();
        System.assertEquals(2, derivSearch.SearchResults.size());       
    }
    
    static testMethod void Search_ValidSearchStringWithPricebook_ReturnsModelByName(){
        Product2 model = new Product2(Name='TestModel', RecordTypeId=Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Model').getRecordTypeId());
        insert model;
        
        TestClass_PriceBookEntryBuilder.BuildPriceBookEntry(TestClass_PriceBookCreator.CreatePricebook(), model);

        VistaProductSearchController derivSearch = new VistaProductSearchController();
        derivSearch.searchString = 'TestModel';
        derivSearch.SetModelSearch();
        derivSearch.Search();
        System.assertEquals(model.Id, derivSearch.SearchResults[0].Id);             
    }
    
}