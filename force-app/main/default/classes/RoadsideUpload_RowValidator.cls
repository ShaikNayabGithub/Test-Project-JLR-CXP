public class RoadsideUpload_RowValidator {
	public void Validate(CSVDataCollection dataCollection)
	{
		List<Roadside_Upload_Field__c> fieldConfigList = Roadside_Upload_Field__c.getAll().values();

		for(Integer rowIndex : dataCollection.LinesByRowIndex.keySet()) {
			List<String> row = dataCollection.LinesByRowIndex.get(rowIndex);

			CSVRowStatus rowStatus = dataCollection.LineStatusesByRowIndex.get(rowIndex);
			if(rowStatus == null) {
				rowStatus = new CSVRowStatus();
				dataCollection.LineStatusesByRowIndex.put(rowIndex, rowStatus);
			}

			for(Roadside_Upload_Field__c fieldConfigData : fieldConfigList) {
				String fieldValue = CSVDataCollectionUtilities.GetColumnValue(dataCollection, 
						fieldConfigData.Name, row);

				if(fieldConfigData.Is_Mandatory__c && String.isBlank(fieldValue)) {
					rowStatus.HasErrored = true;
					if(rowStatus.Message == null) rowStatus.Message = '';
					rowStatus.Message += (System.Label.Required_Field_Missing + fieldConfigData.Name);
				}
			}
		}
	}
}