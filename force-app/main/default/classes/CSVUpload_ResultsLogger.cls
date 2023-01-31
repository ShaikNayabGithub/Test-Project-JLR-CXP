public class CSVUpload_ResultsLogger {
    public void LogResults(CSVUpload_DataCollection dataCollection)
	{
		String messageLog = '';

		for(Integer rowIndex : dataCollection.LineStatusesByRowIndex.keySet()) {
			String rowMessageFormat = rowIndex + CSVParser.ROW_NUMBER_TAG + '"{0}"' + CSVParser.CRLF;
			String rowMessage = '';

			CSVRowStatus rowStatus = dataCollection.LineStatusesByRowIndex.get(rowIndex);
			if(rowStatus == null || rowStatus.HasErrored != true) {
				rowMessage = System.Label.Success;
			} else {
				rowMessage = rowStatus.Message;
				dataCollection.ApexJob.Failure_Count__c++;
			}

			messageLog = messageLog + String.format(rowMessageFormat, new List<String> { rowMessage });
		}

		dataCollection.ApexJob.Status__c = ApexJobUtilities.PROCESSED_STATUS;
		dataCollection.ApexJob.Results_Log__c = messageLog;

		upsert dataCollection.ApexJob;
	}
}