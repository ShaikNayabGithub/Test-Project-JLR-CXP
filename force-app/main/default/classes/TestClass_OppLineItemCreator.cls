@isTest
public class TestClass_OppLineItemCreator {
    
    public static OpportunityLineItem CreateOppLineItem(){
    	//OpportunityLineItem requires an Opportunity and a Pricebook Entry
    	Opportunity opp = TestClass_ValidOpportunityBuilder.Build();
    	insert opp;
    	return CreateOppLineItem(opp.Id, null, null);
    }
    
    public static OpportunityLineItem CreateOppLineItem(Id opportunityId, Id vehicleSpecId, Id modelId){
    	//createPricebookEntry() inserts the PricebookEntry for us so just create the OppLineItem
    	PricebookEntry pbe = CreatePricebookEntry(vehicleSpecId, modelId);
    	OpportunityLineItem oli = new OpportunityLineItem(OpportunityId=opportunityId, Quantity=1, PricebookEntryId=pbe.Id, TotalPrice=1);
    	return oli;
    }
    
    public static PricebookEntry CreatePricebookEntry(Id vehicleSpecId, Id modelId){
    	//create a Product
    	Product2 prod = new Product2(Name='Test Product', ProductCode='test', isActive=true);
    	prod.Make__c = vehicleSpecId;
    	prod.Model__c = modelId; 	
    	insert prod;
    	//create a Pricebook Entry
    	PricebookEntry pbe = new PricebookEntry(Pricebook2Id=Test.getStandardPricebookId(), Product2Id=prod.Id,UnitPrice=1,IsActive=true);
    	insert pbe;
    	return pbe;
    }

	public static PricebookEntry CreatePricebookEntryForCurrency(Id product2Id, String currencyIsoCode){
    	
    	PricebookEntry pbe = new PricebookEntry(Pricebook2Id=Test.getStandardPricebookId(), Product2Id=product2Id, UnitPrice=1,IsActive=true, CurrencyIsoCode = currencyIsoCode);
    	insert pbe;
    	return pbe;
    }

	public static OpportunityLineItem CreateOppLineItemForCurrency(Id opportunityId, Id product2Id, String currencyIsoCode){
    	//createPricebookEntry() inserts the PricebookEntry for us so just create the OppLineItem
    	PricebookEntry pbe = CreatePricebookEntryForCurrency(product2Id, currencyIsoCode);
    	OpportunityLineItem oli = new OpportunityLineItem(OpportunityId=opportunityId, Quantity=1, PricebookEntryId=pbe.Id, TotalPrice=1);
    	return oli;
    }

}