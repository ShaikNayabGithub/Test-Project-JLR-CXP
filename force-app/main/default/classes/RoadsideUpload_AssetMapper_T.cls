@isTest
public class RoadsideUpload_AssetMapper_T {
	static testMethod void AddToCollection_DoesNothing_GivenNoData()
	{
		RoadsideUpload_AssetMapper assetMapper = new RoadsideUpload_AssetMapper();

		List<Asset> assets = new List<Asset>();
		RoadsideUpload_RecordCollection recordCollection = CreateEmptyCollection();


		assetMapper.AddToCollection(assets, recordCollection);


		System.assert(true);
	}

	static testMethod void AddToCollection_AddsAsset1ToAssetsByVIN_GivenAsset1WithVINV1()
	{
		RoadsideUpload_AssetMapper assetMapper = new RoadsideUpload_AssetMapper();

		String reg1 = 'r1';
		String vin1 = 'v1';
		Asset asset1 = new Asset(Name = 'a1', Registration_Number__c = reg1, VIN__c = vin1);

		List<Asset> assets = new List<Asset> { asset1 };
		RoadsideUpload_RecordCollection recordCollection = CreateEmptyCollection();


		assetMapper.AddToCollection(assets, recordCollection);


		System.assertEquals(asset1.Name, recordCollection.AssetsByVIN.get(vin1).Name);
	}

	static testMethod void AddToCollection_AddsAsset1ToAssetsByRegistration_GivenAsset1WithRegR1()
	{
		RoadsideUpload_AssetMapper assetMapper = new RoadsideUpload_AssetMapper();

		String reg1 = 'r1';
		String vin1 = 'v1';
		Asset asset1 = new Asset(Name = 'a1', Registration_Number__c = reg1, VIN__c = vin1);

		List<Asset> assets = new List<Asset> { asset1 };
		RoadsideUpload_RecordCollection recordCollection = CreateEmptyCollection();


		assetMapper.AddToCollection(assets, recordCollection);


		System.assertEquals(asset1.Name, recordCollection.AssetsByRegistration.get(reg1).Name);
	}


	static RoadsideUpload_RecordCollection CreateEmptyCollection()
	{
		RoadsideUpload_RecordCollection recordCollection = new RoadsideUpload_RecordCollection();
		recordCollection.AssetsByVIN = new Map<String, Asset>();
		recordCollection.AssetsByRegistration = new Map<String, Asset>();

		return recordCollection;
	}
}