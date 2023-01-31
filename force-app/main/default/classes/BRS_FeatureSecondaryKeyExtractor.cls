public class BRS_FeatureSecondaryKeyExtractor {
    public String GetPicklistKey(BRS_Service.Feature feature)
    {
        BRS_FeatureGroupFieldMappingByCode__c featureGroupSetting = BRS_FeatureUtilities.FeatureGroupFieldMappingByCode.get(feature.FeatureGroup);

        String key = feature.Code;
        if(featureGroupSetting == null || !featureGroupSetting.Is_Local__c) { return key; } 

        for(BRS_Service.Description description : feature.Descriptions) {
            key = description.Text;
            if(description.Language == 'EN') { break; }
        }

        return key;
    }

    public KeyValuePair_LanguageSpecific ConvertToKeyValuePair(BRS_Service.Feature feature)
    {
        BRS_FeatureGroupFieldMappingByCode__c featureGroupSetting = BRS_FeatureUtilities.FeatureGroupFieldMappingByCode.get(feature.FeatureGroup);

        KeyValuePair_LanguageSpecific keyValuePair = new KeyValuePair_LanguageSpecific();
        keyValuePair.Key = feature.Code;
        
        System.debug('feature.FeatureGroup value: '+feature.FeatureGroup);

        if(feature.FeatureGroup!='TRIM' &&  (featureGroupSetting == null || !featureGroupSetting.Is_Local__c)) { return keyValuePair; } 

        for(BRS_Service.Description description : feature.Descriptions) {
        
            keyValuePair.Value = description.Text;
            keyValuePair.LanguageCode = description.Language;
            if(description.Language == 'EN') { break; }
        }

        return keyValuePair;
    }
}