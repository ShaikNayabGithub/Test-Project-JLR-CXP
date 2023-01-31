public class Vista_ExistingRecordRetriever_F {
	public Vista_ExistingRecordRetriever Create()
	{
		Set<Vista_EntityRetriever_I> entityRetrievers = new Set<Vista_EntityRetriever_I>();

		Vista_OrderRetriever orderRetriever = new Vista_OrderRetriever();
		Vista_AssetRetriever assetRetriever = new Vista_AssetRetriever();
		Vista_DerivativeRetriever derivativeRetriever = new Vista_DerivativeRetriever();
		Vista_RetailerRetriever retailerRetriever = new Vista_RetailerRetriever();
		Vista_OpportunityLineItemRetriever opportunityLineItemRetriever = new Vista_OpportunityLineItemRetriever();
		Vista_OrderItemRetriever orderItemRetriever = new Vista_OrderItemRetriever();
		Vista_PricebookEntryRetriever pricebookEntryRetriever = new Vista_PricebookEntryRetriever();

		entityRetrievers.add(orderRetriever);
		entityRetrievers.add(assetRetriever);
		entityRetrievers.add(derivativeRetriever);
		entityRetrievers.add(retailerRetriever);
		entityRetrievers.add(opportunityLineItemRetriever);
		entityRetrievers.add(orderItemRetriever);
		entityRetrievers.add(pricebookEntryRetriever);

		return new Vista_ExistingRecordRetriever(entityRetrievers);
	}
}