public class Vista_ErrorWriter {
	public void WriteErrors(String key, Database.Error[] errors, Vista_RequestCollection requestCollection)
	{
		List<Vista_RecordGroup> recordGroups = requestCollection.RecordGroups.get(key);

		String errorMessage = '';
		for(Database.Error errorString : errors) {
			errorMessage = errorMessage + string.valueOf(DateTime.now()) + ' Error processing request. Error Message: ' + errorString +'\n';
		}

		for(Vista_RecordGroup recordGroup : recordGroups) {
			recordGroup.Request.Error_Log__c = recordGroup.Request.Error_Log__c + '\n' +errorMessage;
			recordGroup.Request.Status__c = 'Error';
		}
	}
}