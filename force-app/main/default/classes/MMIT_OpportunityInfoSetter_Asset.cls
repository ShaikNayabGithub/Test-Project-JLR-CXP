public class MMIT_OpportunityInfoSetter_Asset {
    private final MMIT_AssetRetriever assetRetriever;
    private final MMIT_OpportunityRetriever opportunityRetriever;
    private final MMIT_OpportunityLineItemRetriever opportunityLineItemRetriever;
    private final MMIT_OpportunityHandoverInfoSetter opportunityHandoverInfoSetter;


    public MMIT_OpportunityInfoSetter_Asset(MMIT_AssetRetriever assetRetriever,
            MMIT_OpportunityRetriever opportunityRetriever,
            MMIT_OpportunityLineItemRetriever opportunityLineItemRetriever,
            MMIT_OpportunityHandoverInfoSetter opportunityHandoverInfoSetter)
    {
        this.assetRetriever = assetRetriever;
        this.opportunityRetriever = opportunityRetriever;
        this.opportunityLineItemRetriever = opportunityLineItemRetriever;
        this.opportunityHandoverInfoSetter = opportunityHandoverInfoSetter;
    }


    public void SetVehicleInfo(List<Asset> assets, Map<Id, Asset> oldMap)
    {
        List<Asset> assetsToProcess = new List<Asset>();
        for(Asset asset : assets) {
            Asset oldAsset = oldMap.get(asset.Id);
            if(asset.Vin__c != oldAsset.VIN__c || asset.Derivative__c != oldAsset.Derivative__c) {
                assetsToProcess.add(asset);
            }
        }
        this.SetVehicleInfo(assetsToProcess);
    }

    public void SetVehicleInfo(List<Asset> assets)
    {
        Map<String, List<Asset>> assetsByOpportunityId = assetRetriever.RetrieveByOpportunityId(assets);
        List<Opportunity> opportunties = opportunityRetriever.Retrieve(assetsByOpportunityId.keySet());
        List<OpportunityLineItem> opportuntyLineItems = opportunityLineItemRetriever.Retrieve(assetsByOpportunityId.keySet());

        opportunityHandoverInfoSetter.SetVehicleInfo(assetsByOpportunityId, opportuntyLineItems, opportunties);
        update opportunties;
    }
}