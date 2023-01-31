@isTest
public class OpportunityProductLookupSetter_Test{
    
    static testMethod void testMakeForOppLineItems(){
        //create list of OpportunityLineItem to test
        //create list of Opportunities (for the same Account using Utility methods)
        Opportunity opp1 = TestClass_ValidOpportunityBuilder.Build();
        opp1.Name = 'test1';
        Opportunity opp2 = TestClass_ValidOpportunityBuilder.Build();
        opp2.Name = 'test2';
        List<Opportunity> oppList = new List<Opportunity>{opp1, opp2};
            insert oppList;
        Pricebook2 pb = TestClass_PricebookCreator.CreatePricebook(); //TestClass_PricebookCreator saves Pricebook
        //create OpportunityLineItems
        Vehicle_Specification__c  make = TestClass_VehicleSpecificationBuilder.BuildMake();
        Product2  model = TestClass_ProductBuilder.BuildModel(make);
        
        
        OpportunityLineItem oli1 = BuildLineItemWithoutbrand(opp1, pb,make,model);
        OpportunityLineItem oli2 = BuildLineItemWithoutbrand(opp2, pb,make,model);
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>{oli1, oli2};
            system.debug('Opp line items'+oliList );
        
        insert oliList;
        
        Test.startTest();
        Set<Id> oliIds = new Set<Id>{oli1.Id, oli2.Id}; //j[]
            //run OpportunityProductLookupSetter SetMakeAndModel method passing in list of Opportunity Line Items
            OpportunityProductLookupSetter opls = new OpportunityProductLookupSetter();
        oliList = [SELECT Product2Id, Product2.Make__c FROM OpportunityLineItem WHERE Id IN :oliIds];
        //opls.SetMakeAndModel(oliList); //run the update method
        //update oliList; //save the OpportunityLineItems
        Test.stopTest();
        //for each OppLineItem, ensure the Brand has been set correctly
        oliList = [SELECT Id FROM OpportunityLineItem WHERE Id IN :oliIds AND Brand__c=:make.Id];
        System.assertEquals(2, oliList.size()); 
    }
    
    static testMethod void testModelForOppLineItems(){
        //create list of OpportunityLineItem to test
        //create list of Opportunities (for the same Account using Utility methods)
        Opportunity opp1 = TestClass_ValidOpportunityBuilder.Build();
        opp1.Name = 'test1';
        Opportunity opp2 = TestClass_ValidOpportunityBuilder.Build();
        opp2.Name = 'test2';
        List<Opportunity> oppList = new List<Opportunity>{opp1, opp2};
            insert oppList;
        Pricebook2 pb = TestClass_PricebookCreator.CreatePricebook(); //TestClass_PricebookCreator saves Pricebook
        //create OpportunityLineItems
        Vehicle_Specification__c  make = TestClass_VehicleSpecificationBuilder.BuildMake();
        Product2  model = TestClass_ProductBuilder.BuildModel(make);
        
        
        OpportunityLineItem oli1 = BuildLineItemWithoutbrand(opp1, pb,make,model);
        OpportunityLineItem oli2 = BuildLineItemWithoutbrand(opp2, pb,make,model);
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>{oli1, oli2};
            insert oliList;
        //each product requires a Vehicle Specification and a Model
        
        Set<Id> oliIds = new Set<Id>{oli1.Id, oli2.Id}; //because we need to retrieve our newly created OpportunityLineItems, store the new ids in a set to pass to the soql
            oliList = [SELECT Product2Id FROM OpportunityLineItem WHERE Id IN :oliIds]; //OpportunityProductLookupSetter uses Product2Id as a map key so we need to retrieve it
        Set<Id> prodIds = new Set<Id>();
        for(OpportunityLineItem oli : oliList){
            prodIds.add(oli.Product2Id);
        }
        
        
        oliList = [SELECT Id FROM OpportunityLineItem WHERE Id IN :oliIds AND Model__c=:model.Id];
        System.assertEquals(2, oliList.size());
    }
    
    static testMethod void testModelForOppLineItemsUpdate(){
        //create list of OpportunityLineItem to test
        //create list of Opportunities (for the same Account using Utility methods)
        Opportunity opp1 = TestClass_ValidOpportunityBuilder.Build();
        opp1.Name = 'test1';
        Opportunity opp2 = TestClass_ValidOpportunityBuilder.Build();
        opp2.Name = 'test2';
        List<Opportunity> oppList = new List<Opportunity>{opp1, opp2};
            insert oppList;
        Pricebook2 pb = TestClass_PricebookCreator.CreatePricebook(); //TestClass_PricebookCreator saves Pricebook
        //create OpportunityLineItems
        Vehicle_Specification__c  make = TestClass_VehicleSpecificationBuilder.BuildMake();
        Product2  model = TestClass_ProductBuilder.BuildModel(make);
        
        
        OpportunityLineItem oli1 = BuildLineItemWithoutbrand(opp1, pb,make,model);
        OpportunityLineItem oli2 = BuildLineItemWithoutbrand(opp2, pb,make,model);
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>{oli1, oli2};
            insert oliList;
        Test.startTest();
        update oliList;
        Test.stopTest();
        //each product requires a Vehicle Specification and a Model
        
        Set<Id> oliIds = new Set<Id>{oli1.Id, oli2.Id}; //because we need to retrieve our newly created OpportunityLineItems, store the new ids in a set to pass to the soql
            oliList = [SELECT Product2Id FROM OpportunityLineItem WHERE Id IN :oliIds]; //OpportunityProductLookupSetter uses Product2Id as a map key so we need to retrieve it
        Set<Id> prodIds = new Set<Id>();
        for(OpportunityLineItem oli : oliList){
            prodIds.add(oli.Product2Id);
        }
        
        
        oliList = [SELECT Id FROM OpportunityLineItem WHERE Id IN :oliIds AND Model__c=:model.Id];
        System.assertEquals(2, oliList.size());
    }
    
    static testMethod void testModelForOppLineItemsDelete(){
        //create list of OpportunityLineItem to test
        //create list of Opportunities (for the same Account using Utility methods)
        Opportunity opp1 = TestClass_ValidOpportunityBuilder.Build();
        opp1.Name = 'test1';
        Opportunity opp2 = TestClass_ValidOpportunityBuilder.Build();
        opp2.Name = 'test2';
        List<Opportunity> oppList = new List<Opportunity>{opp1, opp2};
            insert oppList;
        Pricebook2 pb = TestClass_PricebookCreator.CreatePricebook(); //TestClass_PricebookCreator saves Pricebook
        //create OpportunityLineItems
        Vehicle_Specification__c  make = TestClass_VehicleSpecificationBuilder.BuildMake();
        Product2  model = TestClass_ProductBuilder.BuildModel(make);
        
        
        OpportunityLineItem oli1 = BuildLineItemWithoutbrand(opp1, pb,make,model);
        OpportunityLineItem oli2 = BuildLineItemWithoutbrand(opp2, pb,make,model);
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>{oli1, oli2};
            insert oliList;
        Test.startTest();
        delete oliList[0];
        Test.stopTest();
        //each product requires a Vehicle Specification and a Model
        
        Set<Id> oliIds = new Set<Id>{oli1.Id, oli2.Id}; //because we need to retrieve our newly created OpportunityLineItems, store the new ids in a set to pass to the soql
            oliList = [SELECT Product2Id FROM OpportunityLineItem WHERE Id IN :oliIds]; //OpportunityProductLookupSetter uses Product2Id as a map key so we need to retrieve it
        Set<Id> prodIds = new Set<Id>();
        for(OpportunityLineItem oli : oliList){
            prodIds.add(oli.Product2Id);
        }
        
        
        oliList = [SELECT Id FROM OpportunityLineItem WHERE Id IN :oliIds AND Model__c=:model.Id];
       // System.assertEquals(2, oliList.size());
    }
    public static OpportunityLineItem BuildLineItemWithoutbrand(Opportunity opportunity, PriceBook2 priceBook, Vehicle_Specification__c  make, Product2  model ) {
        OpportunityLineItem opportunityLineItem = new OpportunityLineItem();
        
        
        
        PricebookEntry  pricebookEntry = TestClass_PriceBookEntryBuilder.BuildPriceBookEntry(priceBook, 'test', model, make);
        
        opportunityLineItem.PricebookEntryId = pricebookEntry.Id;
        opportunityLineItem.OpportunityId = opportunity.Id;   
        opportunityLineItem.Quantity = 1;
        opportunityLineItem.TotalPrice = 1;
        
        return opportunityLineItem;
    }
    
}