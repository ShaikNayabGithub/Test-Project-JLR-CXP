public class MMIT_OpportunityInfoSetter_Asset_F {
	public MMIT_OpportunityInfoSetter_Asset Create()
	{
		MMIT_AssetByOpportunityIdMapper assetByOpportunityIdMapper = new MMIT_AssetByOpportunityIdMapper();
		
		MMIT_AssetRetriever assetRetriever = new MMIT_AssetRetriever(assetByOpportunityIdMapper);
		MMIT_OpportunityRetriever opportunityRetriever = new MMIT_OpportunityRetriever();
		MMIT_OpportunityLineItemRetriever opportunityLineItemRetriever = new MMIT_OpportunityLineItemRetriever();
		MMIT_OpportunityHandoverInfoSetter opportunityHandoverInfoSetter = new MMIT_OpportunityHandoverInfoSetter();

		return new MMIT_OpportunityInfoSetter_Asset(assetRetriever, opportunityRetriever,
				opportunityLineItemRetriever, opportunityHandoverInfoSetter);
	}
}