@isTest
public class DMSInboundRequestFormatValidationRule_Te {
    static testMethod void Validate_DoesNotSetResponseErrorCode_GivenValidRequest() {
        DMSInboundRequestFormatValidationRule rule = CreateFormatRule();
        
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = BuildValidRequest();
        DMSInboundUpdateResponse response = new DMSInboundUpdateResponse(request.SFOpportunityID, request.DMSOpportunityID);
        response.ErrorCode = 40;
        
        rule.Validate(request, response);
        
        System.assertEquals(40, response.ErrorCode);
    }
    
    static testMethod void Validate_DoesNotSetResponseErrorMessage_GivenValidRequest() {
        DMSInboundRequestFormatValidationRule rule = CreateFormatRule();
        
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = BuildValidRequest();
        DMSInboundUpdateResponse response = new DMSInboundUpdateResponse(request.SFOpportunityID, request.DMSOpportunityID);
        response.ResponseMessage = 'pre-execution message';
        
        rule.Validate(request, response);
        
        System.assertEquals('pre-execution message', response.ResponseMessage);
    }
    
    
    static testMethod void Validate_DoesNotSetResponseErrorCode_GivenEmptyStageTimestamp() {
        DMSInboundRequestFormatValidationRule rule = CreateFormatRule();
        
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = BuildValidRequest();
        request.StageTimestamp = '';
        DMSInboundUpdateResponse response = new DMSInboundUpdateResponse(request.SFOpportunityID, request.DMSOpportunityID);
        response.ErrorCode = 40;
        
        rule.Validate(request, response);
        
        System.assertEquals(40, response.ErrorCode);
    }
    
    static testMethod void Validate_DoesNotSetResponseErrorMessage_GivenEmptyStageTimestamp() {
        DMSInboundRequestFormatValidationRule rule = CreateFormatRule();
        
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = BuildValidRequest();
        request.StageTimestamp = '';
        DMSInboundUpdateResponse response = new DMSInboundUpdateResponse(request.SFOpportunityID, request.DMSOpportunityID);
        response.ResponseMessage = 'pre-execution message';
        
        rule.Validate(request, response);
        
        System.assertEquals('pre-execution message', response.ResponseMessage);
    }
    
    
    static testMethod void Validate_DoesNotSetResponseErrorCode_GivenNullStageTimestamp() {
        DMSInboundRequestFormatValidationRule rule = CreateFormatRule();
        
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = BuildValidRequest();
        request.StageTimestamp = null;
        DMSInboundUpdateResponse response = new DMSInboundUpdateResponse(request.SFOpportunityID, request.DMSOpportunityID);
        response.ErrorCode = 40;
        
        rule.Validate(request, response);
        
        System.assertEquals(40, response.ErrorCode);
    }
    
    static testMethod void Validate_DoesNotSetResponseErrorMessage_GivenNullStageTimestamp() {
        DMSInboundRequestFormatValidationRule rule = CreateFormatRule();
        
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = BuildValidRequest();
        request.StageTimestamp = null;
        DMSInboundUpdateResponse response = new DMSInboundUpdateResponse(request.SFOpportunityID, request.DMSOpportunityID);
        response.ResponseMessage = 'pre-execution message';
        
        rule.Validate(request, response);
        
        System.assertEquals('pre-execution message', response.ResponseMessage);
    }
    
    
    static testMethod void Validate_SetsResponseErrorMessage_GivenInvalidStageTimestamp() {
        DMSInboundRequestFormatValidationRule rule = CreateFormatRule();
        
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = BuildValidRequest();
        request.StageTimestamp = 'Invalid DateTime';
        DMSInboundUpdateResponse response = new DMSInboundUpdateResponse(request.SFOpportunityID, request.DMSOpportunityID);
        response.ResponseMessage = 'pre-execution message';
        
        rule.Validate(request, response);
        
        System.assertNotEquals('pre-execution message', response.ResponseMessage);
    }
    
    
    static testMethod void Validate_DoesNotSetResponseErrorCode_GivenEmptyCloseDate() {
        DMSInboundRequestFormatValidationRule rule = CreateFormatRule();
        
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = BuildValidRequest();
        request.CloseDate = '';
        DMSInboundUpdateResponse response = new DMSInboundUpdateResponse(request.SFOpportunityID, request.DMSOpportunityID);
        response.ErrorCode = 40;
        
        rule.Validate(request, response);
        
        System.assertEquals(40, response.ErrorCode);
    }
    
    static testMethod void Validate_DoesNotSetResponseErrorMessage_GivenEmptyCloseDate() {
        DMSInboundRequestFormatValidationRule rule = CreateFormatRule();
        
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = BuildValidRequest();
        request.CloseDate = '';
        DMSInboundUpdateResponse response = new DMSInboundUpdateResponse(request.SFOpportunityID, request.DMSOpportunityID);
        response.ResponseMessage = 'pre-execution message';
        
        rule.Validate(request, response);
        
        System.assertEquals('pre-execution message', response.ResponseMessage);
    }
    
    static testMethod void Validate_DoesNotSetResponseErrorCode_GivenNullCloseDate() {
        DMSInboundRequestFormatValidationRule rule = CreateFormatRule();
        
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = BuildValidRequest();
        request.CloseDate = null;
        DMSInboundUpdateResponse response = new DMSInboundUpdateResponse(request.SFOpportunityID, request.DMSOpportunityID);
        response.ErrorCode = 40;
        
        rule.Validate(request, response);
        
        System.assertEquals(40, response.ErrorCode);
    }
    
    static testMethod void Validate_DoesNotSetResponseErrorMessage_GivenNullCloseDate() {
        DMSInboundRequestFormatValidationRule rule = CreateFormatRule();
        
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = BuildValidRequest();
        request.CloseDate = null;
        DMSInboundUpdateResponse response = new DMSInboundUpdateResponse(request.SFOpportunityID, request.DMSOpportunityID);
        response.ResponseMessage = 'pre-execution message';
        
        rule.Validate(request, response);
        
        System.assertEquals('pre-execution message', response.ResponseMessage);
    }
    
    static testMethod void Validate_SetsResponseErrorMessage_GivenInvalidCloseDate() {
        DMSInboundRequestFormatValidationRule rule = CreateFormatRule();
        
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = BuildValidRequest();
        request.CloseDate = 'Invalid DateTime';
        DMSInboundUpdateResponse response = new DMSInboundUpdateResponse(request.SFOpportunityID, request.DMSOpportunityID);
        response.ResponseMessage = 'pre-execution message';
        
        rule.Validate(request, response);
        
        System.assertNotEquals('pre-execution message', response.ResponseMessage);
    }
    
    
    static testMethod void Validate_DoesNotSetResponseErrorCode_GivenEmptyNextFollowUpDate() {
        DMSInboundRequestFormatValidationRule rule = CreateFormatRule();
        
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = BuildValidRequest();
        request.DMSActivities[0].NextFollowUpDate = '';
        DMSInboundUpdateResponse response = new DMSInboundUpdateResponse(request.SFOpportunityID, request.DMSOpportunityID);
        response.ErrorCode = 40;
        
        rule.Validate(request, response);
        
        System.assertEquals(40, response.ErrorCode);
    }
    
    static testMethod void Validate_DoesNotSetResponseErrorMessage_GivenEmptyNextFollowUpDate() {
        DMSInboundRequestFormatValidationRule rule = CreateFormatRule();
        
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = BuildValidRequest();
        request.DMSActivities[0].NextFollowUpDate = '';
        DMSInboundUpdateResponse response = new DMSInboundUpdateResponse(request.SFOpportunityID, request.DMSOpportunityID);
        response.ResponseMessage = 'pre-execution message';
        
        rule.Validate(request, response);
        
        System.assertEquals('pre-execution message', response.ResponseMessage);
    }
    
    static testMethod void Validate_DoesNotSetResponseErrorCode_GivenNullNextFollowUpDate() {
        DMSInboundRequestFormatValidationRule rule = CreateFormatRule();
        
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = BuildValidRequest();
        request.DMSActivities[0].NextFollowUpDate = null;
        DMSInboundUpdateResponse response = new DMSInboundUpdateResponse(request.SFOpportunityID, request.DMSOpportunityID);
        response.ErrorCode = 40;
        
        rule.Validate(request, response);
        
        System.assertEquals(40, response.ErrorCode);
    }
    
    static testMethod void Validate_DoesNotSetResponseErrorMessage_GivenNullNextFollowUpDate() {
        DMSInboundRequestFormatValidationRule rule = CreateFormatRule();
        
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = BuildValidRequest();
        request.DMSActivities[0].NextFollowUpDate = null;
        DMSInboundUpdateResponse response = new DMSInboundUpdateResponse(request.SFOpportunityID, request.DMSOpportunityID);
        response.ResponseMessage = 'pre-execution message';
        
        rule.Validate(request, response);
        
        System.assertEquals('pre-execution message', response.ResponseMessage);
    }
    
    static testMethod void Validate_SetsResponseErrorMessage_GivenInvalidNextFollowUpDate() {
        DMSInboundRequestFormatValidationRule rule = CreateFormatRule();
        
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = BuildValidRequest();
        request.DMSActivities[0].NextFollowUpDate = 'Invalid DateTime';
        DMSInboundUpdateResponse response = new DMSInboundUpdateResponse(request.SFOpportunityID, request.DMSOpportunityID);
        response.ResponseMessage = 'pre-execution message';
        
        rule.Validate(request, response);
        
        System.assertNotEquals('pre-execution message', response.ResponseMessage);
    }
    
    
    private static DMSInboundRequestFormatValidationRule CreateFormatRule()
    {
        I_DateAdapter dateAdapter = new Date_India();
        I_TimeAdapter timeAdapter = new TimeAdapter_HHMMSS();
        DateTimeAdapter dateTimeAdapter = new DateTimeAdapter(dateAdapter, timeAdapter);
        return new DMSInboundRequestFormatValidationRule(dateTimeAdapter);
    }
    
    
    private static DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity BuildValidRequest()
    {
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = new DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity();
        request.StageTimestamp = '20-10-2015 235959';
        request.CloseDate = '20-10-2015';
        request.DMSActivities = new List<DMSInboundIntegrationService.DMSActivity>();
        DMSInboundIntegrationService.DMSActivity activity = new DMSInboundIntegrationService.DMSActivity();
        activity.NextFollowUpDate = '20-10-2015';
        request.DMSActivities.add(activity);
        return request;
    }
}