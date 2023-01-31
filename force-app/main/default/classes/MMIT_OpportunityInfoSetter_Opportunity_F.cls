public class MMIT_OpportunityInfoSetter_Opportunity_F {
	public MMIT_OpportunityInfoSetter_Opportunity Create()
	{
		MMIT_AssetByOpportunityIdMapper assetByOpportunityIdMapper = new MMIT_AssetByOpportunityIdMapper();
		
		MMIT_OpportunityLineItemRetriever opportunityLineItemRetriever = new MMIT_OpportunityLineItemRetriever();
		MMIT_AssetRetriever assetRetriever = new MMIT_AssetRetriever(assetByOpportunityIdMapper);
		MMIT_OpportunityHandoverInfoSetter opportunityHandoverInfoSetter = new MMIT_OpportunityHandoverInfoSetter();

		return new MMIT_OpportunityInfoSetter_Opportunity(opportunityLineItemRetriever, assetRetriever, 
				opportunityHandoverInfoSetter);
	}
}