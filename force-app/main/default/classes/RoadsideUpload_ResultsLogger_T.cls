@isTest
public class RoadsideUpload_ResultsLogger_T {
	static testMethod void LogResults_SetsJobStatusToProcessed_GivenApexJob()
	{
		RoadsideUpload_ResultsLogger resultsLogger = new RoadsideUpload_ResultsLogger();

		RoadsideUpload_RecordCollection recordCollection = CreateEmptyCollection();


		resultsLogger.LogResults(recordCollection);


		Apex_Job__c apexJob = [SELECT Status__c FROM Apex_Job__c WHERE Id =: recordCollection.ApexJob.Id];
		System.assertEquals(ApexJobUtilities.PROCESSED_STATUS, apexJob.Status__c);
	}

	static testMethod void LogResults_SetsResultsLogToEmptyString_GivenNoRowStatuses()
	{
		RoadsideUpload_ResultsLogger resultsLogger = new RoadsideUpload_ResultsLogger();

		RoadsideUpload_RecordCollection recordCollection = CreateEmptyCollection();


		resultsLogger.LogResults(recordCollection);


		System.assert(String.isBlank(recordCollection.ApexJob.Results_Log__c));
	}

	static testMethod void LogResults_SetsResultsLogRow1AsSuccessful_GivenRow1StatusHasErroredEqualsFalse()
	{
		RoadsideUpload_ResultsLogger resultsLogger = new RoadsideUpload_ResultsLogger();

		Integer rowIndex1 = 1;
		String expectedLog = rowIndex1 + CSVParser.ROW_NUMBER_TAG + '"' + System.Label.Success + '"' + 
				CSVParser.CRLF;

		CSVRowStatus rowStatus1 = new CSVRowStatus();
		rowStatus1.HasErrored = false;

		RoadsideUpload_RecordCollection recordCollection = CreateEmptyCollection();
		recordCollection.CSVData.LineStatusesByRowIndex.put(rowIndex1, rowStatus1);


		resultsLogger.LogResults(recordCollection);


		System.assertEquals(expectedLog, recordCollection.ApexJob.Results_Log__c);
	}

	static testMethod void LogResults_SetsResultsLogsRow1AsFM1_GivenRow1StatusHasErroredEqualsTrueAndMessageFM1()
	{
		RoadsideUpload_ResultsLogger resultsLogger = new RoadsideUpload_ResultsLogger();

		Integer rowIndex1 = 1;
		
		CSVRowStatus rowStatus1 = new CSVRowStatus();
		rowStatus1.HasErrored = true;
		rowStatus1.Message = 'FM1';

		String expectedLog = rowIndex1 + CSVParser.ROW_NUMBER_TAG + '"' + rowStatus1.Message + '"' + 
				CSVParser.CRLF;

		RoadsideUpload_RecordCollection recordCollection = CreateEmptyCollection();
		recordCollection.CSVData.LineStatusesByRowIndex.put(rowIndex1, rowStatus1);


		resultsLogger.LogResults(recordCollection);


		System.assertEquals(expectedLog, recordCollection.ApexJob.Results_Log__c);
	}

	static testMethod void LogResults_SetsResultsFailureCountTo1_GivenRow1StatusHasErroredEqualsTrueAndMessageFM1()
	{
		RoadsideUpload_ResultsLogger resultsLogger = new RoadsideUpload_ResultsLogger();

		Integer rowIndex1 = 1;
		
		CSVRowStatus rowStatus1 = new CSVRowStatus();
		rowStatus1.HasErrored = true;
		rowStatus1.Message = 'FM1';

		RoadsideUpload_RecordCollection recordCollection = CreateEmptyCollection();
		recordCollection.CSVData.LineStatusesByRowIndex.put(rowIndex1, rowStatus1);


		resultsLogger.LogResults(recordCollection);


		System.assertEquals(1, recordCollection.ApexJob.Failure_Count__c);
	}


	static RoadsideUpload_RecordCollection CreateEmptyCollection()
	{
		RoadsideUpload_RecordCollection recordCollection = new RoadsideUpload_RecordCollection();
		recordCollection.ApexJob = new Apex_Job__c(Name = 'test', Failure_Count__c = 0);
		recordCollection.CSVData = new CSVDataCollection();
		recordCollection.CSVData.LineStatusesByRowIndex = new Map<Integer, CSVRowStatus>();

		return recordCollection;
	}
}