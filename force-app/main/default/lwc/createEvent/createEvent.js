/**
 * Created by GrantMillgate-EasyTe on 15/11/2019.
 */

import {LightningElement, api, track} from 'lwc';
import GetEventTypes from '@salesforce/apex/ActivitiesController.getEventTypes';
import CreateMilestoneEvent from '@salesforce/apex/ActivitiesController.createActivity';
import {toastErrorOnFail} from 'c/common';

export default class CreateEvent extends LightningElement {
    @api milestoneDisplayName;
    @api milestoneApiName;
    @api relatedMilestone;
    @api opportunityId;
    @track milestoneSubject;
    @track eventTypes;
    @track startDate;
    @track endDate;
    @track selectedEventType;

    renderedCallback() {
        this.milestoneSubject = this.milestoneDisplayName;
    }

    connectedCallback() {
        this.getEventTypes();
    }

    getEventTypes() {
        console.log('>> getEventTypes');
        let request = {};
        toastErrorOnFail(GetEventTypes({
            request : request
        }))
            .then(result => {
                console.log('Result: ' + JSON.stringify(result));
                this.eventTypes = result.Data;
                console.log('Types: ' + this.eventTypes);
            })
            .catch(error => {
                console.log('Errors: ' + JSON.stringify(error));
            });
    }

    handleSaveClick(){
        console.log('>> handleSaveClick()');
        let request = {};

        request.OpportunityId = this.opportunityId;

        //Activity Type
        request.ActivityType = 'EVENT';
        console.log('ActivityType: ' + request.ActivityType);

        //Task Type
        request.EventType = this.selectedEventType;
        console.log('EventType: ' + request.EventType);

        //Start Date
        request.StartDateTime = this.startDate;

        //End Date
        request.EndDateTime = this.endDate;

        //Reminder
        if (this.isReminderChecked == undefined){
            this.isReminderChecked = false;
        }
        request.DoSetReminder = this.isReminderChecked;

        //Reminder Time/Date
        request.ReminderDateTime = this.reminderDateTime;

        //Subject
        request.Subject = this.milestoneSubject;

        //Related Milestone
        request.RelatedMilestone = this.relatedMilestone;

        //Comments
        request.Comments = this.comments;

        console.log(JSON.stringify(request));

        //Call  ActivitiesController
        toastErrorOnFail(CreateMilestoneEvent({
            request : request
        }))

            .then(result => {
                console.log('Result: ' + JSON.stringify(result));
                this.sendNotification();

            })
            .catch(error => {
                console.log('Errors: ' + JSON.stringify(error));
                this.error = error;


            });

        this.doClose();
    }

    handleCancelClick(){
        this.doClose();
    }

    doClose() {
        const selectedEvent = new CustomEvent('milestonecancelled', {});
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }

    handleReminderCheckboxChange(evt){
        let doSetReminder = evt.target.checked;
        console.log('Do Set Reminder: ' + doSetReminder);
        this.isReminderChecked = doSetReminder;
    }

    handleCommentsChange(evt){
        let comments = evt.target.value;
        console.log('Comments: ' + comments);
        this.comments = comments;

    }

    handleSubjectChange(evt){
        let subject = evt.target.value;
        console.log('Subject: ' + subject);
        this.milestoneSubject = subject;
    }

    handleStartDateChange(evt){
        let startDate = evt.target.value;
        console.log('Start Date: ' + startDate);
        this.startDate = startDate;
    }

    handleEndDateChange(evt){
        let endDate = evt.target.value;
        console.log('End Date: ' + endDate);
        this.endDate = endDate;
    }

    handleReminderDateChange(evt){
        let reminderDate = evt.target.value;
        console.log('Reminder: ' + reminderDate);
        this.reminderDateTime = reminderDate;
    }

    handleEventTypeChange(evt){
        console.log('>> handleEventTypeChange(evt: ' + JSON.stringify(evt) + ')');
        this.selectedEventType = undefined;
        const taskType = evt.target.value;
        this.selectedEventType = taskType;
        console.log('EventType Selected', taskType);
    }

    sendNotification(){
        const selectedEvent = new CustomEvent('activitycreated', {

        });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }
}