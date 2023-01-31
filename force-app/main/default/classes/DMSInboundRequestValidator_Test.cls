@isTest
private class DMSInboundRequestValidator_Test {

    static testMethod void Validate_CallsSecondValidationRule_GivenFirstPasses() {
    	List<I_DMSInboundRequestValidationRule> validationRules = new List<I_DMSInboundRequestValidationRule>();
        DMSInboundRequestValidator_DummyPositive positiveValidationRule = new DMSInboundRequestValidator_DummyPositive();
        DMSInboundRequestValidator_DummyNegative negativeValidationRule = new DMSInboundRequestValidator_DummyNegative();
        validationRules.add(positiveValidationRule);
        validationRules.add(negativeValidationRule);
        
        DMSInboundRequestValidator dmsInboundRequestValidator = new DMSInboundRequestValidator(validationRules);
 		
 		DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity inboundDMSRequest = new DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity();
 		Id dummyId = null;
 		DMSInboundUpdateResponse postValidationResponse = new DMSInboundUpdateResponse(dummyId, '');
 		
 		dmsInboundRequestValidator.Validate(inboundDMSRequest, postValidationResponse);
 		
 		System.assert(negativeValidationRule.HasBeenCalled);
    }
    
    
    static testMethod void Validate_DoesNotCallThirdValidationRule_GivenFirstPasses() {
    	List<I_DMSInboundRequestValidationRule> validationRules = new List<I_DMSInboundRequestValidationRule>();
        DMSInboundRequestValidator_DummyPositive positiveValidationRule1 = new DMSInboundRequestValidator_DummyPositive();
        DMSInboundRequestValidator_DummyNegative negativeValidationRule1 = new DMSInboundRequestValidator_DummyNegative();
        DMSInboundRequestValidator_DummyPositive positiveValidationRule2 = new DMSInboundRequestValidator_DummyPositive();
        validationRules.add(positiveValidationRule1);
        validationRules.add(negativeValidationRule1);
        validationRules.add(positiveValidationRule2);
        
        DMSInboundRequestValidator dmsInboundRequestValidator = new DMSInboundRequestValidator(validationRules);
 		
 		DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity inboundDMSRequest = new DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity();
 		Id dummyId = null;
 		DMSInboundUpdateResponse postValidationResponse = new DMSInboundUpdateResponse(dummyId, '');
 		
 		dmsInboundRequestValidator.Validate(inboundDMSRequest, postValidationResponse);
 		
 		System.assert(!positiveValidationRule2.HasBeenCalled);
    }
    
    
    private class DMSInboundRequestValidator_DummyPositive implements I_DMSInboundRequestValidationRule{
    	boolean HasBeenCalled = false;
    	
    	public void Validate(DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity inboundDMSRequest, DMSInboundUpdateResponse postValidationResponse)
    	{
    		HasBeenCalled = true;
    	}
    }
    
    private class DMSInboundRequestValidator_DummyNegative implements I_DMSInboundRequestValidationRule{
    	boolean HasBeenCalled = false;
    	
    	public void Validate(DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity inboundDMSRequest, DMSInboundUpdateResponse postValidationResponse)
    	{
    		HasBeenCalled = true;
    		postValidationResponse.IsSuccess = false;
    	}
    }
}