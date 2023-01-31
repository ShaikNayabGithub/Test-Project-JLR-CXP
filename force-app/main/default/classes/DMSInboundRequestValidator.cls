public class DMSInboundRequestValidator {
	private final List<I_DMSInboundRequestValidationRule> validationRules;
	
	public DMSInboundRequestValidator(List<I_DMSInboundRequestValidationRule> validationRules)
	{
		this.validationRules = validationRules;
	}
	
    public void Validate(DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity inboundDMSRequest, DMSInboundUpdateResponse postValidationResponse)
    {
    	for(I_DMSInboundRequestValidationRule validationRule : validationRules)
    	{
    		validationRule.Validate(inboundDMSRequest, postValidationResponse);
    		if(!postValidationResponse.IsSuccess){ return; }
    	}
    }
}