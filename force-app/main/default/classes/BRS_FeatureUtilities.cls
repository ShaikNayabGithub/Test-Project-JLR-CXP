public class BRS_FeatureUtilities {
	public static final Map<String, BRS_FeatureGroupFieldMappingByCode__c> FeatureGroupFieldMappingByCode = BRS_FeatureGroupFieldMappingByCode__c.getAll();
	
	
    public static Map<String, BRS_FeatureGroupFieldMappingByCode__c> FeatureGroupFieldMappingByFieldName { get {
    	if(FeatureGroupFieldMappingByFieldName == null) {
    		FeatureGroupFieldMappingByFieldName = SetFeatureGroupFieldMappingByFieldName();
    	}
    	return FeatureGroupFieldMappingByFieldName;
    } private set; }
    
    
    private static Map<String, BRS_FeatureGroupFieldMappingByCode__c> SetFeatureGroupFieldMappingByFieldName()
    {
    	Map<String, BRS_FeatureGroupFieldMappingByCode__c> fieldNameMap = new Map<String, BRS_FeatureGroupFieldMappingByCode__c>();
    	
    	for(BRS_FeatureGroupFieldMappingByCode__c setting : FeatureGroupFieldMappingByCode.Values()) {
    		fieldNameMap.put(setting.Field_Name__c, setting);
    	}
    	
    	return fieldNameMap;
    }
}