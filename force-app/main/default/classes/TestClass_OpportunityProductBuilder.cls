@isTest
public class TestClass_OpportunityProductBuilder {

	public static Vehicle_Specification__c make;
	public static Product2 model;
	public static PricebookEntry pricebookEntry;

    public static OpportunityLineItem BuildLineItem(Opportunity opportunity, PriceBook2 priceBook) {
        OpportunityLineItem opportunityLineItem = new OpportunityLineItem();

        make = TestClass_VehicleSpecificationBuilder.BuildMake();
        model = TestClass_ProductBuilder.BuildModel(make);

        pricebookEntry = TestClass_PriceBookEntryBuilder.BuildPriceBookEntry(priceBook, 'test', model, make);

        opportunityLineItem.PricebookEntryId = pricebookEntry.Id;
        opportunityLineItem.OpportunityId = opportunity.Id;
        opportunityLineItem.Brand__c = make.Id;
        opportunityLineItem.Model__c = model.Id;
        opportunityLineItem.Quantity = 1;
        opportunityLineItem.TotalPrice = 1;

        return opportunityLineItem;
    }
}