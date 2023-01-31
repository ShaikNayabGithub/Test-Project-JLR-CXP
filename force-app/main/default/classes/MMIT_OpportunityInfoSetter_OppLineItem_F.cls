public class MMIT_OpportunityInfoSetter_OppLineItem_F {
	public MMIT_OpportunityInfoSetter_OppLineItem Create()
	{
		MMIT_AssetByOpportunityIdMapper assetByOpportunityIdMapper = new MMIT_AssetByOpportunityIdMapper();
		
		MMIT_OpportunityRetriever opportunityRetriever = new MMIT_OpportunityRetriever();
		MMIT_AssetRetriever assetRetriever = new MMIT_AssetRetriever(assetByOpportunityIdMapper);
		MMIT_OpportunityHandoverInfoSetter opportunityHandoverInfoSetter = new MMIT_OpportunityHandoverInfoSetter();

		return new MMIT_OpportunityInfoSetter_OppLineItem(opportunityRetriever, assetRetriever, 
				opportunityHandoverInfoSetter);
	}
}