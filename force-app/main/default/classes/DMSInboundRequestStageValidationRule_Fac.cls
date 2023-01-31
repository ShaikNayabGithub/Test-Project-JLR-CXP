public class DMSInboundRequestStageValidationRule_Fac {
	public DMSInboundRequestStageValidationRule Create()
	{
		I_DMSAdapter_OpportunityStage opportunityStageAdapter = new DMSAdapter_OpportunityStage_India();
		List<Schema.PicklistEntry> opportunityStages = Opportunity.StageName.getDescribe().getPicklistValues();
    	
    	List<String> opportunityStageLabels = new List<string>();
    	for(Schema.PicklistEntry picklistEntry : opportunityStages)
    	{
            string picklistLabel = picklistEntry.getvalue();
            opportunityStageLabels.add(picklistLabel);
    	}
    	
    	return new DMSInboundRequestStageValidationRule(opportunityStageLabels, opportunityStageAdapter);
	}   
}