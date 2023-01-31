public class SObjectHierachyRetriever {
	private static final String QUERY_FORMAT = 'SELECT {0}, {2}{3} FROM {1} WHERE {2} IN: sourceValues AND Id NOT IN: recordIds';
	

	///Retrieves a chain (length N) of SObjects linked by the fields given
	///E.g. Given Account1(parentId=2), field parentid, field id - will add Account2(id=2) to collection
	///E.g. Given Account2(Id=2), field id, field parentid - will add Account1(parentId=2) to collection
	///Please see unit tests for further explanation
	public void RetrieveHierachy(SObjectHierachyCollection hierachyCollection, 
			Schema.DescribeFieldResult sourceField, Schema.DescribeFieldResult toField, 
			Set<Schema.DescribeFieldResult> additionalFields)
	{
		if(hierachyCollection.Size() == 0) { return; }

		String entityName = hierachyCollection.values()[0].getSObjectType().getDescribe().getName();
		String additionalFieldString = this.BuildFieldString(additionalFields);

		String queryString = String.format(QUERY_FORMAT, new List<String> { 
					sourceField.getName(), entityName, toField.getName(), additionalFieldString });

		Set<String> sourceValues = SObjectUtilities.GetFieldValues(hierachyCollection.Values(), 
				sourceField.getName());

		while(sourceValues.Size() > 0) {
			Map<Id, List<SObject>> sourceRecordMapBySourceField = SObjectUtilities.MapByIdField(
					hierachyCollection.Values(), sourceField);

			Set<Id> recordIds = hierachyCollection.keySet();
			List<SObject> retrievedRecords = Database.query(queryString);
			sourceValues.clear();

			for(SObject retrievedRecord : retrievedRecords) {
				Id toFieldValue = (Id)retrievedRecord.get(toField.getName());
				for(SObject sourceRecord : sourceRecordMapBySourceField.get(toFieldValue)) {
					hierachyCollection.put(sourceRecord.Id, retrievedRecord);
				}
				if(retrievedRecord.get(sourceField.getName()) != null) {
					sourceValues.add((Id)retrievedRecord.get(sourceField.getName()));
				}
			}
		}
	}


	private String BuildFieldString(Set<Schema.DescribeFieldResult> fields)
	{
		String returnString = '';
		for(Schema.DescribeFieldResult field : fields) {
			returnString += ', ' + field.getName();
		}
		return returnString;
	}
}