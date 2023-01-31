public class BRS_TranslationAdapter {
    private final BRS_TranslationGroup_F translationGroupFactory;
    private final BRS_FeatureSecondaryKeyExtractor featureSecondaryKeyExtractor;

	private static final Map<String, BRSToSFLangaugeCodeMapping__c> LANGUAGE_MAPPINGS = BRSToSFLangaugeCodeMapping__c.getAll();
	

    public BRS_TranslationAdapter(BRS_TranslationGroup_F translationGroupFactory,
            BRS_FeatureSecondaryKeyExtractor featureSecondaryKeyExtractor)
    {
        this.translationGroupFactory = translationGroupFactory;
        this.featureSecondaryKeyExtractor = featureSecondaryKeyExtractor;
    }

	
    public Map<String, BRS_TranslationGroup_A> Adapt(Map<BRS_Service.Feature, BRS_Request__c> features)
    {
    	Map<String, BRS_TranslationGroup_A> translationMap = new Map<String, BRS_TranslationGroup_A>();
    	
    	for(BRS_Service.Feature feature : features.KeySet()){
    		this.AddTranslationsToMap(feature, translationMap, features.get(feature));
    	}
    	
    	return translationMap;
    }
    
    
    private void AddTranslationsToMap(BRS_Service.Feature feature, Map<String, BRS_TranslationGroup_A> translationMap, BRS_Request__c request)
    {
    	if(feature.Descriptions == null) { return; }
    	
    	BRS_FeatureGroupFieldMappingByCode__c featureGroupSetting = BRS_FeatureUtilities.FeatureGroupFieldMappingByCode.get(feature.FeatureGroup);
		if(featureGroupSetting == null) { return; }
		String picklistName = featureGroupSetting.Field_Name__c;
        String picklistValueKey = this.featureSecondaryKeyExtractor.GetPicklistKey(feature);
		
		for(BRS_Service.Description description : feature.Descriptions) {
			BRSToSFLangaugeCodeMapping__c languageMapping = LANGUAGE_MAPPINGS.get(description.Language);
			if(languageMapping == null) { continue; }
            String mapKey = languageMapping.SF_Value__c + featureGroupSetting.Is_Local__c;
			
			BRS_TranslationGroup_A translationGroup = translationMap.get(mapKey);
    		if(translationGroup == null) {
    			translationGroup = this.translationGroupFactory.Create(languageMapping.SF_Value__c, 
                        featureGroupSetting.Is_Local__c);
    			translationMap.put(mapKey, translationGroup);
    		}
    		
    		translationGroup.AddPicklistValueTranslation(picklistName, picklistValueKey, description.Text, request);
		}
    }
}