public class BRS_RequestProcessor_Batchable_Factory {
	public BRS_RequestProcessor_Batchable Build() {
		BRS_FeatureCreator_Factory featureCreatorFactory = new BRS_FeatureCreator_Factory();
		
		BRS_FeatureCreator featureCreator = featureCreatorFactory.Build();
		BRS_RequestPostProcessor requestPostProcessor = new BRS_RequestPostProcessor(BRSRequestUtilities.FeaturesAddedStatus);
		
		return new BRS_RequestProcessor_Batchable(featureCreator, requestPostProcessor);
	}
}