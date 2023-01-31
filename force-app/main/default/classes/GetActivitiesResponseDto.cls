/**
 * Created by Grant Millgate | Argo Logic | grant@argologic.com.au on 18/11/2019.
 */

public with sharing class GetActivitiesResponseDto extends BaseResponseDto{

    public GetActivitiesResponseDto(){
        super();
        init();
    }

    private void init(){
        if (this.Tasks == null){
            this.Tasks =  new List<ActivityResourceDto>();
        }

        if (this.Events == null){
            this.Events = new List<ActivityResourceDto>();
        }

    }

    public void addTasks(List<Task> tasks){

        for(Task tsk : tasks){
            ActivityResourceDto resource = new ActivityResourceDto();
            resource.Id = tsk.Id;
            resource.Type = 'Task';
            resource.Attributes.Subject = tsk.Subject;
            resource.Attributes.ActivityType = tsk.Type;
            resource.Attributes.Description = tsk.Description;
            resource.Attributes.DateCreated = String.valueOf(tsk.CreatedDate.date());
            resource.Attributes.WhatId = tsk.WhatId;
            resource.NextMilestone = MilestoneController.getNextMilestones(tsk.Related_Milestone__c);
            this.Tasks.add(resource);
        }
    }

    public void addEvents(List<Event> events){
        for(Event evt : events){
            ActivityResourceDto resource = new ActivityResourceDto();
            resource.Id = evt.Id;
            resource.Type = 'Event';
            resource.Attributes.Subject = evt.Subject;
            resource.Attributes.Description = evt.Description;
            resource.Attributes.ActivityType = evt.Type;
            resource.Attributes.DateCreated = String.valueOf(evt.CreatedDate.date());
            resource.Attributes.WhatId = evt.WhatId;
            resource.NextMilestone = MilestoneController.getNextMilestones(evt.Related_Milestone__c);
            this.Events.add(resource);
        }
    }

    @AuraEnabled
    public List<ActivityResourceDto> Tasks {get; set;}

    @AuraEnabled
    public List<ActivityResourceDto> Events {get; set;}

}