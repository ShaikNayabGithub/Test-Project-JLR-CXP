public class BRS_ProductCreator_Factory {
    public BRS_ProductCreator Build()
    {
    	ProductMatcher productMatcher = new ProductMatcher();
    	BRS_EnhancedUpserter upserter = new BRS_EnhancedUpserter();
    	JSONDeserializer deserializer = new JSONDeserializer();
        BRS_FeatureSecondaryKeyExtractor secondaryKeyExtractor = new BRS_FeatureSecondaryKeyExtractor();
    	
    	BRS_Product_Adapter_I derivativeAdapter = new BRS_DerivativeToProduct_Adapter();
    	BRS_Product_Adapter_I modelAdapter = new BRS_ModelToProduct_Adapter(deserializer, secondaryKeyExtractor);
    	
    	BRS_ProductRecordTypeSpecificCreator modelCreator = new BRS_ProductRecordTypeSpecificCreator(modelAdapter, productMatcher, upserter);
    	BRS_ProductRecordTypeSpecificCreator derivativeCreator = new BRS_ProductRecordTypeSpecificCreator(derivativeAdapter, productMatcher, upserter);
    	BRS_PricebookEntryCreator pricebookEntryCreator = new BRS_PricebookEntryCreator(upserter, deserializer);
    	
    	return new BRS_ProductCreator(modelCreator, derivativeCreator, pricebookEntryCreator);
    }
}