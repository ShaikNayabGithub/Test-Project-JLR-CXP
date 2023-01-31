@isTest
public class RoadsideUpload_AssetBuilder_T {
	static testMethod void Build_DoesNothing_GivenEmptyCollection()
	{
		RoadsideUpload_AssetBuilder assetBuilder = BuildBuilder();

		RoadsideUpload_RecordCollection recordCollection = new RoadsideUpload_RecordCollection();

		assetBuilder.Build(recordCollection);

		System.assert(true);
	}

	static testMethod void Build_SetsAssetMileage_GivenAssetAndMileage()
	{
		RoadsideUpload_AssetBuilder assetBuilder = BuildBuilder();

		Integer rowIndex1 = 1;
		Integer mileage1 = 1;
		String vin1 = 'v1';

		List<String> rowData = new List<String> {
			vin1,
			String.valueOf(mileage1)
		};
		Asset asset1 = new Asset();

		RoadsideUpload_RecordCollection recordCollection = CreateEmptyCollection();
		recordCollection.CSVData.ColumnIndexesByFieldName.put(RoadsideUpload_Constants.MILEAGE_COLUMN_HEADER, 1);
		recordCollection.AssetsByVIN.put(vin1, asset1);
		recordCollection.CSVData.LinesByRowIndex.put(rowIndex1, rowData);


		assetBuilder.Build(recordCollection);


		System.assertEquals(mileage1, asset1.Mileage__c);
	}

	static testMethod void Build_DoesNotSetMileage_GivenAssetAndMileageAndRowStatusFailed()
	{
		RoadsideUpload_AssetBuilder assetBuilder = BuildBuilder();

		Integer rowIndex1 = 1;
		Integer oldMileage1 = 1;
		Integer mileage1 = 2;
		String vin1 = 'v1';
		CSVRowStatus rowStatus1 = new CSVRowStatus();
		rowStatus1.HasErrored = true;

		List<String> rowData = new List<String> {
			vin1,
			String.valueOf(mileage1)
		};
		Asset asset1 = new Asset(Mileage__c = oldMileage1);

		RoadsideUpload_RecordCollection recordCollection = CreateEmptyCollection();
		recordCollection.CSVData.ColumnIndexesByFieldName.put(RoadsideUpload_Constants.MILEAGE_COLUMN_HEADER, 1);
		recordCollection.AssetsByVIN.put(vin1, asset1);
		recordCollection.CSVData.LinesByRowIndex.put(rowIndex1, rowData);
		recordCollection.CSVData.LineStatusesByRowIndex.put(rowIndex1, rowStatus1);


		assetBuilder.Build(recordCollection);


		System.assertEquals(oldMileage1, asset1.Mileage__c);
	}

	static testMethod void Build_SetsAssetMileageUOM_GivenAssetAndMileageUOM()
	{
		RoadsideUpload_AssetBuilder assetBuilder = BuildBuilder();

		Integer rowIndex1 = 1;
		String mileageUOM1 = 'Miles';
		String vin1 = 'v1';

		List<String> rowData = new List<String> {
			vin1,
			mileageUOM1
		};
		Asset asset1 = new Asset();

		RoadsideUpload_RecordCollection recordCollection = CreateEmptyCollection();
		recordCollection.CSVData.ColumnIndexesByFieldName.put(RoadsideUpload_Constants.MILEAGE_UOM_COLUMN_HEADER, 1);
		recordCollection.AssetsByVIN.put(vin1, asset1);
		recordCollection.CSVData.LinesByRowIndex.put(rowIndex1, rowData);


		assetBuilder.Build(recordCollection);


		System.assertEquals(mileageUOM1, asset1.Mileage_UOM__c);
	}

	static testMethod void Build_DoesNotSetMileageUOM_GivenAssetAndMileageUOMAndRowStatusFailed()
	{
		RoadsideUpload_AssetBuilder assetBuilder = BuildBuilder();

		Integer rowIndex1 = 1;
		String mileageUOM1 = 'Kilometers';
		String mileageUOM2 = 'Miles';
		String vin1 = 'v1';
		CSVRowStatus rowStatus1 = new CSVRowStatus();
		rowStatus1.HasErrored = true;

		List<String> rowData = new List<String> {
			vin1,
			mileageUOM2
		};
		Asset asset1 = new Asset(Mileage_UOM__c = mileageUOM1);

		RoadsideUpload_RecordCollection recordCollection = CreateEmptyCollection();
		recordCollection.CSVData.ColumnIndexesByFieldName.put(RoadsideUpload_Constants.MILEAGE_UOM_COLUMN_HEADER, 1);
		recordCollection.AssetsByVIN.put(vin1, asset1);
		recordCollection.CSVData.LinesByRowIndex.put(rowIndex1, rowData);
		recordCollection.CSVData.LineStatusesByRowIndex.put(rowIndex1, rowStatus1);


		assetBuilder.Build(recordCollection);


		System.assertEquals(mileageUOM1, asset1.Mileage_UOM__c);
	}


	static RoadsideUpload_AssetBuilder BuildBuilder()
	{
		RoadsideUpload_AssetGetter assetGetter = new RoadsideUpload_AssetGetter();
		return new RoadsideUpload_AssetBuilder(assetGetter);
	}

	static RoadsideUpload_RecordCollection CreateEmptyCollection()
	{
		RoadsideUpload_RecordCollection recordCollection = new RoadsideUpload_RecordCollection();
		recordCollection.CSVData = new CSVDataCollection();
		recordCollection.CSVData.LinesByRowIndex = new Map<Integer, List<String>>();
		recordCollection.CSVData.LineStatusesByRowIndex = new Map<Integer, CSVRowStatus>();
		recordCollection.CSVData.ColumnIndexesByFieldName = new Map<String, Integer> {
			RoadsideUpload_Constants.VIN_COLUMN_HEADER => 0
		};
		recordCollection.AssetsByVIN = new Map<String, Asset>();
		recordCollection.AssetsByRegistration = new Map<String, Asset>();

		return recordCollection;
	}
}