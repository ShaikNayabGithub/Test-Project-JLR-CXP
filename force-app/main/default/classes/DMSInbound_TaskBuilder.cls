public class DMSInbound_TaskBuilder {
    private final I_DateAdapter dateAdapter;

    public DMSInbound_TaskBuilder(I_DateAdapter dateAdapter)
    {
        this.dateAdapter = dateAdapter;
    }


    public void Build(DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity inboundDMSRequest,
            DMSInboundUpdateResponse postValidationResponse,
            List<Task> out_tasksForInsertion, List<DMSInboundUpdateResponse> out_responsesWithTasks) {
        Map<String, DMSInboundIntegrationService.DMSActivity> newDmsTaskIds = GetNewDMSIds(inboundDMSRequest.DMSActivities);
        Id ownerId = [Select OwnerId from Opportunity where Id =: inboundDMSRequest.SFOpportunityID].OwnerId;
        
        for(String dmsId : newDmsTaskIds.keySet()) {
            DMSInboundIntegrationService.DMSActivity activity = newDmsTaskIds.get(dmsId);

            Task newTask = new Task(DMS_Id__c = dmsId,
                OwnerId = ownerId,
                WhatId = inboundDMSRequest.SFOpportunityID,
                Status = 'Not Started',
                Priority = 'Normal',
                Subject = activity.NextPlannedActivity);

            if(String.isNotEmpty(activity.NextFollowUpDate)){ newTask.ActivityDate = dateAdapter.parse(activity.NextFollowUpDate); }

            out_tasksForInsertion.add(newTask);
            out_responsesWithTasks.add(postValidationResponse);
        }
    }


    private Map<String, DMSInboundIntegrationService.DMSActivity> GetNewDMSIds(List<DMSInboundIntegrationService.DMSActivity> activities){
        Map<String, DMSInboundIntegrationService.DMSActivity> activitiesByDmsId = new Map<String, DMSInboundIntegrationService.DMSActivity>();
        
        for(DMSInboundIntegrationService.DMSActivity activity : activities) {
            if(String.isEmpty(activity.NextPlannedActivity)) { continue; }
            activitiesByDmsId.put(activity.DMSId, activity);
        }

        for(Task existingTask : [SELECT DMS_Id__c From Task WHERE DMS_Id__c IN: activitiesByDmsId.keySet()]) {
            activitiesByDmsId.remove(existingTask.DMS_Id__c);
        }

        return activitiesByDmsId;
    }
}