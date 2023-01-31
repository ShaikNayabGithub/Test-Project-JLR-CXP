public class CountryMapping_Utilities {
	public static Map<String, aop_NationalityToISOCode__c> CountryMappingsByName { get {
		if(CountryMappingsByName == null) {
			CountryMappingsByName = aop_NationalityToISOCode__c.getAll();
		}
		return CountryMappingsByName;
	} private set; }
	
    public static Map<String, aop_NationalityToISOCode__c> CountryMappingsByISOCode { get {
    	if(CountryMappingsByISOCode == null) {
    		CountryMappingsByISOCode = new Map<String, aop_NationalityToISOCode__c>();
    		for(aop_NationalityToISOCode__c countrySetting : CountryMappingsByName.Values()) {
    			CountryMappingsByISOCode.put(countrySetting.aop_ISO_Code__c , countrySetting);
    		}
    	}
    	return CountryMappingsByISOCode;
    } private set; }
}