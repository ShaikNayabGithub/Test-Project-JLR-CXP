@isTest
public class DMSInbound_TaskBuilder_Test {
    static testmethod void Build_ReturnsTaskWithOwnerIdSetToOpportunityOwner_GivenRequestWithOpportunityOwner()
    {
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = new DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity();

        DMSInboundIntegrationService.DMSActivity activity = new DMSInboundIntegrationService.DMSActivity();
        activity.NextPlannedActivity = 'test';
        Opportunity opportunity = CreateOpportunity();

        request.DMSActivities = new List<DMSInboundIntegrationService.DMSActivity>{ activity };
        request.SFOpportunityID = opportunity.Id;

        DMSInboundUpdateResponse postValidationResponse = new DMSInboundUpdateResponse(opportunity.Id, 'test');
        List<Task> results = new List<Task>();

        DMSInbound_TaskBuilder taskBuilder = new DMSInbound_TaskBuilder(new DummyDateAdapter());

        taskBuilder.Build(request, postValidationResponse, results, new List<DMSInboundUpdateResponse>());

        System.assertEquals([Select OwnerId From Opportunity where Id=:opportunity.Id Limit 1].OwnerId, results[0].OwnerId);
    }

    static testmethod void Build_ReturnsTaskWithSubjectSetToRequestNextPlannedActivity_GivenRequestWithNextPlannedActivity()
    {
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = new DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity();

        string activityName = 'test';
        DMSInboundIntegrationService.DMSActivity activity = new DMSInboundIntegrationService.DMSActivity();
        Opportunity opportunity = CreateOpportunity();
        activity.NextPlannedActivity = activityName;

        request.DMSActivities = new List<DMSInboundIntegrationService.DMSActivity>{ activity };
        request.SFOpportunityID = opportunity.Id;

        DMSInboundUpdateResponse postValidationResponse = new DMSInboundUpdateResponse(opportunity.Id, 'test');
        List<Task> results = new List<Task>();
        
        DMSInbound_TaskBuilder taskBuilder = new DMSInbound_TaskBuilder(new DummyDateAdapter());

        taskBuilder.Build(request, postValidationResponse, results, new List<DMSInboundUpdateResponse>());

        System.assertEquals(activityName, results[0].Subject);
    }

    static testmethod void Build_ReturnsTaskWithWhatIdSetToRequestOpportunity_GivenRequestWithOpportunityId()
    {
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = new DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity();

        DMSInboundIntegrationService.DMSActivity activity = new DMSInboundIntegrationService.DMSActivity();
        activity.NextPlannedActivity = 'test';
        Opportunity opportunity = CreateOpportunity();

        request.DMSActivities = new List<DMSInboundIntegrationService.DMSActivity>{ activity };
        request.SFOpportunityID = opportunity.Id;

        DMSInboundUpdateResponse postValidationResponse = new DMSInboundUpdateResponse(opportunity.Id, 'test');
        List<Task> results = new List<Task>();
        
        DMSInbound_TaskBuilder taskBuilder = new DMSInbound_TaskBuilder(new DummyDateAdapter());

        taskBuilder.Build(request, postValidationResponse, results, new List<DMSInboundUpdateResponse>());

        System.assertEquals(opportunity.Id, results[0].WhatId);
    }

    static testmethod void Build_ReturnsTaskWithStatusSetToNotStarted_GivenRequest()
    {
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = new DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity();

        DMSInboundIntegrationService.DMSActivity activity = new DMSInboundIntegrationService.DMSActivity();
        activity.NextPlannedActivity = 'test';
        Opportunity opportunity = CreateOpportunity();

        request.DMSActivities = new List<DMSInboundIntegrationService.DMSActivity>{ activity };
        request.SFOpportunityID = opportunity.Id;

        DMSInboundUpdateResponse postValidationResponse = new DMSInboundUpdateResponse(opportunity.Id, 'test');
        List<Task> results = new List<Task>();
        
        DMSInbound_TaskBuilder taskBuilder = new DMSInbound_TaskBuilder(new DummyDateAdapter());

        taskBuilder.Build(request, postValidationResponse, results, new List<DMSInboundUpdateResponse>());

        System.assertEquals('Not Started', results[0].Status);
    }

    static testmethod void Build_ReturnsTaskWithPrioritySetToNormal_GivenRequest()
    {
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = new DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity();

        DMSInboundIntegrationService.DMSActivity activity = new DMSInboundIntegrationService.DMSActivity();
        activity.NextPlannedActivity = 'test';
        Opportunity opportunity = CreateOpportunity();

        request.DMSActivities = new List<DMSInboundIntegrationService.DMSActivity>{ activity };
        request.SFOpportunityID = opportunity.Id;

        DMSInboundUpdateResponse postValidationResponse = new DMSInboundUpdateResponse(opportunity.Id, 'test');
        List<Task> results = new List<Task>();
        
        DMSInbound_TaskBuilder taskBuilder = new DMSInbound_TaskBuilder(new DummyDateAdapter());

        taskBuilder.Build(request, postValidationResponse, results, new List<DMSInboundUpdateResponse>());

        System.assertEquals('Normal', results[0].Priority);
    }

    static testmethod void Build_ReturnsTaskWithActivityDateSetToRequestNextFollowUpDate_GivenRequestWithNextFollowUpDate()
    {
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = new DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity();

        Date inputDate = Date.today();
        DMSInboundIntegrationService.DMSActivity activity = new DMSInboundIntegrationService.DMSActivity();
        activity.NextPlannedActivity = 'test';
        Opportunity opportunity = CreateOpportunity();
        activity.NextFollowUpDate = String.valueOf(inputDate);

        request.DMSActivities = new List<DMSInboundIntegrationService.DMSActivity>{ activity };
        request.SFOpportunityID = opportunity.Id;

        DMSInboundUpdateResponse postValidationResponse = new DMSInboundUpdateResponse(opportunity.Id, 'test');
        List<Task> results = new List<Task>();
        
        DMSInbound_TaskBuilder taskBuilder = new DMSInbound_TaskBuilder(new DummyDateAdapter());

        taskBuilder.Build(request, postValidationResponse, results, new List<DMSInboundUpdateResponse>());

        System.assertEquals(inputDate, results[0].ActivityDate);
    }

    private static Opportunity CreateOpportunity()
    {   
        Profile ownerProfile = ProfileUtilities.Profiles.get('DMS Integration Profile');
        User owner;
        System.RunAs(new User(Id=UserInfo.getUserId())){
            owner = TestClass_UserCreator.CreateUser(ownerProfile);
        }

        Opportunity opportunity = TestClass_ValidOpportunityBuilder.Build();
        opportunity.OwnerId = owner.Id;
        insert opportunity;
        return opportunity;
    }

    private class DummyDateAdapter implements I_DateAdapter{
        public Date parse(string dateString)
        {
            return Date.valueOf(dateString);
        }
    }
}