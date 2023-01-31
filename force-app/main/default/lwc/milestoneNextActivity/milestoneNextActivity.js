/**
 * Created by caleb on 30/01/2020.
 */

import {LightningElement, api, track} from 'lwc';

export default class MilestoneNextActivity extends LightningElement
{
    @api milestones;
    @track activityTypes = [{label: 'Task', value: 'Task'}, {label: 'Event', value: 'Event'}];

    @api currentActivity;
    @api currentMilestone;

    @track taskDueDate;
    @track eventStartDate;
    @track eventEndDate;

    @track commentText = "";

    @track doSetReminder = false;
    @track reminderDate;

    @api
    getActivity(opportunityId)
    {
        let activityRequest = {};
        activityRequest.ActivityType = this.currentActivity;
        activityRequest.OpportunityId = opportunityId;
        activityRequest.TaskType = null;
        activityRequest.EventType = null;
        activityRequest.Subject = this.currentMilestone;
        activityRequest.DueDateTime = this.taskDueDate;
        activityRequest.StartDateTime = this.eventStartDate;
        activityRequest.EndDateTime = this.eventEndDate;
        activityRequest.DoSetReminder = this.doSetReminder;
        activityRequest.ReminderDateTime = this.reminderDate;
        activityRequest.Comments = this.commentText;
        activityRequest.RelatedMilestone = this.currentMilestone;
        return activityRequest;
    }

    connectedCallback()
    {
        console.log(">> milestoneNextActivity.connectedCallback()");
        if (this.currentActivity === undefined)
        {
            this.currentActivity = "Task";
        }
        for (let i = 0; i < this.milestones.length; i++)
        {
            if (this.milestones[i].IsDefaultSelection) this.currentMilestone = this.milestones[i].Id;
        }
        console.log("<< milestoneNextActivity.connectedCallback()");
    }

    get isTask()
    {
        return this.currentActivity === "Task";
    }

    //////////////////
    /// validation ///
    //////////////////

    @api
    isValid()
    {
        let startDatePicker = this.template.querySelector('.input-event-start');
        let endDatePicker = this.template.querySelector('.input-event-end');
        let dueDatePicker = this.template.querySelector('.input-due-date');
        let currentMilestonePicker = this.template.querySelector('.input-milestone-dropdown');
        let reminderDatePicker = this.template.querySelector('.input-reminder-date');

        let isValid = true;

        currentMilestonePicker.errors = [];
        if (this.currentMilestone === undefined)
        {
            currentMilestonePicker.errors = [{ id: "1", message: "Please Select a Related Stage" }];
            isValid = false;
        }
        if (this.currentActivity === "Task")
        {
            dueDatePicker.errors = [];
            if (this.taskDueDate === undefined)
            {
                dueDatePicker.errors = [{ id: "1", message: "Please Select a Task Due Date" }];
                isValid = false;
            }
        }
        if (this.currentActivity === "Event")
        {
            startDatePicker.errors = [];
            endDatePicker.errors = [];
            if (this.eventStartDate === undefined)
            {
                startDatePicker.errors = [{ id: "1", message: "Please Select an Event Start Datetime" }];
                isValid = false;
            }
            if (this.eventEndDate === undefined)
            {
                endDatePicker.errors = [{ id: "1", message: "Pleases Select an Event End Datetime" }];
                isValid = false;
            }
            if (this.eventStartDate !== undefined && this.eventEndDate !== undefined && new Date(this.eventStartDate) > new Date(this.eventEndDate))
            {
                endDatePicker.errors = [{ id: "1", message: "End Datetime must be After Start Date Time" }];
                isValid = false;
            }
        }

        if (this.doSetReminder)
        {
            reminderDatePicker.errors = [];
            if (this.reminderDate === undefined)
            {
                reminderDatePicker.errors = [{ id: "1", message: "Please Select a Reminder Date"}];
                isValid = false;
            }
        }
        return isValid;
    }

    /////////////////////
    /// change handel ///
    /////////////////////

    // checkboxes
    handelEventTaskChange(evt)
    {
        this.currentActivity = evt.detail;
        console.log("currentActivity = " + this.currentActivity);
    }

    // milestone
    handelMilestoneChange(evt)
    {
        this.currentMilestone = evt.detail;
        console.log("currentMilestone = " + this.currentMilestone);
    }

    // date
    handelTaskDueDateChange(evt)
    {
        this.taskDueDate = evt.detail;
        console.log("taskDueDate = " + this.taskDueDate);
    }

    handelEventStartDateChange(evt)
    {
        this.eventStartDate = evt.detail;
        console.log("eventStartDate = " + this.eventStartDate);

        let endDateTime = new Date(this.eventStartDate);
        endDateTime.setHours(endDateTime.getHours() + 1);
        let datePicker = this.template.querySelector('.input-event-end');
        datePicker.setDatetime(endDateTime.toISOString());
        this.eventEndDate = endDateTime.toISOString();
    }

    handelEventEndDateChange(evt)
    {
        this.eventEndDate = evt.detail;
        console.log("eventEndDate = " + this.eventEndDate);
    }

    handelCommentChange(evt)
    {
        this.commentText = evt.detail;
        console.log("commentText = " + this.commentText);
    }

    handelReminderCheckBoxChange(evt)
    {
        this.doSetReminder = evt.detail;
        console.log("doSetReminder = " + this.doSetReminder);
        if (!this.doSetReminder)
        {
            this.reminderDate = undefined;
        }
    }

    handelReminderDateChange(evt)
    {
        this.reminderDate = evt.detail;
        console.log("reminderDate = " + this.reminderDate);
    }
}