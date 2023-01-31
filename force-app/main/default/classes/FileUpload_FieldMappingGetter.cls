public class FileUpload_FieldMappingGetter {
    public Map<String, File_Upload_Field_Mapping__c> GetFieldMappings(String processName)
    {
        Map<String, File_Upload_Field_Mapping__c> filteredMap = new Map<String, File_Upload_Field_Mapping__c>();

        Map<String, File_Upload_Field_Mapping__c> mappingInfoMap = File_Upload_Field_Mapping__c.getAll();

		for(String mappingInfoName : mappingInfoMap.keySet()) {
            String[] splitMappingName = mappingInfoName.split('\\.');

            if(splitMappingName[0] != processName) continue;
            filteredMap.put(mappingInfoName, mappingInfoMap.get(mappingInfoName));
        }

        return filteredMap;
    }
}