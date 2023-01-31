@isTest
public class DMSInboundRequestMandatoryFieldsRule_Tes {
	static testMethod void Validate_DoesNotSetResponseErrorCode_GivenValidRequest() {
        DMSInboundRequestMandatoryFieldsRule rule = new DMSInboundRequestMandatoryFieldsRule();
        
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = CreateValidRequest();
        
        DMSInboundUpdateResponse response = new DMSInboundUpdateResponse(request.SFOpportunityID, request.DMSOpportunityID);
        response.ErrorCode = 40;
        
        rule.Validate(request, response);
        
        System.assertEquals(40, response.ErrorCode);
    }
    
    static testMethod void Validate_DoesNotSetResponseErrorMessage_GivenValidRequest() {
        DMSInboundRequestMandatoryFieldsRule rule = new DMSInboundRequestMandatoryFieldsRule();
        
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = CreateValidRequest();
        
        DMSInboundUpdateResponse response = new DMSInboundUpdateResponse(request.SFOpportunityID, request.DMSOpportunityID);
        response.ResponseMessage = 'pre-validation message';
        
        rule.Validate(request, response);
        
        System.assertEquals('pre-validation message', response.ResponseMessage);
    }
	
    static testMethod void Validate_SetsResponseErrorCodeTo1_GivenNullDMSOpportunityID() {
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = CreateValidRequest();
        request.DMSOpportunityID = null;
        
        AssertErrorCodeSetTo1(request);
    }
    
    static testMethod void Validate_SetsResponseErrorCodeTo1_GivenEmptyDMSOpportunityID() {
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = CreateValidRequest();
        request.DMSOpportunityID = '';
        
        AssertErrorCodeSetTo1(request);
    }
    
    static testMethod void Validate_SetsResponseErrorMessage_GivenNullDMSOpportunityID() {
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = CreateValidRequest();
        request.DMSOpportunityID = null;
        
        AssertErrorMessageChanged(request);
    }
    
    static testMethod void Validate_SetsResponseErrorMessage_GivenEmptyDMSOpportunityID() {
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = CreateValidRequest();
        request.DMSOpportunityID = '';
        
        AssertErrorMessageChanged(request);
    }
    
    
    static testMethod void Validate_SetsResponseErrorCodeTo1_GivenNullSFOpportunityID() {
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = CreateValidRequest();
        request.SFOpportunityID = null;
        
        AssertErrorCodeSetTo1(request);
    }
    
    static testMethod void Validate_SetsResponseErrorMessage_GivenNullSFOpportunityID() {
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = CreateValidRequest();
        request.SFOpportunityID = null;
        
        AssertErrorMessageChanged(request);
    }
    
    
    static testMethod void Validate_SetsResponseErrorCodeTo1_GivenNullStage() {
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = CreateValidRequest();
        request.Stage = null;
        
        AssertErrorCodeSetTo1(request);
    }
    
    static testMethod void Validate_SetsResponseErrorCodeTo1_GivenEmptyStage() {
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = CreateValidRequest();
        request.Stage = '';
        
        AssertErrorCodeSetTo1(request);
    }
    
    static testMethod void Validate_SetsResponseErrorMessage_GivenNullStage() {
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = CreateValidRequest();
        request.Stage = null;
        
        AssertErrorMessageChanged(request);
    }
    
    static testMethod void Validate_SetsResponseErrorMessage_GivenEmptyStage() {
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = CreateValidRequest();
        request.Stage = '';
        
        AssertErrorMessageChanged(request);
    }
    
    
    static testMethod void Validate_SetsResponseErrorCodeTo1_GivenNullMake() {
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = CreateValidRequest();
        request.Make = null;
        
        AssertErrorCodeSetTo1(request);
    }
    
    static testMethod void Validate_SetsResponseErrorCodeTo1_GivenEmptyMake() {
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = CreateValidRequest();
        request.Make = '';
        
        AssertErrorCodeSetTo1(request);
    }
    
    static testMethod void Validate_SetsResponseErrorMessage_GivenNullMake() {
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = CreateValidRequest();
        request.Make = null;
        
        AssertErrorMessageChanged(request);
    }
    
    static testMethod void Validate_SetsResponseErrorMessage_GivenEmptyMake() {
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = CreateValidRequest();
        request.Make = '';
        
        AssertErrorMessageChanged(request);
    }
    
    
    static testMethod void Validate_SetsResponseErrorCodeTo1_GivenNullModel() {
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = CreateValidRequest();
        request.Model = null;
        
        AssertErrorCodeSetTo1(request);
    }
    
    static testMethod void Validate_SetsResponseErrorCodeTo1_GivenEmptyModel() {
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = CreateValidRequest();
        request.Model = '';
        
        AssertErrorCodeSetTo1(request);
    }
    
    static testMethod void Validate_SetsResponseErrorMessage_GivenNullModel() {
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = CreateValidRequest();
        request.Model = null;
        
        AssertErrorMessageChanged(request);
    }
    
    static testMethod void Validate_SetsResponseErrorMessage_GivenEmptyModel() {
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = CreateValidRequest();
        request.Model = '';
        
        AssertErrorMessageChanged(request);
    }
    
    
    static testMethod void Validate_SetsResponseErrorCodeTo1_GivenNullDerivative() {
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = CreateValidRequest();
        request.Derivative = null;
        
        AssertErrorCodeSetTo1(request);
    }
    
    static testMethod void Validate_SetsResponseErrorCodeTo1_GivenEmptyDerivative() {
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = CreateValidRequest();
        request.Derivative = '';
        
        AssertErrorCodeSetTo1(request);
    }
    
    static testMethod void Validate_SetsResponseErrorMessage_GivenNullDerivative() {
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = CreateValidRequest();
        request.Derivative = null;
        
        AssertErrorMessageChanged(request);
    }
    
    static testMethod void Validate_SetsResponseErrorMessage_GivenEmptyDerivative() {
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = CreateValidRequest();
        request.Derivative = '';
        
        AssertErrorMessageChanged(request);
    }
    
    
    static testMethod void Validate_SetsResponseErrorCodeTo1_GivenNullStageTimestamp() {
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = CreateValidRequest();
        request.StageTimestamp = null;
        
        AssertErrorCodeSetTo1(request);
    }
    
    static testMethod void Validate_SetsResponseErrorCodeTo1_GivenEmptyStageTimestamp() {
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = CreateValidRequest();
        request.StageTimestamp = '';
        
        AssertErrorCodeSetTo1(request);
    }
    
    static testMethod void Validate_SetsResponseErrorMessage_GivenNullStageTimestamp() {
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = CreateValidRequest();
        request.StageTimestamp = null;
        
        AssertErrorMessageChanged(request);
    }
    
    static testMethod void Validate_SetsResponseErrorMessage_GivenEmptyStageTimestamp() {
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = CreateValidRequest();
        request.StageTimestamp = '';
        
        AssertErrorMessageChanged(request);
    }
    
    
    private static void AssertErrorCodeSetTo1(DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request)
    {
    	DMSInboundRequestMandatoryFieldsRule rule = new DMSInboundRequestMandatoryFieldsRule();
    	DMSInboundUpdateResponse response = new DMSInboundUpdateResponse(request.SFOpportunityID, request.DMSOpportunityID);
        response.ErrorCode = 40;
        
        rule.Validate(request, response);
        
        System.assertEquals(1, response.ErrorCode);
    }
    
    private static void AssertErrorMessageChanged(DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request)
    {
    	DMSInboundRequestMandatoryFieldsRule rule = new DMSInboundRequestMandatoryFieldsRule();
    	DMSInboundUpdateResponse response = new DMSInboundUpdateResponse(request.SFOpportunityID, request.DMSOpportunityID);
        response.ResponseMessage = 'pre-validation message';
        
        rule.Validate(request, response);
        
        System.assertNotEquals('pre-validation message', response.ResponseMessage);
    }
    
    private static DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity CreateValidRequest()
    {
    	DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = new DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity();
    	request.DMSOpportunityID = 'valid';
    	request.SFOpportunityID = '07M8E000000IgNX';
    	request.Stage = 'valid';
    	request.Make = 'valid';
    	request.Model = 'valid';
    	request.Derivative = 'valid';
    	request.StageTimestamp = 'valid';
    	return request;
    }
}