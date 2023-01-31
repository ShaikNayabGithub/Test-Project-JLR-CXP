public class CSVUpload_SimpleFieldSetter_F {
    public CSVUpload_SimpleFieldSetter Create(String processName)
    {
        FileUpload_FieldMappingGetter fieldMappingGetter = new FileUpload_FieldMappingGetter();
        List<File_Upload_Field_Mapping__c> fieldMappings = fieldMappingGetter.GetFieldMappings(processName).values();

        return new CSVUpload_SimpleFieldSetter(fieldMappings);
    }
}