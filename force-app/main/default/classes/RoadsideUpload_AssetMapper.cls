public class RoadsideUpload_AssetMapper {
	public void AddToCollection(List<Asset> assets, RoadsideUpload_RecordCollection recordCollection)
	{
		if(recordCollection.AssetsByVIN == null) {
			recordCollection.AssetsByVIN = new Map<String, Asset>();
		}

		if(recordCollection.AssetsByRegistration == null) {
			recordCollection.AssetsByRegistration = new Map<String, Asset>();
		}

		for(Asset asset : assets) {
			if(String.isNotBlank(asset.VIN__c)) {
				recordCollection.AssetsByVIN.put(asset.VIN__c, asset);
			}

			if(String.isNotBlank(asset.Registration_Number__c)) {
				recordCollection.AssetsByRegistration.put(asset.Registration_Number__c, asset);
			}
		}
	}
}