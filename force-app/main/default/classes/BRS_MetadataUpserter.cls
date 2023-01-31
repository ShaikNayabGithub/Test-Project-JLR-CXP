public class BRS_MetadataUpserter {
	private final SF_MetadataAPI.MetadataPort metadataPort;
	private final SF_SessionIdRetriever sessionIdRetriever = new SF_SessionIdRetriever();
	
	
	public BRS_MetadataUpserter(SF_MetadataAPI.MetadataPort metadataPort)
	{
		this.metadataPort = metadataPort;
	}
	
	
    public void UpsertMetadata(Map<String, BRS_PicklistGroup_A> picklists)
    {
        Map<Boolean, List<BRS_PicklistGroup_A>> picklistsByIsLocal = new Map<Boolean, List<BRS_PicklistGroup_A>>();
        for(BRS_PicklistGroup_A picklist : picklists.values()) {
            List<BRS_PicklistGroup_A> subList = picklistsByIsLocal.get(picklist.GetIsLocal());
            if(subList == null) {
                subList = new List<BRS_PicklistGroup_A>();
                picklistsByIsLocal.put(picklist.GetIsLocal(), subList);
            }
            subList.add(picklist);
        }

        for(List<BRS_PicklistGroup_A> subGroup : picklistsByIsLocal.values()) {
            this.UpsertMetadata(subGroup);
        }
    }
    
    public void UpsertMetadata(Map<String, BRS_TranslationGroup_A> translations)
    {
        Map<Boolean, List<BRS_TranslationGroup_A>> translationsByIsLocal = new Map<Boolean, List<BRS_TranslationGroup_A>>();
        for(BRS_TranslationGroup_A translation : translations.values()) {
            List<BRS_TranslationGroup_A> subList = translationsByIsLocal.get(translation.GetIsLocal());
            if(subList == null) {
                subList = new List<BRS_TranslationGroup_A>();
                translationsByIsLocal.put(translation.GetIsLocal(), subList);
            }
            subList.add(translation);
        }

    	for(List<BRS_TranslationGroup_A> subGroup : translationsByIsLocal.values()) {
            this.UpsertMetadata(subGroup);
        }
    }
    
    public void UpsertMetadata(Map<String, BRS_RecordTypeGroup> recordTypes)
    {
    	this.UpsertMetadata(recordTypes.Values());
    }
    
    public void SetSessionId()
    {
    	this.metadataPort.SessionHeader.sessionId = this.sessionIdRetriever.RetrieveSessionId();
    }
    
    
    private void UpsertMetadata(List<BRS_MetadataGroup> metadataGroup)
    {
    	List<SF_MetadataAPI.Metadata> metadata = this.GetMetadata(metadataGroup);
    	if(metadata.Size() == 0) { return; }
    	
    	SF_MetadataAPI.UpsertResult[] results = this.metadataPort.upsertMetadata(metadata);
    	
    	for(Integer i = 0; i < results.Size(); i++) {
    		if(!results[i].success) {
    			for(BRS_Request__c request : metadataGroup[i].Requests.Values()) {
    				request.Status__c = BRSRequestUtilities.FailureStatus;
    				request.Error_Message__c += results[i].errors[0].message;//needs improvement
    			}
    		}
    	}
    }
    
    private List<SF_MetadataAPI.Metadata> GetMetadata(List<BRS_MetadataGroup> metadataGroups)
    {
    	List<SF_MetadataAPI.Metadata> metadata = new List<SF_MetadataAPI.Metadata>();
    	
    	for(BRS_MetadataGroup metadataGroup : metadataGroups) {
    		metadata.Add(metadataGroup.Metadata);
    	}
    	
    	return metadata;
    }
}