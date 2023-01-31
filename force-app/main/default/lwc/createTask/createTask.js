/**
 * Created by GrantMillgate-EasyTe on 15/11/2019.
 */

import {LightningElement, track, api} from 'lwc';
import GetTaskTypes from '@salesforce/apex/ActivitiesController.getTaskTypes';
import CreateMilestoneTask from '@salesforce/apex/ActivitiesController.createActivity';
import {toastErrorOnFail} from 'c/common';

export default class CreateTask extends LightningElement {

    @api milestoneDisplayName;
    @api milestoneApiName;
    @api relatedMilestone;
    @api opportunityId;
    @track comments;
    @track isReminderChecked;
    @track reminderDateTime;
    @track dueDate;
    @track milestoneSubject;
    @track taskTypes;
    @track selectedTaskType;
    @track error;

    connectedCallback() {
        this.getTaskTypes();
    }

    renderedCallback() {
        this.milestoneSubject = this.milestoneDisplayName;
    }

    handleTaskTypeChange(evt) {
        console.log('>> handleTaskTypeChange(evt: ' + JSON.stringify(evt) + ')');
        this.selectedTaskType = undefined;
        const taskType = evt.target.value;
        this.selectedTaskType = taskType;
        console.log('TaskType Selected', taskType);
    }

    handleSaveClick() {
        console.log('>> handleSaveClick()');
        let request = {};

        request.OpportunityId = this.opportunityId;

        //Activity Type
        request.ActivityType = 'TASK';
        console.log('ActivityType: ' + request.ActivityType);

        //Task Type
        request.TaskType = this.selectedTaskType;
        console.log('TaskType: ' + request.TaskType);

        //Due Date
        request.DueDateTime = this.dueDate;

        //Reminder
        if (this.isReminderChecked == undefined) {
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
        toastErrorOnFail(CreateMilestoneTask({
            request: request
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

    getTaskTypes() {
        console.log('>> getTaskTypes');
        let request = {};
        toastErrorOnFail(GetTaskTypes({
            request: request
        }))
            .then(result => {
                console.log('Result: ' + JSON.stringify(result));
                this.taskTypes = result.Data;
                console.log('Types: ' + this.taskTypes);
            })
            .catch(error => {
                console.log('Errors: ' + JSON.stringify(error));
            });
    }

    handleCancelClick() {
        this.doClose();
    }

    doClose() {
        const selectedEvent = new CustomEvent('milestonecancelled', {});
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }

    handleReminderCheckboxChange(evt) {
        let doSetReminder = evt.target.checked;
        console.log('Do Set Reminder: ' + doSetReminder);
        this.isReminderChecked = doSetReminder;
    }

    handleCommentsChange(evt) {
        let comments = evt.target.value;
        console.log('Comments: ' + comments);
        this.comments = comments;

    }

    handleSubjectChange(evt) {
        let subject = evt.target.value;
        console.log('Subject: ' + subject);
        this.milestoneSubject = subject;
    }

    handleDueDateChange(evt) {
        let dueDate = evt.target.value;
        console.log('Due Date: ' + dueDate);
        this.dueDate = dueDate;
    }

    handleReminderDateChange(evt) {
        let reminderDate = evt.target.value;
        console.log('Reminder: ' + reminderDate);
        this.reminderDateTime = reminderDate;
    }

    sendNotification(){
        const selectedEvent = new CustomEvent('activitycreated', {

        });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }
}