public interface I_DMSInboundRequestValidationRule {
    void Validate(DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity inboundDMSRequest, 
    	DMSInboundUpdateResponse postValidationResponse);
}