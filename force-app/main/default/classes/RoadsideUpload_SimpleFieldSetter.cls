public class RoadsideUpload_SimpleFieldSetter {
	public void SetSimpleFields(SObject record, List<String> rowData, CSVDataCollection dataCollection)
	{
		Map<String, Schema.SObjectField> fieldDescribeMap =
				record.getSObjectType().getDescribe().fields.getMap();

		Map<String, Roadside_Upload_Field__c> mappingInfoMap = Roadside_Upload_Field__c.getAll();

		for(String columnHeader : mappingInfoMap.keySet()) {
			Roadside_Upload_Field__c mappingInfo = mappingInfoMap.get(columnHeader);
			if(String.isBlank(mappingInfo.Salesforce_Field_Name__c)) continue;

			Schema.DescribeFieldResult fieldDescription = 
					fieldDescribeMap.get(mappingInfo.Salesforce_Field_Name__c).getDescribe();

			String fieldValueString = CSVDataCollectionUtilities.GetColumnValue(dataCollection, columnHeader,
					rowData);
			if(String.isBlank(fieldValueString)) continue;

			object fieldValue = SObjectUtilities.CastFieldData(fieldValueString, fieldDescription);
			record.put(mappingInfo.Salesforce_Field_Name__c, fieldValue);
		}
	}
}