public class DMSInboundRequestOpportunityExistsRule implements I_DMSInboundRequestValidationRule{
	private final Set<Id> existingOpportunityIds; 
	
	public DMSInboundRequestOpportunityExistsRule(Set<Id> existingOpportunityIds)
	{
		this.existingOpportunityIds = existingOpportunityIds;
	}
	
    public void Validate(DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity inboundDMSRequest, 
    	DMSInboundUpdateResponse postValidationResponse)
    {
    	if(existingOpportunityIds.contains(inboundDMSRequest.SFOpportunityID)){ return; }
    	string exceptionMessage = String.format(System.Label.DMSException_OpportunityNotFound, new List<String> { inboundDMSRequest.DMSOpportunityID });
    	postValidationResponse.SetError(10004, exceptionMessage);
    }
}