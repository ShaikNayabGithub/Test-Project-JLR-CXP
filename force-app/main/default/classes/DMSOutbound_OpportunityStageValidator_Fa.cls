public class DMSOutbound_OpportunityStageValidator_Fa {
	public DMSOutbound_OpportunityStageValidator Create()
	{
		Map<String, DoNotSendOpportunityStages_India__c> excludedStageSettings = DoNotSendOpportunityStages_India__c.getAll();
		List<String> excludedStages = new List<String>(excludedStageSettings.keySet());

		return new DMSOutbound_OpportunityStageValidator(excludedStages);
	}
}