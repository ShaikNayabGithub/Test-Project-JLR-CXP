/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 17/11/2019.
 */

public without sharing class ActivitiesController {

    private static final String ACTIVITY_TYPES_TASK = 'TASK';
    private static final String ACTIVITY_TYPES_EVENT = 'EVENT';
    private static final String RECORD_TYPE_ID_MILESTONE_TASK = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Milestone_Task').getRecordTypeId();
    private static final String RECORD_TYPE_ID_MILESTONE_EVENT = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('Milestone_Event').getRecordTypeId();

    public static final String TASK_STATUS_COMPLETED = 'Completed';

    public static final List<String> MILESTONE_ORDER = new List<String> { 'Qualified', 'Test Drive', 'Vehicle Selection', 'Appraisal', 'Negotiation', 'Order Taken', 'Handover & RDA', 'Won', 'Lost' };

    public static final Map<String, String> MILESTONE_TO_OPPORTUNITY_STAGE_DEV_NAME = new Map<String, String>
    {
            'Qualified' => 'Qualified',
            'Test_Drive' => 'Test Drive',
            'Select Vehicle' => 'Vehicle Selection',
            'Appraisal' => 'Appraisal',
            'Negotiation' => 'Negotiation',
            'Order_Taken' => 'Order Taken',
            'Handover_RDA' => 'Handover & RDA'
    };

    @AuraEnabled
    public static GetActivitiesResponseDto getActivities(GetActivitiesRequestDto request){

        GetActivitiesResponseDto response = new GetActivitiesResponseDto();

        List<Task> tasks = [
                SELECT Id, Subject, Description, CreatedDate, Type, CallType, WhatId, Related_Milestone__c
                FROM Task
                WHERE (WhatId != NULL AND WhatId = :request.OpportunityId) OR Id = :request.ActivityId
        ];
        response.addTasks(tasks);

        List<Event> events = [
                SELECT Id, Subject, StartDateTime, EndDateTime, Description, CreatedDate, Type, EventSubtype, WhatId, Related_Milestone__c
                FROM Event
                WHERE (WhatId != NULL AND WhatId = :request.OpportunityId) OR Id = :request.ActivityId
        ];
        response.addEvents(events);

        return response;
    }

    @AuraEnabled
    public static ContactMailingDetailsResponseDto getOpportunityContactMailingDetails(string opportunityId)
    {
        Opportunity opp = [
                SELECT
                        Primary_Contact__r.Email,
                        Primary_Contact__r.MobilePhone,
                        Primary_Contact__r.MailingStreet,
                        Primary_Contact__r.MailingCity,
                        Primary_Contact__r.MailingState,
                        Primary_Contact__r.MailingPostalCode,
                        Primary_Contact__r.MailingCountry,
                        Country_ISO_Code__c,
                        Sale_Type__c,
                        IsWon,
                        CloseDate,
                        Delayed_Sent_to_Bookworks__c,
                        Do_Not_Send_Build_Delay_Letter__c,
                        (
                                SELECT
                                        OpportunityId
                                FROM OpportunityLineItems
                                WHERE PricebookEntry.Product2.RecordType.Name = 'Derivative'
                                AND Asset__r.Vista_Status__c NOT IN ('Order Cancelled','Customer Handover','Arrived at Dealer','Into Port of Entry or Receiving Compound','In Transit to Dealer','Shipped')
                        )
                FROM Opportunity
                WHERE Id = :opportunityId
        ];
        ContactMailingDetailsResponseDto res = new ContactMailingDetailsResponseDto();
        res.Email = opp.Primary_Contact__r.Email;
        res.MobilePhone = opp.Primary_Contact__r.MobilePhone;
        res.MailingStreet = opp.Primary_Contact__r.MailingStreet;
        res.MailingCity = opp.Primary_Contact__r.MailingCity;
        res.MailingState = opp.Primary_Contact__r.MailingState;
        res.MailingPostCode = opp.Primary_Contact__r.MailingPostalCode;
        res.MailingCountry = opp.Primary_Contact__r.MailingCountry;
        res.WillSendLetter = opp.OpportunityLineItems.size() > 0;
        return res;
    }

    @AuraEnabled
    public static void updateOpportunityContactDetails(string opportunityId, ContactMailingDetailsResponseDto address)
    {
        Opportunity opp = [
                SELECT
                        Do_not_send_build_delay_letter__c,
                        Primary_Contact__r.Id
                FROM Opportunity
                WHERE Id = :opportunityId
        ];
        if (opp.Primary_Contact__r == null)
        {
            throw new JlrCustomException('Primary Contact is not populated. Please contact CXP Support.');
        }
        opp.Primary_Contact__r.Email = address.Email;
        opp.Primary_Contact__r.MobilePhone = address.MobilePhone;
        opp.Primary_Contact__r.MailingStreet = address.MailingStreet;
        opp.Primary_Contact__r.MailingCity = address.MailingCity;
        opp.Primary_Contact__r.MailingState = address.MailingState;
        opp.Primary_Contact__r.MailingPostalCode = address.MailingPostCode;
        opp.Primary_Contact__r.MailingCountry = address.MailingCountry;
        update opp.Primary_Contact__r;
        opp.Do_not_send_build_delay_letter__c = address.LetterOptOut;
        update opp;
    }

    @AuraEnabled
    public static GetTaskTypesResponseDto getTaskTypes(GetTaskTypesRequestDto request){

        Schema.DescribeFieldResult fieldResult = Task.Type.getDescribe();

        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        GetTaskTypesResponseDto response = new GetTaskTypesResponseDto();
        List<String> entries = new List<String>();
        For( Schema.PicklistEntry entry : ple){
            if (entry.active == true) {
                entries.add(entry.getValue());
            }
        }
        response.Data = entries;
        return response;
    }

    @AuraEnabled
    public static GetEventTypesResponseDto getEventTypes(GetEventTypesRequestDto request){

        Schema.DescribeFieldResult fieldResult = Event.Type.getDescribe();

        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        GetEventTypesResponseDto response = new GetEventTypesResponseDto();
        List<String> entries = new List<String>();
        For( Schema.PicklistEntry entry : ple){
            if (entry.active == true) {
                entries.add(entry.getValue());
            }
        }
        response.Data = entries;
        return response;
    }


    @AuraEnabled
    public static CreateActivityResponseDto createActivity(CreateActivityRequestDto request) {

        if (request.ActivityType.equalsIgnoreCase(ACTIVITY_TYPES_TASK)) {
            Task newTask = createTask(request);
            CreateActivityResponseDto response = new CreateActivityResponseDto(newTask);
            return response;
        } else if (request.ActivityType.equalsIgnoreCase(ACTIVITY_TYPES_EVENT)) {
            Event newEvent = createEvent(request);
            CreateActivityResponseDto response = new CreateActivityResponseDto(newEvent);
            return response;
        }
        throw new InvalidParameterValueException(request.ActivityType, 'Unknown activity type');
    }

    private static Task createTask(CreateActivityRequestDto request) {
        Task newTask = new Task();
        newTask.RecordTypeId = RECORD_TYPE_ID_MILESTONE_TASK;
        if (string.isBlank(request.WhatId))
        {
            newTask.WhatId = request.OpportunityId;
        }
        else
        {
            newTask.WhatId = request.WhatId;
        }
        if (string.isBlank(request.WhoId))
        {
            newTask.WhoId = GetOpportunity(request.OpportunityId)?.Primary_Contact__c;
        }
        else
        {
            newTask.WhoId = request.WhoId;
        }
        newTask.Related_Milestone__c = request.RelatedMilestone;
        newTask.Type = request.TaskType;
        newTask.Description = request.Comments;
        newTask.Status = 'Pending';
        If (request.DoSetReminder) {
            If (String.isNotBlank(request.ReminderDateTime)) {
                newTask.ReminderDateTime = JlrDateParser.parseStringAsDatetime(request.ReminderDateTime);
            }
        }
        newTask.ActivityDate = JlrDateParser.parseStringAsDate(request.DueDateTime);
        if (MILESTONE_TO_OPPORTUNITY_STAGE_DEV_NAME.containsKey(request.Subject))
        {
            newTask.Subject = MILESTONE_TO_OPPORTUNITY_STAGE_DEV_NAME.get(request.Subject);
        }
        else
        {
            newTask.Subject = request.Subject;
        }
        insert newTask;
        return newTask;
    }

    private static Event createEvent(CreateActivityRequestDto request){
        Event newEvent = new Event();
        newEvent.RecordTypeId = RECORD_TYPE_ID_MILESTONE_EVENT;
        if (string.isBlank(request.WhatId))
        {
            newEvent.WhatId = request.OpportunityId;
        }
        else
        {
            newEvent.WhatId = request.WhatId;
        }
        if (string.isBlank(request.WhoId))
        {
            newEvent.WhoId = GetOpportunity(request.OpportunityId)?.Primary_Contact__c;
        }
        else
        {
            newEvent.WhoId = request.WhoId;
        }

        newEvent.Related_Milestone__c = request.RelatedMilestone;
        newEvent.Type = request.EventType;
        newEvent.Description = request.Comments;
        newEvent.StartDateTime = JlrDateParser.parseStringAsDatetime(request.StartDateTime);
        newEvent.EndDateTime = JlrDateParser.parseStringAsDatetime(request.EndDateTime);
        If (request.DoSetReminder) {
            If (String.isNotBlank(request.ReminderDateTime)) {
                newEvent.ReminderDateTime = JlrDateParser.parseStringAsDatetime(request.ReminderDateTime);
            }
        }
        if (MILESTONE_TO_OPPORTUNITY_STAGE_DEV_NAME.containsKey(request.Subject))
        {
            newEvent.Subject = MILESTONE_TO_OPPORTUNITY_STAGE_DEV_NAME.get(request.Subject);
        }
        else
        {
            newEvent.Subject = request.Subject;
        }
        insert newEvent;
        return newEvent;
    }

    private static Opportunity GetOpportunity(String OpportunityId)
    {
        List<Opportunity> opps = [SELECT Id, Primary_Contact__c, StageName FROM Opportunity WHERE Id = :OpportunityId];
        if (opps.size() > 0)
        {
            return opps[0];
        }
        return null;
    }

    @AuraEnabled
    public static UpdateActivityResponseDto updateActivity(UpdateActivityRequestDto request)
    {
        UpdateActivityResponseDto response = new UpdateActivityResponseDto();
        try
        {
            if (request.ActivityType != null && request.ActivityType.equalsIgnoreCase(ACTIVITY_TYPES_TASK))
            {
                response = updateTask(request);
                return response;
            }
            else if (request.ActivityType != null && request.ActivityType.equalsIgnoreCase(ACTIVITY_TYPES_EVENT))
            {
                response = updateEvent(request);
                return response;
            }
            throw new InvalidParameterValueException(request.ActivityType, 'Unknown activity type');
        }
        catch (Exception ex)
        {
            response.addError(ex);
            return response;
        }
    }

    private static UpdateActivityResponseDto updateTask(UpdateActivityRequestDto request)
    {
        List<Task> tasks = [SELECT Id, WhatId, Related_Milestone__c FROM Task WHERE Id = :request.ActivityId];
        if (tasks.size() == 0)
        {
            throw new JlrCustomException('No task Found');
        }
        Task task = tasks[0];
        if (request.IsCompleted)
        {
            task.Status = TASK_STATUS_COMPLETED;
            updateOpportunityStage(task);
        }
        update task;
        return new UpdateActivityResponseDto();
    }

    private static UpdateActivityResponseDto updateEvent(UpdateActivityRequestDto request)
    {
        List<Event> events = [SELECT Id, WhatId, Related_Milestone__c FROM Event WHERE Id = :request.ActivityId];
        if (events.size() == 0)
        {
            throw new JlrCustomException('No event Found');
        }
        Event event = events[0];
        if (request.IsCompleted)
        {
            event.Event_Completed__c = true;
            updateOpportunityStage(event);
        }
        update event;
        return new UpdateActivityResponseDto();
    }

    private static void updateOpportunityStage(Event event)
    {
        Opportunity opportunity = GetOpportunity(event.WhatId);
        if (opportunity == null) return;
        String oppStageName = opportunity.StageName;
        String milestoneStageName = MILESTONE_TO_OPPORTUNITY_STAGE_DEV_NAME.get(event.Related_Milestone__c);
        Integer oppStageNumber =  MILESTONE_ORDER.indexOf(oppStageName);
        Integer milestoneStageNumber = MILESTONE_ORDER.indexOf(milestoneStageName);
        if (oppStageNumber < milestoneStageNumber)
        {
            // update opportunity stage
            opportunity.Always_Allow_Stage_Change__c = true;
            opportunity.StageName = milestoneStageName;
            setMilestoneCompletionDate(opportunity, event.Related_Milestone__c);
        }
        update opportunity;
    }

    private static void setMilestoneCompletionDate(Opportunity opp, string relatedMilestone)
    {
        Opportunity_Stage_Map__mdt stage = [SELECT Completed_Stage_Date_Field__c FROM Opportunity_Stage_Map__mdt WHERE Activity_Related_Milestone_Name__c = :relatedMilestone];
        opp.put(stage.Completed_Stage_Date_Field__c, Date.today());
    }


    private static void updateOpportunityStage(Task task)
    {
        Opportunity opportunity = GetOpportunity(task.WhatId);
        if (opportunity == null) return;
        String oppStageName = opportunity.StageName;
        String milestoneStageName = MILESTONE_TO_OPPORTUNITY_STAGE_DEV_NAME.get(task.Related_Milestone__c);
        Integer oppStageNumber =  MILESTONE_ORDER.indexOf(oppStageName);
        Integer milestoneStageNumber = MILESTONE_ORDER.indexOf(milestoneStageName);
        if (oppStageNumber < milestoneStageNumber)
        {
            // update opportunity stage
            opportunity.Always_Allow_Stage_Change__c = true;
            opportunity.StageName = milestoneStageName;
            setMilestoneCompletionDate(opportunity, task.Related_Milestone__c);
        }
        update opportunity;
    }

    @AuraEnabled
    public static UpdateActivityResponseDto createAndCloseActivity(CreateActivityRequestDto request)
    {
        CreateActivityResponseDto createResponse = createActivity(request);
        UpdateActivityRequestDto updateReq = new UpdateActivityRequestDto();
        updateReq.ActivityId = createResponse.Data[0].Id;
        updateReq.IsCompleted = true;
        updateReq.ActivityType = request.ActivityType;
        UpdateActivityResponseDto updateRes = updateActivity(updateReq);
        return updateRes;
    }

    @AuraEnabled
    public static DeleteActivityResponseDto deleteActivity(DeleteActivityRequestDto request)
    {
        try
        {
            List<Task> tasks = [
                    SELECT Id
                    FROM Task
                    WHERE Id = :request.ActivityId OR (WhatId = :request.OpportunityId AND Related_Milestone__c = :request.RelatedMilestone)
            ];
            List<Event> events = [
                    SELECT Id
                    FROM Event
                    WHERE Id = :request.ActivityId OR (WhatId = :request.OpportunityId AND Related_Milestone__c = :request.RelatedMilestone)
            ];
            delete tasks;
            delete events;
            return new DeleteActivityResponseDto();
        }
        catch (Exception ex)
        {
            DeleteActivityResponseDto res = new DeleteActivityResponseDto();
            res.addError(ex);
            return res;
        }
    }

    @AuraEnabled
    public static ActivityInfoDto GetActivityInfo(string activityId)
    {
        List<Task> tasks = [
                SELECT Id, Subject, Description, CreatedDate, Type, CallType, WhatId, WhoId, Related_Milestone__c
                FROM Task
                WHERE Id = :activityId
        ];
        List<Event> events = [
                SELECT Id, Subject, StartDateTime, EndDateTime, Description, CreatedDate, WhoId, Type, EventSubtype, WhatId, Related_Milestone__c
                FROM Event
                WHERE Id = :activityId
        ];
        string whatId = (tasks.size() > 0)
                ? tasks[0].WhatId
                : ((events.size() > 0)
                        ? events[0].WhatId
                        : null);
        string whoId = (tasks.size() > 0)
                ? tasks[0].WhoId
                : ((events.size() > 0)
                        ? events[0].WhoId
                        : null);
        if (whatId == null)
        {
            ActivityInfoDto res = new ActivityInfoDto();
            res.WhatType = 'None';
            return res;
        }

        List<Account> accs = [
                SELECT Id
                FROM Account
                WHERE Id = :whatId
        ];

        if (accs.size() > 0)
        {
            ActivityInfoDto res = new ActivityInfoDto();
            res.WhatType = 'Account';
            res.WhoId = whoId;
            res.Id = accs[0].Id;
            return res;
        }

        List<Opportunity> opps = [
                SELECT Id, IsClosed, Primary_Contact__r.Email
                FROM Opportunity
                WHERE Id = :whatId
        ];

        if (opps.size() > 0)
        {
            ActivityInfoDto res = new ActivityInfoDto();
            res.WhatType = 'Opportunity';
            res.Id = opps[0].Id;
            res.WhoId = whoId;
            res.OpportunityIsClosed = opps[0].IsClosed;
            res.OpportunityContactEmail = opps[0].Primary_Contact__r.Email;
            return res;
        }

        ActivityInfoDto res = new ActivityInfoDto();
        res.WhatType = 'Other';
        return res;
    }
}