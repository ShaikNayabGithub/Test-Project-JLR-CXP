public class BRS_TranslationGroup_Local extends BRS_TranslationGroup_A {
	private final SF_MetadataAPI.CustomObjectTranslation objectTranslation;
	private final Map<String, SF_MetadataAPI.CustomFieldTranslation> picklists;
	private Map<String, Map<String, SF_MetadataAPI.PicklistValueTranslation>> picklistValues;


	public BRS_TranslationGroup_Local(String sObjectName, String language)
    {
    	super(new SF_MetadataAPI.CustomObjectTranslation());
    	this.Metadata.API_Version = '39.0';
    	this.objectTranslation = (SF_MetadataAPI.CustomObjectTranslation)this.Metadata;
    	this.objectTranslation.fullName = sObjectName + '-' + language;
    	this.objectTranslation.fields = new List<SF_MetadataAPI.CustomFieldTranslation>();
    	this.picklists = new Map<String, SF_MetadataAPI.CustomFieldTranslation>();
    	this.picklistValues = new Map<String, Map<String, SF_MetadataAPI.PicklistValueTranslation>>();
    }


    public override void AddPicklistValueTranslation(String picklistName, String picklistValue, 
    		String translation, BRS_Request__c request)
    {
    	SF_MetadataAPI.CustomFieldTranslation picklist = this.picklists.get(picklistName);
    	if(picklist == null) { 
    		picklist = new SF_MetadataAPI.CustomFieldTranslation();
    		picklist.name = picklistName;
    		picklist.picklistValues = new List<SF_MetadataAPI.PicklistValueTranslation>();

    		this.objectTranslation.fields.add(picklist);
    		this.picklists.put(picklistName, picklist);
    		this.picklistValues.put(picklistName, new Map<String, SF_MetadataAPI.PicklistValueTranslation>());
    	}

    	SF_MetadataAPI.PicklistValueTranslation picklistValueTranslation = picklistValues.get(picklistName).get(picklistValue);
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
        return true;
    }
}