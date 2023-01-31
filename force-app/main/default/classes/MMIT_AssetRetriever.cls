public class MMIT_AssetRetriever {
    private MMIT_AssetByOpportunityIdMapper assetByOpportunityIdMapper;


    public MMIT_AssetRetriever(MMIT_AssetByOpportunityIdMapper assetByOpportunityIdMapper)
    {
        this.assetByOpportunityIdMapper = assetByOpportunityIdMapper;
    }


    public Map<String, List<Asset>> RetrieveByOpportunityId(Set<String> opportunityIds)
    {
    
        if(opportunityIds.isEmpty()){
        return new Map<String, List<Asset>>();
        }
   
        List<Asset> retrievedAssets = [SELECT Id, Brand__c, Model__c, Derivative__c, VIN__c, Order_Number__c,
                Order__r.OpportunityId
                FROM Asset WHERE Order__r.OpportunityId IN: opportunityIds];

        return this.assetByOpportunityIdMapper.MapAssets(retrievedAssets);
    }

    public Map<String, List<Asset>> RetrieveByOpportunityId(List<Asset> assets)
    {
        Map<Id, Asset> inputAssetMap = new Map<Id, Asset>(assets);
        
        List<Asset> retrievedAssets = [SELECT Id, Brand__c, Model__c, Derivative__c, VIN__c, Order_Number__c,
                Order__r.OpportunityId
                FROM Asset WHERE Id IN: inputAssetMap.keySet()];

        return this.assetByOpportunityIdMapper.MapAssets(retrievedAssets);
    }
}