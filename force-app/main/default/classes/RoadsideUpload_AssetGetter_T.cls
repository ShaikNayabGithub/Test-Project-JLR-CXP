@isTest
public class RoadsideUpload_AssetGetter_T {
	static testMethod void GetAsset_ReturnsNull_GivenNoData()
	{
		RoadsideUpload_AssetGetter assetGetter = new RoadsideUpload_AssetGetter();

		List<String> rowData = new List<String>();
		RoadsideUpload_RecordCollection recordCollection = CreateEmptyCollection();


		Asset result = assetGetter.GetAsset(rowData, recordCollection);


		System.assertEquals(null, result);
	}

	static testMethod void GetAsset_ReturnsNull_GivenEmptyCollection()
	{
		RoadsideUpload_AssetGetter assetGetter = new RoadsideUpload_AssetGetter();

		String vin1 = 'v1';

		RoadsideUpload_RecordCollection recordCollection = CreateEmptyCollection();
		recordCollection.CSVData.ColumnIndexesByFieldName.put(RoadsideUpload_Constants.VIN_COLUMN_HEADER, 0);
		List<String> rowData = new List<String> {
			vin1
		};


		Asset result = assetGetter.GetAsset(rowData, recordCollection);


		System.assertEquals(null, result);
	}

	static testMethod void GetAsset_ReturnsAsset1_GivenV1AndAssetWithVINV1()
	{
		RoadsideUpload_AssetGetter assetGetter = new RoadsideUpload_AssetGetter();

		String vin1 = 'v1';
		Asset asset1 = new Asset(Name = vin1);

		RoadsideUpload_RecordCollection recordCollection = CreateEmptyCollection();
		recordCollection.CSVData.ColumnIndexesByFieldName.put(RoadsideUpload_Constants.VIN_COLUMN_HEADER, 0);
		recordCollection.AssetsByVIN.put(vin1, asset1);
		List<String> rowData = new List<String> {
			vin1
		};


		Asset result = assetGetter.GetAsset(rowData, recordCollection);


		System.assertEquals(asset1.Name, result.Name);
	}

	static testMethod void GetAsset_ReturnsAsset1_GivenR1AndAssetWithRegistrationR1()
	{
		RoadsideUpload_AssetGetter assetGetter = new RoadsideUpload_AssetGetter();

		String registration1 = 'r1';
		Asset asset1 = new Asset(Name = registration1);

		RoadsideUpload_RecordCollection recordCollection = CreateEmptyCollection();
		recordCollection.CSVData.ColumnIndexesByFieldName.put(RoadsideUpload_Constants.REGISTRATION_COLUMN_HEADER, 0);
		recordCollection.AssetsByRegistration.put(registration1, asset1);
		List<String> rowData = new List<String> {
			registration1
		};


		Asset result = assetGetter.GetAsset(rowData, recordCollection);


		System.assertEquals(asset1.Name, result.Name);
	}

	static testMethod void GetAsset_ReturnsAsset1_GivenR1AndV1AndAsset1WithVINV1AndRegistrationR1AndAsset2WithRegistrationR1()
	{
		RoadsideUpload_AssetGetter assetGetter = new RoadsideUpload_AssetGetter();

		String registration1 = 'r1';
		String vin1 = 'v1';
		Asset asset1 = new Asset(Name = vin1);
		Asset asset2 = new Asset(Name = registration1);

		RoadsideUpload_RecordCollection recordCollection = CreateEmptyCollection();
		recordCollection.CSVData.ColumnIndexesByFieldName.put(RoadsideUpload_Constants.REGISTRATION_COLUMN_HEADER, 1);
		recordCollection.CSVData.ColumnIndexesByFieldName.put(RoadsideUpload_Constants.VIN_COLUMN_HEADER, 0);
		recordCollection.AssetsByRegistration.put(registration1, asset1);
		recordCollection.AssetsByRegistration.put(registration1, asset2);
		recordCollection.AssetsByVIN.put(vin1, asset1);

		List<String> rowData = new List<String> {
			vin1,
			registration1
		};


		Asset result = assetGetter.GetAsset(rowData, recordCollection);


		System.assertEquals(asset1.Name, result.Name);
	}


	static RoadsideUpload_RecordCollection CreateEmptyCollection()
	{
		RoadsideUpload_RecordCollection recordCollection = new RoadsideUpload_RecordCollection();
		recordCollection.CSVData = new CSVDataCollection();
		recordCollection.CSVData.ColumnIndexesByFieldName = new Map<String, Integer> ();
		recordCollection.AssetsByVIN = new Map<String, Asset>();
		recordCollection.AssetsByRegistration = new Map<String, Asset>();

		return recordCollection;
	}
}