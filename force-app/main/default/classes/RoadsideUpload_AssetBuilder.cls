public class RoadsideUpload_AssetBuilder {
	private final RoadsideUpload_AssetGetter assetGetter;


	public RoadsideUpload_AssetBuilder(RoadsideUpload_AssetGetter assetGetter)
	{
		this.assetGetter = assetGetter;
	}


	public void Build(RoadsideUpload_RecordCollection recordCollection)
	{
		if(recordCollection.AssetsToUpdate == null) {
			recordCollection.AssetsToUpdate = new Map<Integer, Asset>();
		}

		if(recordCollection.CSVData == null || recordCollection.CSVData.LinesByRowIndex == null) return;

		for(Integer csvRowIndex : recordCollection.CSVData.LinesByRowIndex.keySet()) {
			CSVRowStatus rowStatus = recordCollection.CSVData.LineStatusesByRowIndex.get(csvRowIndex);
			if(rowStatus != null && rowStatus.HasErrored == true) continue;
			
			List<String> rowData = recordCollection.CSVData.LinesByRowIndex.get(csvRowIndex);
			Asset asset = this.assetGetter.GetAsset(rowData, recordCollection);
			if(asset == null) continue;

			String newMileage = CSVDataCollectionUtilities.GetColumnValue(recordCollection.CSVData, 
					RoadsideUpload_Constants.MILEAGE_COLUMN_HEADER, rowData);

			if(String.isNotBlank(newMileage)) {
				asset.Mileage__c = Integer.valueOf(newMileage);
				recordCollection.AssetsToUpdate.put(csvRowIndex, asset);
			}

			String newMileageUOM = CSVDataCollectionUtilities.GetColumnValue(recordCollection.CSVData, 
					RoadsideUpload_Constants.MILEAGE_UOM_COLUMN_HEADER, rowData);

			if(String.isNotBlank(newMileageUOM)) {
				asset.Mileage_UOM__c = newMileageUOM;
				recordCollection.AssetsToUpdate.put(csvRowIndex, asset);
			}
		}
	}
}