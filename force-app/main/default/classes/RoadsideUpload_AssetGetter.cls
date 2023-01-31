public class RoadsideUpload_AssetGetter {
	public Asset GetAsset(List<String> rowData, RoadsideUpload_RecordCollection recordCollection)
	{
		String vin = CSVDataCollectionUtilities.GetColumnValue(recordCollection.CSVData, 
					RoadsideUpload_Constants.VIN_COLUMN_HEADER, rowData);

		if(String.isNotBlank(vin)) {
			Asset asset = recordCollection.AssetsByVIN.get(vin);
			if(asset != null) return asset;
		}

		String registration = CSVDataCollectionUtilities.GetColumnValue(recordCollection.CSVData, 
					RoadsideUpload_Constants.REGISTRATION_COLUMN_HEADER, rowData);

		if(String.isNotBlank(registration)) {
			Asset asset = recordCollection.AssetsByRegistration.get(registration);
			return asset;
		}

		return null;
	}
}