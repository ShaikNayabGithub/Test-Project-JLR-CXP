public class BRS_RequestProcessor_Products_BatchF {
	public BRS_RequestProcessor_Products_Batch Build() {
		BRS_ProductCreator_Factory productCreatorFactory = new BRS_ProductCreator_Factory();
		
		BRS_ProductCreator productCreator = productCreatorFactory.Build();
		BRS_RequestPostProcessor requestPostProcessor = new BRS_RequestPostProcessor(BRSRequestUtilities.SuccessStatus);
		
		return new BRS_RequestProcessor_Products_Batch(productCreator, requestPostProcessor);
	}
}