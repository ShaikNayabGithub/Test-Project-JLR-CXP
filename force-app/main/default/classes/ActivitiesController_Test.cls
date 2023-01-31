/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 2/12/2019.
 */

@IsTest
public with sharing class ActivitiesController_Test
{
    public static final String SELECT_VEHICLE_MILESTONE_NAME = 'Select Vehicle';

    @TestSetup
    public static void TestSetup()
    {
        // Create an Opportunity with qualify activity
        OpportunitiesController.create((CreateOpportunityRequestDto)JSON.deserialize('{"NameLast":"ActivtyTest","NameFirst":"Test","Email":"test@test.com","PhoneMobile":"0421123456","LeadSource":"Walk-in","RelatedMilestoneId":"Qualified","RelatedMilestoneName":"Qualification","ActivityType":"Task","DueDate":"2020-03-01","IsOpportunityQualified":false,"DoSetReminder":false,"PricebookId":"01s1o0000059Y9eAAE","ReminderDateTime":null}', CreateOpportunityRequestDto.class));
    }

    @IsTest
    public static void getActivitiesTest()
    {
        // ARRANGE
        String opportunityId = [SELECT Id FROM Opportunity LIMIT 1].Id;
        GetActivitiesRequestDto req = new GetActivitiesRequestDto();
        req.OpportunityId = opportunityId;

        // ACT
        Test.startTest();
        GetActivitiesResponseDto res = ActivitiesController.getActivities(req);
        Test.stopTest();

        // ASSERT
        System.assertEquals(1, res.Tasks.size());
        System.assertEquals(7, res.Tasks[0].NextMilestone.size());
    }

    @IsTest
    public static void getActivitiesTest2()
    {
        // ARRANGE
        String opportunityId = [SELECT Id FROM Opportunity LIMIT 1].Id;
        GetActivitiesRequestDto req = new GetActivitiesRequestDto();
        req.OpportunityId = opportunityId;
        // create event as well for code coverage purposes
        CreateActivityRequestDto eventReq = (CreateActivityRequestDto)JSON.deserialize('{"ActivityType":"Event","OpportunityId":"' + opportunityId + '","TaskType":null,"EventType":null,"Subject":"Select Vehicle","StartDateTime":"2020-03-5","EndDateTime":"2020-03-6","DoSetReminder":false,"Comments":"","RelatedMilestone":"' + SELECT_VEHICLE_MILESTONE_NAME + '"}', CreateActivityRequestDto.class);
        CreateActivityResponseDto eventRes = ActivitiesController.createActivity(eventReq);

        // ACT
        Test.startTest();
        GetActivitiesResponseDto res = ActivitiesController.getActivities(req);
        Test.stopTest();

        // ASSERT
        System.assertEquals(1, res.Tasks.size());
        System.assertEquals(7, res.Tasks[0].NextMilestone.size());
        System.assertEquals(7, res.Events[0].NextMilestone.size());
    }

    @IsTest
    public static void getOpportunityContactMailingDetailsTest()
    {
        // ARRANGE
        String opportunityId = [SELECT Id FROM Opportunity LIMIT 1].Id;

        // ACT
        Test.startTest();
        ContactMailingDetailsResponseDto res = ActivitiesController.getOpportunityContactMailingDetails(opportunityId);
        Test.stopTest();

        // ASSERT

    }

    @IsTest
    public static void getTaskTypesTest()
    {
        // ARRANGE
        GetTaskTypesRequestDto req = new GetTaskTypesRequestDto();

        // ACT
        Test.startTest();
        GetTaskTypesResponseDto res = ActivitiesController.getTaskTypes(req);
        Test.stopTest();

        // ASSERT
        System.assertNotEquals(null, res);
        System.assertNotEquals(null, res.Data);
    }

    @IsTest
    public static void getEventTypesTest()
    {
        // ARRANGE
        GetEventTypesRequestDto req = new GetEventTypesRequestDto();

        // ACT
        Test.startTest();
        GetEventTypesResponseDto res = ActivitiesController.getEventTypes(req);
        Test.stopTest();

        // ASSERT
        System.assertNotEquals(null, res);
        System.assertNotEquals(null, res.Data);
    }

    @IsTest
    public static void createActivityTask()
    {
        // ARRANGE
        String opportunityId = [SELECT Id FROM Opportunity LIMIT 1].Id;
        CreateActivityRequestDto req = (CreateActivityRequestDto)JSON.deserialize('{"ActivityType":"Task","OpportunityId":"' + opportunityId + '","TaskType":null,"EventType":null,"Subject":"Select Vehicle","DueDateTime":"2020-03-5","DoSetReminder":false,"Comments":"","RelatedMilestone":"' + SELECT_VEHICLE_MILESTONE_NAME + '"}', CreateActivityRequestDto.class);

        // ACT
        Test.startTest();
        CreateActivityResponseDto res = ActivitiesController.createActivity(req);
        Test.stopTest();

        // ASSERT
        System.assertEquals(true, res.IsSuccess);
        System.assertEquals(1, [SELECT Id FROM Task WHERE Related_Milestone__c = :SELECT_VEHICLE_MILESTONE_NAME].size());
    }

    @IsTest
    public static void createActivityEvent()
    {
        // ARRANGE
        String opportunityId = [SELECT Id FROM Opportunity LIMIT 1].Id;
        CreateActivityRequestDto req = (CreateActivityRequestDto)JSON.deserialize('{"ActivityType":"Event","OpportunityId":"' + opportunityId + '","TaskType":null,"EventType":null,"Subject":"Select Vehicle","StartDateTime":"2020-03-5","EndDateTime":"2020-03-6","DoSetReminder":false,"Comments":"","RelatedMilestone":"' + SELECT_VEHICLE_MILESTONE_NAME + '"}', CreateActivityRequestDto.class);

        // ACT
        Test.startTest();
        CreateActivityResponseDto res = ActivitiesController.createActivity(req);
        Test.stopTest();

        // ASSERT
        System.assertEquals(true, res.IsSuccess);
        System.assertEquals(1, [SELECT Id FROM Event WHERE Related_Milestone__c = :SELECT_VEHICLE_MILESTONE_NAME].size());
    }

    @IsTest
    public static void deleteActivityEventTest()
    {
        // ARRANGE
        String opportunityId = [SELECT Id FROM Opportunity LIMIT 1].Id;
        ActivitiesController.createActivity((CreateActivityRequestDto)JSON.deserialize('{"ActivityType":"Event","OpportunityId":"' + opportunityId + '","TaskType":null,"EventType":null,"Subject":"Select Vehicle","StartDateTime":"2020-03-5","EndDateTime":"2020-03-6","DoSetReminder":false,"Comments":"","RelatedMilestone":"' + SELECT_VEHICLE_MILESTONE_NAME + '"}', CreateActivityRequestDto.class));
        String activityId = [SELECT Id FROM Event LIMIT 1].Id;
        UpdateActivityRequestDto createReq = (UpdateActivityRequestDto)JSON.deserialize('{"ActivityId":"' + activityId + '","ActivityType":"Event","IsCompleted":true}', UpdateActivityRequestDto.class);
        ActivitiesController.updateActivity(createReq);

        DeleteActivityRequestDto req = new DeleteActivityRequestDto();
        req.ActivityId = activityId;

        // ACT
        Test.startTest();
        DeleteActivityResponseDto res = ActivitiesController.deleteActivity(req);
        Test.stopTest();

        // ASSERT
        System.assertEquals(true, res.IsSuccess);
        System.assertEquals(0, [SELECT Id FROM Event].size());
    }

    @IsTest
    public static void updateActivityTaskTest()
    {
        // ARRANGE
        String activityId = [SELECT Id FROM Task LIMIT 1].Id;
        UpdateActivityRequestDto req = (UpdateActivityRequestDto)JSON.deserialize('{"ActivityId":"' + activityId + '","ActivityType":"Task","IsCompleted":true}', UpdateActivityRequestDto.class);

        // ACT
        Test.startTest();
        UpdateActivityResponseDto res = ActivitiesController.updateActivity(req);
        Test.stopTest();

        // ASSERT
        System.assertEquals(true, res.IsSuccess);
        System.assertEquals(ActivitiesController.TASK_STATUS_COMPLETED, [SELECT Id, Status FROM Task LIMIT 1].Status);
    }

    @IsTest
    public static void updateOpportunityContactDetailsTest()
    {
        // ARRANGE
        String opportunityId = [SELECT Id FROM Opportunity LIMIT 1].Id;
        ContactMailingDetailsResponseDto req = new ContactMailingDetailsResponseDto();
        req.MobilePhone = '0421090000';
        req.Email = 't@t.com';
        req.LetterOptOut = false;

        // ACT
        Test.startTest();
        ActivitiesController.updateOpportunityContactDetails(opportunityId, req);
        Test.stopTest();

        // ASSERT

    }

    @IsTest
    public static void updateActivityEventTest()
    {
        // ARRANGE
        String opportunityId = [SELECT Id FROM Opportunity LIMIT 1].Id;
        ActivitiesController.createActivity((CreateActivityRequestDto)JSON.deserialize('{"ActivityType":"Event","OpportunityId":"' + opportunityId + '","TaskType":null,"EventType":null,"Subject":"Select Vehicle","StartDateTime":"2020-03-5","EndDateTime":"2020-03-6","DoSetReminder":false,"Comments":"","RelatedMilestone":"' + SELECT_VEHICLE_MILESTONE_NAME + '"}', CreateActivityRequestDto.class));
        String activityId = [SELECT Id FROM Event LIMIT 1].Id;
        UpdateActivityRequestDto req = (UpdateActivityRequestDto)JSON.deserialize('{"ActivityId":"' + activityId + '","ActivityType":"Event","IsCompleted":true}', UpdateActivityRequestDto.class);

        // ACT
        Test.startTest();
        UpdateActivityResponseDto res = ActivitiesController.updateActivity(req);
        Test.stopTest();

        // ASSERT
        System.assertEquals(true, res.IsSuccess);
        System.assertEquals(true, [SELECT Id, Event_Completed__c FROM Event LIMIT 1].Event_Completed__c);
    }

    @IsTest
    public static void getActivitiesInfoDto()
    {
        // ARRANGE
        String opportunityId = [SELECT Id FROM Opportunity LIMIT 1].Id;
        GetActivitiesRequestDto req = new GetActivitiesRequestDto();
        req.OpportunityId = opportunityId;
        // create event as well for code coverage purposes
        CreateActivityRequestDto eventReq = (CreateActivityRequestDto)JSON.deserialize('{"ActivityType":"Event","OpportunityId":"' + opportunityId + '","TaskType":null,"EventType":null,"Subject":"Select Vehicle","StartDateTime":"2020-03-5","EndDateTime":"2020-03-6","DoSetReminder":false,"Comments":"","RelatedMilestone":"' + SELECT_VEHICLE_MILESTONE_NAME + '"}', CreateActivityRequestDto.class);
        CreateActivityResponseDto eventRes = ActivitiesController.createActivity(eventReq);
        string activityId = [SELECT Id FROM Event].Id;

        // ACT
        Test.startTest();
        ActivityInfoDto res = ActivitiesController.GetActivityInfo(activityId);
        res.Id = '';
        res.WhoId = '';
        res.OpportunityIsClosed = true;
        res.WhatType = '';
        Test.stopTest();

        // ASSERT

    }
}