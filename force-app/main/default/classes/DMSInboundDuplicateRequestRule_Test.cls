@isTest
public class DMSInboundDuplicateRequestRule_Test {
    static testMethod void Validate_DoesNotSetResponseErrorCode_GivenValidRequest() {
        DMSInboundDuplicateRequestRule rule = CreateRule();
        
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = BuildValidRequest();
        DMSInboundUpdateResponse response = new DMSInboundUpdateResponse(request.SFOpportunityID, request.DMSOpportunityID);
        response.ErrorCode = 40;
        
        rule.Validate(request, response);
        
        System.assertEquals(40, response.ErrorCode);
    }

    static testMethod void Validate_DoesNotSetResponseErrorMessage_GivenValidRequest() {
        DMSInboundDuplicateRequestRule rule = CreateRule();
        
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = BuildValidRequest();
        DMSInboundUpdateResponse response = new DMSInboundUpdateResponse(request.SFOpportunityID, request.DMSOpportunityID);
        response.ResponseMessage = 'pre-execution message';
        
        rule.Validate(request, response);
        
        System.assertEquals('pre-execution message', response.ResponseMessage);
    }

    static testMethod void Validate_SetsResponseErrorMessage_GivenDuplicateRequest() {
        DMSInboundDuplicateRequestRule rule = CreateRule();
        
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request1 = BuildValidRequest();
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request2 = BuildValidRequest();
        DMSInboundUpdateResponse response1 = new DMSInboundUpdateResponse(request1.SFOpportunityID, request1.DMSOpportunityID);
        DMSInboundUpdateResponse response2 = new DMSInboundUpdateResponse(request2.SFOpportunityID, request2.DMSOpportunityID);
        response2.ResponseMessage = 'pre-execution message';
        
        rule.Validate(request1, response1);
        rule.Validate(request2, response2);
        
        System.assertNotEquals('pre-execution message', response2.ResponseMessage);
    }

    static testMethod void Validate_SetsResponseErrorMessage_GivenDuplicateRequestWithInvalidStageTimestamp() {
        DMSInboundDuplicateRequestRule rule = CreateRule();
        
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request1 = BuildValidRequest();
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request2 = BuildValidRequest();
        request2.StageTimestamp = 'asfbjakf';
        DMSInboundUpdateResponse response1 = new DMSInboundUpdateResponse(request1.SFOpportunityID, request1.DMSOpportunityID);
        DMSInboundUpdateResponse response2 = new DMSInboundUpdateResponse(request2.SFOpportunityID, request2.DMSOpportunityID);
        response2.ResponseMessage = 'pre-execution message';
        
        rule.Validate(request1, response1);
        rule.Validate(request2, response2);
        
        System.assertNotEquals('pre-execution message', response2.ResponseMessage);
    }

    static testMethod void Validate_UpdatesRequest1Stage_GivenDuplicateRequest() {
        DMSInboundDuplicateRequestRule rule = CreateRule();
        string newStage = 'newStage';

        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request1 = BuildValidRequest();
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request2 = BuildValidRequest();

        request2.StageTimestamp = '20-10-2016 235959';
        request2.Stage = newStage;
        DMSInboundUpdateResponse response1 = new DMSInboundUpdateResponse(request1.SFOpportunityID, request1.DMSOpportunityID);
        DMSInboundUpdateResponse response2 = new DMSInboundUpdateResponse(request2.SFOpportunityID, request2.DMSOpportunityID);
        
        rule.Validate(request1, response1);
        rule.Validate(request2, response2);
        
        System.assertEquals(newStage, request1.Stage);
    }

    static testMethod void Validate_UpdatesRequest1StageTimestamp_GivenDuplicateRequest() {
        DMSInboundDuplicateRequestRule rule = CreateRule();
        string newStageTimestamp = '29-10-2099 235959';

        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request1 = BuildValidRequest();
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request2 = BuildValidRequest();
        request2.StageTimestamp = newStageTimestamp;
        DMSInboundUpdateResponse response1 = new DMSInboundUpdateResponse(request1.SFOpportunityID, request1.DMSOpportunityID);
        DMSInboundUpdateResponse response2 = new DMSInboundUpdateResponse(request2.SFOpportunityID, request2.DMSOpportunityID);
        
        rule.Validate(request1, response1);
        rule.Validate(request2, response2);
        
        System.assertEquals(newStageTimestamp, request1.StageTimestamp);
    }

    static testMethod void Validate_UpdatesRequest1Amount_GivenDuplicateRequest() {
        DMSInboundDuplicateRequestRule rule = CreateRule();
        Decimal newAmount = 10;

        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request1 = BuildValidRequest();
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request2 = BuildValidRequest();

        request2.StageTimestamp = '20-10-2016 235959';
        request2.Amount = newAmount;
        DMSInboundUpdateResponse response1 = new DMSInboundUpdateResponse(request1.SFOpportunityID, request1.DMSOpportunityID);
        DMSInboundUpdateResponse response2 = new DMSInboundUpdateResponse(request2.SFOpportunityID, request2.DMSOpportunityID);
        
        rule.Validate(request1, response1);
        rule.Validate(request2, response2);
        
        System.assertEquals(newAmount, request1.Amount);
    }

    static testMethod void Validate_UpdatesRequest1CloseDate_GivenDuplicateRequest() {
        DMSInboundDuplicateRequestRule rule = CreateRule();
        string newCloseDate = 'newCloseDate';

        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request1 = BuildValidRequest();
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request2 = BuildValidRequest();

        request2.StageTimestamp = '20-10-2016 235959';
        request2.CloseDate = newCloseDate;
        DMSInboundUpdateResponse response1 = new DMSInboundUpdateResponse(request1.SFOpportunityID, request1.DMSOpportunityID);
        DMSInboundUpdateResponse response2 = new DMSInboundUpdateResponse(request2.SFOpportunityID, request2.DMSOpportunityID);
        
        rule.Validate(request1, response1);
        rule.Validate(request2, response2);
        
        System.assertEquals(newCloseDate, request1.CloseDate);
    }

    static testMethod void Validate_UpdatesRequest1NextFollowUpDate_GivenDuplicateRequest() {
        DMSInboundDuplicateRequestRule rule = CreateRule();
        string newNextFollowUpDate = 'newNextFollowUpDate';

        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request1 = BuildValidRequest();
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request2 = BuildValidRequest();

        request2.StageTimestamp = '20-10-2016 235959';

        request2.DMSActivities = new List<DMSInboundIntegrationService.DMSActivity>();
        DMSInboundIntegrationService.DMSActivity activity = new DMSInboundIntegrationService.DMSActivity();
        activity.NextFollowUpDate = newNextFollowUpDate;
        request2.DMSActivities.add(activity);

        DMSInboundUpdateResponse response1 = new DMSInboundUpdateResponse(request1.SFOpportunityID, request1.DMSOpportunityID);
        DMSInboundUpdateResponse response2 = new DMSInboundUpdateResponse(request2.SFOpportunityID, request2.DMSOpportunityID);
        
        rule.Validate(request1, response1);
        rule.Validate(request2, response2);
        
        System.assertEquals(newNextFollowUpDate, request1.DMSActivities[0].NextFollowUpDate);
    }

    static testMethod void Validate_UpdatesRequest1NextPlannedActivity_GivenDuplicateRequest() {
        DMSInboundDuplicateRequestRule rule = CreateRule();
        string newNextPlannedActivity = 'newNextPlannedActivity';

        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request1 = BuildValidRequest();
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request2 = BuildValidRequest();

        request2.StageTimestamp = '20-10-2016 235959';

        request2.DMSActivities = new List<DMSInboundIntegrationService.DMSActivity>();
        DMSInboundIntegrationService.DMSActivity activity = new DMSInboundIntegrationService.DMSActivity();
        activity.NextPlannedActivity = newNextPlannedActivity;
        request2.DMSActivities.add(activity);

        DMSInboundUpdateResponse response1 = new DMSInboundUpdateResponse(request1.SFOpportunityID, request1.DMSOpportunityID);
        DMSInboundUpdateResponse response2 = new DMSInboundUpdateResponse(request2.SFOpportunityID, request2.DMSOpportunityID);
        
        rule.Validate(request1, response1);
        rule.Validate(request2, response2);
        
        System.assertEquals(newNextPlannedActivity, request1.DMSActivities[0].NextPlannedActivity);
    }

    static testMethod void Validate_UpdatesRequest1Make_GivenDuplicateRequest() {
        DMSInboundDuplicateRequestRule rule = CreateRule();
        string newMake = 'newMake';

        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request1 = BuildValidRequest();
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request2 = BuildValidRequest();

        request2.StageTimestamp = '20-10-2016 235959';
        request2.Make = newMake;
        DMSInboundUpdateResponse response1 = new DMSInboundUpdateResponse(request1.SFOpportunityID, request1.DMSOpportunityID);
        DMSInboundUpdateResponse response2 = new DMSInboundUpdateResponse(request2.SFOpportunityID, request2.DMSOpportunityID);
        
        rule.Validate(request1, response1);
        rule.Validate(request2, response2);
        
        System.assertEquals(newMake, request1.Make);
    }

    static testMethod void Validate_UpdatesRequest1Model_GivenDuplicateRequest() {
        DMSInboundDuplicateRequestRule rule = CreateRule();
        string newModel = 'newModel';

        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request1 = BuildValidRequest();
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request2 = BuildValidRequest();

        request2.StageTimestamp = '20-10-2016 235959';
        request2.Model = newModel;
        DMSInboundUpdateResponse response1 = new DMSInboundUpdateResponse(request1.SFOpportunityID, request1.DMSOpportunityID);
        DMSInboundUpdateResponse response2 = new DMSInboundUpdateResponse(request2.SFOpportunityID, request2.DMSOpportunityID);
        
        rule.Validate(request1, response1);
        rule.Validate(request2, response2);
        
        System.assertEquals(newModel, request1.Model);
    }

    static testMethod void Validate_UpdatesRequest1Derivative_GivenDuplicateRequest() {
        DMSInboundDuplicateRequestRule rule = CreateRule();
        string newDerivative = 'newDerivative';

        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request1 = BuildValidRequest();
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request2 = BuildValidRequest();

        request2.StageTimestamp = '20-10-2016 235959';
        request2.Derivative = newDerivative;
        DMSInboundUpdateResponse response1 = new DMSInboundUpdateResponse(request1.SFOpportunityID, request1.DMSOpportunityID);
        DMSInboundUpdateResponse response2 = new DMSInboundUpdateResponse(request2.SFOpportunityID, request2.DMSOpportunityID);
        
        rule.Validate(request1, response1);
        rule.Validate(request2, response2);
        
        System.assertEquals(newDerivative, request1.Derivative);
    }


    private static DMSInboundDuplicateRequestRule CreateRule()
    {
        I_DateAdapter dateAdapter = new Date_India();
        I_TimeAdapter timeAdapter = new TimeAdapter_HHMMSS();
        DateTimeAdapter dateTimeAdapter = new DateTimeAdapter(dateAdapter, timeAdapter);
        return new DMSInboundDuplicateRequestRule(new Map<Id, DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity>(), dateTimeAdapter);
    }

    private static DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity BuildValidRequest()
    {
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = new DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity();
        request.StageTimestamp = '20-10-2015 235959';
        request.SFOpportunityID = Id.valueOf('0A28E000000Ccn0');
        return request;
    }
}