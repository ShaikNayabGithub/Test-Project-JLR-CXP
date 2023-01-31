public abstract class BRS_TranslationGroup_A extends BRS_MetadataGroup {
	protected BRS_TranslationGroup_A(SF_MetadataAPI.Metadata metadata)
	{
		super(metadata);
	}


	public abstract void AddPicklistValueTranslation(String picklistName, String picklistValue, 
			String translation, BRS_Request__c request);
	public abstract Boolean GetIsLocal();
}