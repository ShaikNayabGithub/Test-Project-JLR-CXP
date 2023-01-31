@isTest
public class RoadsideUpload_EventBuilder_T {
	static testMethod void Build_DoesNothing_GivenEmptyCollection()
	{
		RoadsideUpload_EventBuilder eventBuilder = BuildBuilder();

		RoadsideUpload_RecordCollection recordCollection = CreateEmptyCollection();


		eventBuilder.Build(recordCollection);


		System.assert(true);
	}

	static testMethod void Build_SetsIsReminderSetToFalse_GivenRowData()
	{
		RoadsideUpload_EventBuilder eventBuilder = BuildBuilder();

		Integer rowIndex1 = 1;
		String vin1 = 'v1';

		List<String> rowData = new List<String> {
			//vin1
		};

		RoadsideUpload_RecordCollection recordCollection = CreateEmptyCollection();
		recordCollection.CSVData.LinesByRowIndex.put(rowIndex1, rowData);

		eventBuilder.Build(recordCollection);


		System.assertEquals(false, recordCollection.EventByCSVRowNumber.get(rowIndex1).IsReminderSet);
	}

	static testMethod void Build_SetsWhatToAsset1_GivenAsset1WithVIN1()
	{
		RoadsideUpload_EventBuilder eventBuilder = BuildBuilder();

		Integer rowIndex1 = 1;
		String vin1 = 'v1';

		Asset asset1 = TestClass_AssetBuilder.BuildVehicle();
		insert asset1;

		List<String> rowData = new List<String> {
			vin1
		};

		RoadsideUpload_RecordCollection recordCollection = CreateEmptyCollection();
		recordCollection.CSVData.ColumnIndexesByFieldName.put(RoadsideUpload_Constants.VIN_COLUMN_HEADER, 0);
		recordCollection.CSVData.LinesByRowIndex.put(rowIndex1, rowData);
		recordCollection.AssetsByVIN.put(vin1, asset1);

		eventBuilder.Build(recordCollection);


		System.assertEquals(asset1.Id, recordCollection.EventByCSVRowNumber.get(rowIndex1).WhatId);
	}

	static testMethod void Build_SetsWhoToContact1_GivenContact1WithEmail()
	{
		RoadsideUpload_EventBuilder eventBuilder = BuildBuilder();

		Integer rowIndex1 = 1;

		Contact contact1 = TestClass_ValidContactBuilder.Build();

		List<String> rowData = new List<String> {
			contact1.Email
		};

		RoadsideUpload_RecordCollection recordCollection = CreateEmptyCollection();
		recordCollection.CSVData.ColumnIndexesByFieldName.put(RoadsideUpload_Constants.EMAIL_COLUMN_HEADER, 0);
		recordCollection.CSVData.LinesByRowIndex.put(rowIndex1, rowData);
		recordCollection.ContactsByEmail.put(contact1.Email, contact1);

		eventBuilder.Build(recordCollection);


		System.assertEquals(contact1.Id, recordCollection.EventByCSVRowNumber.get(rowIndex1).WhoId);
	}


	static RoadsideUpload_EventBuilder BuildBuilder()
	{
		RoadsideUpload_AssetGetter assetGetter = new RoadsideUpload_AssetGetter();
		RoadsideUpload_WhoGetter whoGetter = new RoadsideUpload_WhoGetter();
		RoadsideUpload_SimpleFieldSetter simpleFieldSetter = new RoadsideUpload_SimpleFieldSetter();

		return new RoadsideUpload_EventBuilder(assetGetter, whoGetter, simpleFieldSetter);
	}

	static RoadsideUpload_RecordCollection CreateEmptyCollection()
	{
		RoadsideUpload_RecordCollection recordCollection = new RoadsideUpload_RecordCollection();
		recordCollection.CSVData = new CSVDataCollection();
		recordCollection.CSVData.LinesByRowIndex = new Map<Integer, List<String>>();
		recordCollection.CSVData.LineStatusesByRowIndex = new Map<Integer, CSVRowStatus>();
		recordCollection.CSVData.ColumnIndexesByFieldName = new Map<String, Integer>();
		recordCollection.AssetsByVIN = new Map<String, Asset>();
		recordCollection.ContactsByEmail = new Map<String, Contact>();

		return recordCollection;
	}
}