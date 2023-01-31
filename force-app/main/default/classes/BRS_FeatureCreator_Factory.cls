public class BRS_FeatureCreator_Factory {
    public BRS_FeatureCreator Build()
    {
    	JSONDeserializer deserializer = new JSONDeserializer();
    	
    	SF_MetadataAPIPort_Factory metadataServicePortFactory = new SF_MetadataAPIPort_Factory();
    	SF_MetadataAPI.MetadataPort metadataPort = metadataServicePortFactory.Build();
        BRS_PicklistGroup_F picklistGroupFactory = new BRS_PicklistGroup_F();
        BRS_TranslationGroup_F translationGroupFactory = new BRS_TranslationGroup_F();
        BRS_FeatureSecondaryKeyExtractor secondaryKeyExtractor = new BRS_FeatureSecondaryKeyExtractor();
    	
    	BRS_FeatureExtractor featureExtractor = new BRS_FeatureExtractor(deserializer);
    	BRS_PicklistAdapter picklistAdapter = new BRS_PicklistAdapter(picklistGroupFactory, secondaryKeyExtractor);
		BRS_TranslationAdapter translationAdapter = new BRS_TranslationAdapter(translationGroupFactory, secondaryKeyExtractor);
		BRS_RecordTypeAdapter recordTypeAdapter = new BRS_RecordTypeAdapter();
		BRS_MetadataUpserter metadataUpserter = new BRS_MetadataUpserter(metadataPort);
    	
    	return new BRS_FeatureCreator(featureExtractor, picklistAdapter, translationAdapter, recordTypeAdapter, metadataUpserter);
    }
}