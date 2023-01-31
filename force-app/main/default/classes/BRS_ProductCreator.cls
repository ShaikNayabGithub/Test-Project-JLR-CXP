public class BRS_ProductCreator {
	private final BRS_ProductRecordTypeSpecificCreator modelCreator;
	private final BRS_ProductRecordTypeSpecificCreator derivativeCreator;
	private final BRS_PricebookEntryCreator pricebookEntryCreator;
	
	
	public BRS_ProductCreator(BRS_ProductRecordTypeSpecificCreator modelCreator, BRS_ProductRecordTypeSpecificCreator derivativeCreator, BRS_PricebookEntryCreator pricebookEntryCreator) {
		this.modelCreator = modelCreator;
		this.derivativeCreator = derivativeCreator;
		this.pricebookEntryCreator = pricebookEntryCreator;
	}


	public void Create(List<BRS_Request__c> requests)
	{
		BRS_RequestCollection requestCollection = new BRS_RequestCollection();
		requestCollection.Requests = new Map<Id, BRS_Request__c>(requests);

		this.modelCreator.Create(requestCollection);
		ProductUtilities.SetModelMap();
		
		this.derivativeCreator.Create(requestCollection);		
		this.pricebookEntryCreator.Create(requestCollection);
	}
}