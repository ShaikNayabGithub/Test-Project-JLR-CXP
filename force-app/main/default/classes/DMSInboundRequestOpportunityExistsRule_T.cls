@isTest
private class DMSInboundRequestOpportunityExistsRule_T {
    static testMethod void Validate_SetsResponseErrorCodeTo4_GivenNullId() {
        Set<Id> existingOpportunityIds = new Set<Id>();
        DMSInboundRequestOpportunityExistsRule opportunityExistsRule = new DMSInboundRequestOpportunityExistsRule(existingOpportunityIds);
        
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = new DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity();
        DMSInboundUpdateResponse response = new DMSInboundUpdateResponse(request.SFOpportunityID, request.DMSOpportunityID);
        
        opportunityExistsRule.Validate(request, response);
        
        System.assertEquals(10004, response.ErrorCode);
    }
    
    
    static testMethod void Validate_SetsResponseErrorMessage_GivenNullId() {
        Set<Id> existingOpportunityIds = new Set<Id>();
        DMSInboundRequestOpportunityExistsRule opportunityExistsRule = new DMSInboundRequestOpportunityExistsRule(existingOpportunityIds);
        
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = new DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity();
        DMSInboundUpdateResponse response = new DMSInboundUpdateResponse(request.SFOpportunityID, request.DMSOpportunityID);
        
        opportunityExistsRule.Validate(request, response);
        
        System.assertEquals( String.format(System.Label.DMSException_OpportunityNotFound, new List<String> { request.DMSOpportunityID }), response.ResponseMessage);
    }
    
    @isTest(SeeAllData=true)
    static void Validate_DoesNotSetResponseErrorMessage_GivenExistingId() {
    	Id testId = Id.valueOf('0A28E000000Ccn0');
    	
        Set<Id> existingOpportunityIds = new Set<Id>();
        existingOpportunityIds.add(testId);
        
        DMSInboundRequestOpportunityExistsRule opportunityExistsRule = new DMSInboundRequestOpportunityExistsRule(existingOpportunityIds);
        
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = new DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity();
        request.SFOpportunityID = testId;
        DMSInboundUpdateResponse response = new DMSInboundUpdateResponse(request.SFOpportunityID, request.DMSOpportunityID);
        response.ResponseMessage = 'pre-execution message';
        
        opportunityExistsRule.Validate(request, response);
        
        System.assertEquals('pre-execution message', response.ResponseMessage);
    }
    
    
    @isTest(SeeAllData=true)
    static void Validate_DoesNotSetResponseErrorCode_GivenExistingId() {
    	Id testId = Id.valueOf('0A28E000000Ccn0');
    	
        Set<Id> existingOpportunityIds = new Set<Id>();
        existingOpportunityIds.add(testId);
        
        DMSInboundRequestOpportunityExistsRule opportunityExistsRule = new DMSInboundRequestOpportunityExistsRule(existingOpportunityIds);
        
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = new DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity();
        request.SFOpportunityID = testId;
        DMSInboundUpdateResponse response = new DMSInboundUpdateResponse(request.SFOpportunityID, request.DMSOpportunityID);
        response.ErrorCode = 40;
        
        opportunityExistsRule.Validate(request, response);
        
        System.assertEquals(40, response.ErrorCode);
    }
}