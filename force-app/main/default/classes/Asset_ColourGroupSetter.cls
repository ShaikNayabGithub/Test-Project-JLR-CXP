public class Asset_ColourGroupSetter {
	public void SetColourGroup(List<Asset> currentAssets, Map<Id, Asset> oldAssetMap)
	{
		List<Asset> assetsWithNewColour = new List<Asset>();

		for(Asset currentAsset : currentAssets) {
			Asset oldAsset = oldAssetMap.get(currentAsset.Id);
			if(currentAsset.Exterior_Colour__c != oldAsset.Exterior_Colour__c) {
				assetsWithNewColour.add(currentAsset);
			}
		}

		this.SetColourGroup(assetsWithNewColour);
	}

	public void SetColourGroup(List<Asset> assets)
	{
		Map<String, Colour_Group_Mapping__c> colourMappingByName = Colour_Group_Mapping__c.getAll();

		for(Asset asset : assets) {
			if(String.isBlank(asset.Exterior_Colour__c)) { continue; }

			Colour_Group_Mapping__c colourMapping = colourMappingByName.get(asset.Exterior_Colour__c);
			if(colourMapping == null || String.isBlank(colourMapping.Colour_Group__c)) {
				asset.Exterior_Colour_Group__c = 'Other';
				continue;
			}
			
			asset.Exterior_Colour_Group__c = colourMapping.Colour_Group__c;
		}
	}
}