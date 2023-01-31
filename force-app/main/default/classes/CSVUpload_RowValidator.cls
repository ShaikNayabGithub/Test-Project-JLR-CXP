public class CSVUpload_RowValidator {
    private final List<File_Upload_Field_Mapping__c> fieldMapping;


    public CSVUpload_RowValidator(List<File_Upload_Field_Mapping__c> fieldMapping)
    {
        this.fieldMapping = fieldMapping;
    }


    public void Validate(CSVDataCollection dataCollection)
	{
		for(Integer rowIndex : dataCollection.LinesByRowIndex.keySet()) {
			List<String> row = dataCollection.LinesByRowIndex.get(rowIndex);

			CSVRowStatus rowStatus = dataCollection.LineStatusesByRowIndex.get(rowIndex);
			if(rowStatus == null) {
				rowStatus = new CSVRowStatus();
				dataCollection.LineStatusesByRowIndex.put(rowIndex, rowStatus);
			}

			for(File_Upload_Field_Mapping__c fieldConfigData : fieldMapping) {
				String fieldValue = CSVDataCollectionUtilities.GetColumnValue(dataCollection, 
						fieldConfigData.Import_Node__c, row);

				if(fieldConfigData.Is_Mandatory__c && String.isBlank(fieldValue)) {
					rowStatus.HasErrored = true;
					if(rowStatus.Message == null) rowStatus.Message = '';
					rowStatus.Message += (System.Label.Required_Field_Missing + fieldConfigData.Import_Node__c);
				}
			}
		}
	}
}