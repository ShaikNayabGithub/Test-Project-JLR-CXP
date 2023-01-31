public class RoadsideUpload_ResultsLogger {
	public void LogResults(RoadsideUpload_RecordCollection recordCollection)
	{
		String messageLog = '';

		for(Integer rowIndex : recordCollection.CSVData.LineStatusesByRowIndex.keySet()) {
			String rowMessageFormat = rowIndex + CSVParser.ROW_NUMBER_TAG + '"{0}"' + CSVParser.CRLF;
			String rowMessage = '';

			CSVRowStatus rowStatus = recordCollection.CSVData.LineStatusesByRowIndex.get(rowIndex);
			if(rowStatus == null || rowStatus.HasErrored != true) {
				rowMessage = System.Label.Success;
			} else {
				rowMessage = rowStatus.Message;
				recordCollection.ApexJob.Failure_Count__c++;
			}

			messageLog = messageLog + String.format(rowMessageFormat, new List<String> { rowMessage });
		}

		recordCollection.ApexJob.Status__c = ApexJobUtilities.PROCESSED_STATUS;
		recordCollection.ApexJob.Results_Log__c = messageLog;

		upsert recordCollection.ApexJob;
	}
}