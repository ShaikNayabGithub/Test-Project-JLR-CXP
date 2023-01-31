public class BRS_FeatureCreator {
	private final BRS_FeatureExtractor featureExtractor;
	private final BRS_PicklistAdapter picklistAdapter;
	private final BRS_TranslationAdapter translationAdapter;
	private final BRS_RecordTypeAdapter recordTypeAdapter;
	private final BRS_MetadataUpserter metadataUpserter;
	

	public BRS_FeatureCreator(BRS_FeatureExtractor featureExtractor, BRS_PicklistAdapter picklistAdapter, BRS_TranslationAdapter translationAdapter, BRS_RecordTypeAdapter recordTypeAdapter, BRS_MetadataUpserter metadataUpserter) {
		this.featureExtractor = featureExtractor;
		this.picklistAdapter = picklistAdapter;
		this.translationAdapter = translationAdapter;
		this.recordTypeAdapter = recordTypeAdapter;
		this.metadataUpserter = metadataUpserter;
	}
	

	public void Create(List<BRS_Request__c> requests)
	{
		Map<BRS_Service.Feature, BRS_Request__c> features = this.featureExtractor.Extract(requests);
		
		Map<String, BRS_PicklistGroup_A> picklists = this.picklistAdapter.Adapt(features);
		Map<String, BRS_TranslationGroup_A> translations = this.translationAdapter.Adapt(features);
		Map<String, BRS_RecordTypeGroup> recordTypes = this.recordTypeAdapter.Adapt(picklists);
		
		this.metadataUpserter.SetSessionId();
		this.metadataUpserter.UpsertMetadata(picklists);
		this.metadataUpserter.UpsertMetadata(translations);
		this.metadataUpserter.UpsertMetadata(recordTypes);
	}
}