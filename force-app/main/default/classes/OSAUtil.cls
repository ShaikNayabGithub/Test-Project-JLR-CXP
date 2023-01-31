public without sharing class OSAUtil {
	// This method is used to get key features URL which is stored in custom metadata 
    public static String getKeyFeaturesUrl(String brand, String modelName) {
        String keyFeaturesLink = '';
        if(String.isNotBlank(brand) && String.isNotBlank(modelName)) {
            modelName = modelName.replaceAll('[^a-zA-Z0-9]', '_');
            List < Model_Settings__mdt > keyFeatures = [SELECT Key_Features__c FROM Model_Settings__mdt WHERE Brand__c = :brand AND DeveloperName = :modelName];
            if(keyFeatures != null && !keyFeatures.isEmpty()) {                
                keyFeaturesLink = keyFeatures[0].Key_Features__c;
            }
        }
        return keyFeaturesLink;
    }
}