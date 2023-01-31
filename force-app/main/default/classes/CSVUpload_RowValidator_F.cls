public class CSVUpload_RowValidator_F {
    public CSVUpload_RowValidator Create(String processName)
    {
        FileUpload_FieldMappingGetter fieldMappingGetter = new FileUpload_FieldMappingGetter();
        List<File_Upload_Field_Mapping__c> fieldMappings = fieldMappingGetter.GetFieldMappings(processName).values();

        return new CSVUpload_RowValidator(fieldMappings);
    }
}