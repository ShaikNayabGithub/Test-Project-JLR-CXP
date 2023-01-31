@isTest
public class CSVUpload_ErrorProcessor_T {
    static testMethod void ProcessErrors_ReturnsZero_GivenEmptyCollections()
	{
		CSVUpload_ErrorProcessor errorProcessor = new CSVUpload_ErrorProcessor();

		Database.SaveResult[] insertResults = new Database.SaveResult[]{};
		List<Integer> rowIndexes = new List<Integer>();
		Map<Integer, CSVRowStatus> lineStatusesByRowIndex = new Map<Integer, CSVRowStatus>();


		Integer results = errorProcessor.ProcessErrors(insertResults, rowIndexes, lineStatusesByRowIndex);


		System.assertEquals(0, results);
	}

	static testMethod void ProcessErrors_ReturnsOne_GivenSuccessfulSaveResult()
	{
		CSVUpload_ErrorProcessor errorProcessor = new CSVUpload_ErrorProcessor();

		Apex_Job__c apexJob = TestClass_ApexJob.Build();

		Database.SaveResult[] insertResults = Database.Insert(new List<Apex_Job__c>{ apexJob }, false);
		List<Integer> rowIndexes = new List<Integer>();
		Map<Integer, CSVRowStatus> lineStatusesByRowIndex = new Map<Integer, CSVRowStatus>();


		Integer results = errorProcessor.ProcessErrors(insertResults, rowIndexes, lineStatusesByRowIndex);


		System.assertEquals(1, results);
	}

	static testMethod void ProcessErrors_ReturnsZero_GivenFailedSaveResult()
	{
		CSVUpload_ErrorProcessor errorProcessor = new CSVUpload_ErrorProcessor();

		Integer rowIndex1 = 1;
		Event event = new Event();

		Database.SaveResult[] insertResults = Database.Insert(new List<Event>{ event }, false);
		List<Integer> rowIndexes = new List<Integer> { rowIndex1 };
		Map<Integer, CSVRowStatus> lineStatusesByRowIndex = new Map<Integer, CSVRowStatus>();


		Integer results = errorProcessor.ProcessErrors(insertResults, rowIndexes, lineStatusesByRowIndex);


		System.assertEquals(0, results);
	}

	static testMethod void ProcessErrors_SetsRowStatusToHasFailed_GivenFailedSaveResult()
	{
		CSVUpload_ErrorProcessor errorProcessor = new CSVUpload_ErrorProcessor();

		Integer rowIndex1 = 1;
		Event event = new Event();

		Database.SaveResult[] insertResults = Database.Insert(new List<Event>{ event }, false);
		List<Integer> rowIndexes = new List<Integer> { rowIndex1 };
		Map<Integer, CSVRowStatus> lineStatusesByRowIndex = new Map<Integer, CSVRowStatus>();


		Integer results = errorProcessor.ProcessErrors(insertResults, rowIndexes, lineStatusesByRowIndex);


		System.assert(lineStatusesByRowIndex.get(rowIndex1).HasErrored);
	}

	static testMethod void ProcessErrors_SetsRowMessage_GivenFailedSaveResult()
	{
		CSVUpload_ErrorProcessor errorProcessor = new CSVUpload_ErrorProcessor();

		Integer rowIndex1 = 1;
		Event event = new Event();

		Database.SaveResult[] insertResults = Database.Insert(new List<Event>{ event }, false);
		List<Integer> rowIndexes = new List<Integer> { rowIndex1 };
		Map<Integer, CSVRowStatus> lineStatusesByRowIndex = new Map<Integer, CSVRowStatus>();


		Integer results = errorProcessor.ProcessErrors(insertResults, rowIndexes, lineStatusesByRowIndex);


		System.assert(String.isNotBlank(lineStatusesByRowIndex.get(rowIndex1).Message));
	}
}