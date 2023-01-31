@isTest
public class RoadsideUpload_PairedListPopulator_T {
	static testMethod void PopulateLists_AddsNothingToRowIndexes_GivenEmptyMap()
	{
		RoadsideUpload_PairedListPopulator pairedListPopulator = new RoadsideUpload_PairedListPopulator();

		List<Integer> rowIndexes = new List<Integer>();
		List<SObject> records = new List<SObject>(); 
		Map<Integer, SObject> recordMap = new Map<Integer, SObject>();
		Map<Integer, CSVRowStatus> lineStatusesByRowIndex = new Map<Integer, CSVRowStatus>();


		pairedListPopulator.PopulateLists(rowIndexes, records, recordMap, lineStatusesByRowIndex);


		System.assertEquals(0, rowIndexes.Size());
	}

	static testMethod void PopulateLists_AddsNothingToRecordsList_GivenEmptyMap()
	{
		RoadsideUpload_PairedListPopulator pairedListPopulator = new RoadsideUpload_PairedListPopulator();

		List<Integer> rowIndexes = new List<Integer>();
		List<SObject> records = new List<SObject>(); 
		Map<Integer, SObject> recordMap = new Map<Integer, SObject>();
		Map<Integer, CSVRowStatus> lineStatusesByRowIndex = new Map<Integer, CSVRowStatus>();


		pairedListPopulator.PopulateLists(rowIndexes, records, recordMap, lineStatusesByRowIndex);


		System.assertEquals(0, records.Size());
	}

	static testMethod void PopulateLists_Adds1ToRowIndexes_GivenLead1By1()
	{
		RoadsideUpload_PairedListPopulator pairedListPopulator = new RoadsideUpload_PairedListPopulator();

		Integer rowIndex1 = 1;
		Lead lead1 = new Lead(FirstName = 'n1');

		List<Integer> rowIndexes = new List<Integer>();
		List<SObject> records = new List<SObject>(); 
		Map<Integer, SObject> recordMap = new Map<Integer, SObject> { rowIndex1 => lead1 };
		Map<Integer, CSVRowStatus> lineStatusesByRowIndex = new Map<Integer, CSVRowStatus>();


		pairedListPopulator.PopulateLists(rowIndexes, records, recordMap, lineStatusesByRowIndex);


		System.assertEquals(rowIndex1, rowIndexes[0]);
	}

	static testMethod void PopulateLists_AddsLead1ToRecordList_GivenLead1By1()
	{
		RoadsideUpload_PairedListPopulator pairedListPopulator = new RoadsideUpload_PairedListPopulator();

		Integer rowIndex1 = 1;
		Lead lead1 = new Lead(FirstName = 'n1');

		List<Integer> rowIndexes = new List<Integer>();
		List<SObject> records = new List<SObject>(); 
		Map<Integer, SObject> recordMap = new Map<Integer, SObject> { rowIndex1 => lead1 };
		Map<Integer, CSVRowStatus> lineStatusesByRowIndex = new Map<Integer, CSVRowStatus>();


		pairedListPopulator.PopulateLists(rowIndexes, records, recordMap, lineStatusesByRowIndex);


		System.assertEquals(lead1.FirstName, ((Lead)records[0]).FirstName);
	}

	static testMethod void PopulateLists_Adds1ToRowIndexes_GivenLead1By1AndEmptyStatus()
	{
		RoadsideUpload_PairedListPopulator pairedListPopulator = new RoadsideUpload_PairedListPopulator();

		Integer rowIndex1 = 1;
		Lead lead1 = new Lead(FirstName = 'n1');
		CSVRowStatus rowStatus1 = new CSVRowStatus();

		List<Integer> rowIndexes = new List<Integer>();
		List<SObject> records = new List<SObject>(); 
		Map<Integer, SObject> recordMap = new Map<Integer, SObject> { rowIndex1 => lead1 };
		Map<Integer, CSVRowStatus> lineStatusesByRowIndex = new Map<Integer, CSVRowStatus> { rowIndex1 => rowStatus1 };


		pairedListPopulator.PopulateLists(rowIndexes, records, recordMap, lineStatusesByRowIndex);


		System.assertEquals(rowIndex1, rowIndexes[0]);
	}

	static testMethod void PopulateLists_AddsLead1ToRecordList_GivenLead1By1AndEmptyStatus()
	{
		RoadsideUpload_PairedListPopulator pairedListPopulator = new RoadsideUpload_PairedListPopulator();

		Integer rowIndex1 = 1;
		Lead lead1 = new Lead(FirstName = 'n1');
		CSVRowStatus rowStatus1 = new CSVRowStatus();

		List<Integer> rowIndexes = new List<Integer>();
		List<SObject> records = new List<SObject>(); 
		Map<Integer, SObject> recordMap = new Map<Integer, SObject> { rowIndex1 => lead1 };
		Map<Integer, CSVRowStatus> lineStatusesByRowIndex = new Map<Integer, CSVRowStatus> { rowIndex1 => rowStatus1 };


		pairedListPopulator.PopulateLists(rowIndexes, records, recordMap, lineStatusesByRowIndex);


		System.assertEquals(lead1.FirstName, ((Lead)records[0]).FirstName);
	}

	static testMethod void PopulateLists_AddsNothingToRowIndexes_GivenLead1By1AndFailedStatus()
	{
		RoadsideUpload_PairedListPopulator pairedListPopulator = new RoadsideUpload_PairedListPopulator();

		Integer rowIndex1 = 1;
		Lead lead1 = new Lead(FirstName = 'n1');
		CSVRowStatus rowStatus1 = new CSVRowStatus();
		rowStatus1.HasErrored = true;

		List<Integer> rowIndexes = new List<Integer>();
		List<SObject> records = new List<SObject>(); 
		Map<Integer, SObject> recordMap = new Map<Integer, SObject> { rowIndex1 => lead1 };
		Map<Integer, CSVRowStatus> lineStatusesByRowIndex = new Map<Integer, CSVRowStatus> { rowIndex1 => rowStatus1 };


		pairedListPopulator.PopulateLists(rowIndexes, records, recordMap, lineStatusesByRowIndex);


		System.assertEquals(0, rowIndexes.Size());
	}

	static testMethod void PopulateLists_AddsNothingToRecordList_GivenLead1By1AndFailedStatus()
	{
		RoadsideUpload_PairedListPopulator pairedListPopulator = new RoadsideUpload_PairedListPopulator();

		Integer rowIndex1 = 1;
		Lead lead1 = new Lead(FirstName = 'n1');
		CSVRowStatus rowStatus1 = new CSVRowStatus();
		rowStatus1.HasErrored = true;

		List<Integer> rowIndexes = new List<Integer>();
		List<SObject> records = new List<SObject>(); 
		Map<Integer, SObject> recordMap = new Map<Integer, SObject> { rowIndex1 => lead1 };
		Map<Integer, CSVRowStatus> lineStatusesByRowIndex = new Map<Integer, CSVRowStatus> { rowIndex1 => rowStatus1 };


		pairedListPopulator.PopulateLists(rowIndexes, records, recordMap, lineStatusesByRowIndex);


		System.assertEquals(0, records.Size());
	}
}