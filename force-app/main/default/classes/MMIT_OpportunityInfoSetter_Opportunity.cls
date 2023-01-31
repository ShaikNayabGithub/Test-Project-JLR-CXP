public class MMIT_OpportunityInfoSetter_Opportunity {
	private final MMIT_OpportunityLineItemRetriever opportunityLineItemRetriever;
	private final MMIT_AssetRetriever assetRetriever;
	private final MMIT_OpportunityHandoverInfoSetter opportunityHandoverInfoSetter;

	private static final Schema.DescribeFieldResult OPPORTUNITY_ID_FIELD = Schema.Opportunity.Id.getDescribe();
	

	public MMIT_OpportunityInfoSetter_Opportunity(MMIT_OpportunityLineItemRetriever opportunityLineItemRetriever,
			MMIT_AssetRetriever assetRetriever, 
			MMIT_OpportunityHandoverInfoSetter opportunityHandoverInfoSetter)
	{
		this.opportunityLineItemRetriever = opportunityLineItemRetriever;
		this.assetRetriever = assetRetriever;
		this.opportunityHandoverInfoSetter = opportunityHandoverInfoSetter;
	}


	public void SetVehicleInfo(List<Opportunity> opportunties, Map<Id, Opportunity> oldMap)
	{
		List<Opportunity> opportunitiesToProcess = new List<Opportunity>();
		for(Opportunity opportunity : opportunties) {
			Opportunity oldOpportunity = oldMap.get(opportunity.Id);
			if(opportunity.StageName != oldOpportunity.StageName) {
				opportunitiesToProcess.add(opportunity);
			}
		}
		this.SetVehicleInfo(opportunitiesToProcess);
	}

	public void SetVehicleInfo(List<Opportunity> opportunties)
	{
		List<Opportunity> opportunitiesToProcess = new List<Opportunity>();
		for(Opportunity opportunity : opportunties) {
			if(opportunity.StageName == 'Handover' || opportunity.StageName == 'Won'|| opportunity.StageName == 'Handover & RDA' ) {
				opportunitiesToProcess.add(opportunity);
			}
		}
		Set<String> opportunityIds = SObjectUtilities.GetFieldValues(opportunitiesToProcess, 
				OPPORTUNITY_ID_FIELD.getName());
		Map<String, List<Asset>> assetsByOpportunityId = this.assetRetriever.RetrieveByOpportunityId(opportunityIds);
		List<OpportunityLineItem> opportuntyLineItems = opportunityLineItemRetriever.Retrieve(opportunityIds);

		opportunityHandoverInfoSetter.SetVehicleInfo(assetsByOpportunityId, opportuntyLineItems, opportunitiesToProcess);
	}
}