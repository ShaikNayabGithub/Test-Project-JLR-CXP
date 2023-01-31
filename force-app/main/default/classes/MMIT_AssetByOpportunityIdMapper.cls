public class MMIT_AssetByOpportunityIdMapper {
	public Map<String, List<Asset>> MapAssets(List<Asset> assets)
	{
		Map<String, List<Asset>> outputMap = new Map<String, List<Asset>>();

		for(Asset asset : assets) {
			if(asset.Order__r == null || String.isBlank(asset.Order__r.OpportunityId)) { continue; }
			
			List<Asset> subList = outputMap.get(asset.Order__r.OpportunityId);
			if(subList == null) {
				subList = new List<Asset>();
				outputMap.put(asset.Order__r.OpportunityId, subList);
			}
			subList.add(asset);
		}

		return outputMap;
	}
}