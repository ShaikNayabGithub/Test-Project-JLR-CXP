public class BRS_PicklistAdapter {
    private final BRS_PicklistGroup_F picklistGroupFactory;
    private final BRS_FeatureSecondaryKeyExtractor secondaryKeyExtractor;


    public BRS_PicklistAdapter(BRS_PicklistGroup_F picklistGroupFactory,
            BRS_FeatureSecondaryKeyExtractor secondaryKeyExtractor)
    {
        this.picklistGroupFactory = picklistGroupFactory;
        this.secondaryKeyExtractor = secondaryKeyExtractor;
    }


    public Map<String, BRS_PicklistGroup_A> Adapt(Map<BRS_Service.Feature, BRS_Request__c> features)
    {
    	Map<String, BRS_PicklistGroup_A> picklistMap = new Map<String, BRS_PicklistGroup_A>();
    	
    	for(BRS_Service.Feature feature : features.KeySet()){
    		BRS_FeatureGroupFieldMappingByCode__c featureGroupSetting = BRS_FeatureUtilities.FeatureGroupFieldMappingByCode.get(feature.FeatureGroup);
    		if(featureGroupSetting == null) { continue; }
    		
    		String picklistName = featureGroupSetting.Field_Name__c;
            if(featureGroupSetting.Is_Local__c) { 
                picklistName = Schema.SObjectType.Asset.getName() + '.' + picklistName;
            }
    		
    		BRS_PicklistGroup_A picklistGroup = picklistMap.get(picklistName);
    		if(picklistGroup == null) {
                picklistGroup = this.picklistGroupFactory.Create(picklistName, featureGroupSetting.Is_Local__c);
    			picklistMap.put(picklistName, picklistGroup);
    		}
    		
            String picklistKey = this.secondaryKeyExtractor.GetPicklistKey(feature);
    		picklistGroup.AddPicklistValue(picklistKey, features.get(feature));
    	}
    	
    	this.AddExistingPicklistValues(picklistMap);
    	return picklistMap;
    }
    
    
    private void AddExistingPicklistValues(Map<String, BRS_PicklistGroup_A> picklistMap)
    {
    	Map<String, Schema.SObjectField> product2Fields = Schema.SObjectType.Asset.fields.getMap();
    	for(String picklistName : picklistMap.KeySet()) {
            Boolean isLocal = picklistName.contains('.');
            String picklistLocalName = picklistName + '__c';
            if(isLocal) {
                String[] splitName = picklistName.split('\\.');
                picklistLocalName = splitName[splitName.size() - 1];
            }
    		
    		BRS_PicklistGroup_A picklistGroup = picklistMap.get(picklistName);
    		if(picklistGroup == null) { 
                picklistGroup = this.picklistGroupFactory.Create(picklistName, isLocal);
    			picklistMap.put(picklistName, picklistGroup);
			}
    		
    		Schema.DescribeFieldResult picklistDescription = product2Fields.get(picklistLocalName).getDescribe();
    		List<Schema.PicklistEntry> picklistValues = picklistDescription.getPicklistValues();
    		
    		for(Schema.PicklistEntry picklistValue : picklistValues) {
    			picklistGroup.AddPicklistValue(picklistValue.getValue());
    		}
    	}
    }
}