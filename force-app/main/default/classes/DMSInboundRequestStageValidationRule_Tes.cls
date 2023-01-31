@isTest
private class DMSInboundRequestStageValidationRule_Tes {
     static testMethod void Validate_SetsResponseErrorCodeTo10002_GivenNullStage() {
        List<String> existingStages = new List<String>();
        Dummy_DMSAdapter_OpportunityStage opportunityStageAdapter = new Dummy_DMSAdapter_OpportunityStage();
        DMSInboundRequestStageValidationRule stageValidationRule = new DMSInboundRequestStageValidationRule(existingStages, opportunityStageAdapter);
        
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = new DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity();
        DMSInboundUpdateResponse response = new DMSInboundUpdateResponse(request.SFOpportunityID, request.DMSOpportunityID);
        response.ErrorCode = 40;
        
        stageValidationRule.Validate(request, response);
        
        System.assertEquals(10002, response.ErrorCode);
    }
    
    
    static testMethod void Validate_SetsResponseErrorMessage_GivenNullStage() {
        List<String> existingStages = new List<String>();
        Dummy_DMSAdapter_OpportunityStage opportunityStageAdapter = new Dummy_DMSAdapter_OpportunityStage();
        DMSInboundRequestStageValidationRule stageValidationRule = new DMSInboundRequestStageValidationRule(existingStages, opportunityStageAdapter);
        
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = new DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity();
        DMSInboundUpdateResponse response = new DMSInboundUpdateResponse(request.SFOpportunityID, request.DMSOpportunityID);
        response.ResponseMessage = 'old message';
        
        stageValidationRule.Validate(request, response);
        
        System.assertEquals(System.Label.DMSException_InvalidStage, response.ResponseMessage);
    }
    
    
    static testMethod void Validate_DoesnotSetResponseErrorCode_GivenExistingStage() {
    	string existingStage = 'existing stage';
        List<String> existingStages = new List<String>();
        existingStages.add(existingStage);
        
        Dummy_DMSAdapter_OpportunityStage opportunityStageAdapter = new Dummy_DMSAdapter_OpportunityStage();
        DMSInboundRequestStageValidationRule stageValidationRule = new DMSInboundRequestStageValidationRule(existingStages, opportunityStageAdapter);
        
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = new DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity();
        DMSInboundUpdateResponse response = new DMSInboundUpdateResponse(request.SFOpportunityID, request.DMSOpportunityID);
        request.Stage = existingStage;
        response.ErrorCode = 40;
        
        stageValidationRule.Validate(request, response);
        
        System.assertEquals(40, response.ErrorCode);
    }
    
    
    static testMethod void Validate_DoesnotSetResponseErrorMessage_GivenExistingStage() {
        string existingStage = 'existing stage';
        List<String> existingStages = new List<String>();
        existingStages.add(existingStage);
        
        Dummy_DMSAdapter_OpportunityStage opportunityStageAdapter = new Dummy_DMSAdapter_OpportunityStage();
        DMSInboundRequestStageValidationRule stageValidationRule = new DMSInboundRequestStageValidationRule(existingStages, opportunityStageAdapter);
        
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = new DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity();
        DMSInboundUpdateResponse response = new DMSInboundUpdateResponse(request.SFOpportunityID, request.DMSOpportunityID);
        request.Stage = existingStage;
        response.ResponseMessage = 'old message';
        
        stageValidationRule.Validate(request, response);
        
        System.assertEquals('old message', response.ResponseMessage);
    }
    
    private class Dummy_DMSAdapter_OpportunityStage implements I_DMSAdapter_OpportunityStage{
    	public string GetSalesforceValue(string dmsValue)
    	{
    		return dmsValue;
    	}
    }
}