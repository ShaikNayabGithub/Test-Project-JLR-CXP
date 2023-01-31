public class DMSInboundRequestMandatoryFieldsRule implements I_DMSInboundRequestValidationRule{
    public void Validate(DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity inboundDMSRequest, 
    	DMSInboundUpdateResponse postValidationResponse)
    {
    	if(String.isBlank(inboundDMSRequest.DMSOpportunityID) || 
    		String.isBlank(inboundDMSRequest.SFOpportunityID) ||
    		String.isBlank(inboundDMSRequest.Stage) ||
    		String.isBlank(inboundDMSRequest.Make) ||
    		String.isBlank(inboundDMSRequest.Model) ||
    		String.isBlank(inboundDMSRequest.Derivative) ||
    		String.isBlank(inboundDMSRequest.StageTimestamp))
		{
			postValidationResponse.SetError(1, System.Label.DMSException_MissingFields);
		}
    }
}