public class BRS_TranslationGroup_Global extends BRS_TranslationGroup_A{
	public SF_MetadataAPI.Translations Translations { public get; private set; }
    private Map<String, SF_MetadataAPI.GlobalPicklistTranslation> Picklists;
    private Map<String, Map<String, SF_MetadataAPI.PicklistValueTranslation>> PicklistValues;
    
    
    public BRS_TranslationGroup_Global(String language)
    {
    	super(new SF_MetadataAPI.Translations());
    	this.Metadata.API_Version = '37.0';
    	this.Translations = (SF_MetadataAPI.Translations)this.Metadata;
    	this.Translations.fullName = language;
    	this.Translations.globalPicklists = new List<SF_MetadataAPI.GlobalPicklistTranslation>();
    	this.Picklists = new Map<String, SF_MetadataAPI.GlobalPicklistTranslation>();
    	this.PicklistValues = new Map<String, Map<String, SF_MetadataAPI.PicklistValueTranslation>>();
    }
    
    
    public override void AddPicklistValueTranslation(String picklistName, String picklistValue, String translation, BRS_Request__c request)
    {
    	SF_MetadataAPI.GlobalPicklistTranslation picklist = Picklists.get(picklistName);
    	if(picklist == null) {
    		picklist = new SF_MetadataAPI.GlobalPicklistTranslation();
    		picklist.name = picklistName;
    		picklist.picklistValues = new List<SF_MetadataAPI.PicklistValueTranslation>();
    		this.Translations.globalPicklists.Add(picklist);
    		this.Picklists.put(picklistName, picklist);
    		this.PicklistValues.put(picklistName, new Map<String, SF_MetadataAPI.PicklistValueTranslation>());
    	}
    	
    	SF_MetadataAPI.PicklistValueTranslation picklistValueTranslation = PicklistValues.get(picklistName).get(picklistValue);
    	if(picklistValueTranslation == null) {
    		picklistValueTranslation = new SF_MetadataAPI.PicklistValueTranslation();
    		picklistValueTranslation.masterLabel = picklistValue;
    		picklistValueTranslation.translation = translation;
    		picklist.picklistValues.Add(picklistValueTranslation);
    		this.PicklistValues.get(picklistName).put(picklistValue, picklistValueTranslation);
    	}
    	
    	if(!this.Requests.ContainsKey(request.Id)) {
			this.Requests.put(request.Id, request);
		}
    }

    public override Boolean GetIsLocal()
    {
        return false;
    }
}