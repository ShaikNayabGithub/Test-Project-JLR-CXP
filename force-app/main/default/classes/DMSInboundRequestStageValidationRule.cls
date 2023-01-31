public class DMSInboundRequestStageValidationRule implements I_DMSInboundRequestValidationRule{
    private final List<String> opportunityStages;
    private final I_DMSAdapter_OpportunityStage opportunityStageAdapter;
    
    public DMSInboundRequestStageValidationRule(List<String> opportunityStages, I_DMSAdapter_OpportunityStage opportunityStageAdapter)
    {
    	this.opportunityStages = opportunityStages;
    	this.opportunityStageAdapter = opportunityStageAdapter;
    }
    
    public void Validate(DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity inboundDMSRequest, 
    	DMSInboundUpdateResponse postValidationResponse)
    {
    	string salesforceStage = opportunityStageAdapter.GetSalesforceValue(inboundDMSRequest.Stage);
    	for(String opportunityStage : opportunityStages)
    	{
    		if(opportunityStage == salesforceStage){ return; }
    	}
    	postValidationResponse.SetError(10002, System.Label.DMSException_InvalidStage);
    }
}