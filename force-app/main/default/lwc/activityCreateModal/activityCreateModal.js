/**
 * Created by caleb on 8/07/2020.
 */

import {LightningElement, api, track} from 'lwc';
import getMilestones from  '@salesforce/apex/MilestoneController.getNextMilestones';
import CreateActivity from '@salesforce/apex/ActivitiesController.createActivity';
import {showMessageIfSuccess} from 'c/utilToastMessages';

export default class ActivityCreateModal extends LightningElement
{
    @api
    opportunityId;
    @api
    doShowModal = false;
    @track
    nextMilestones;

    @track isLoading = false;

    async connectedCallback()
    {
        let miles = await getMilestones({developerName:"Qualified"});
        this.initMilestones(miles);
    }

    initMilestones(miles)
    {
        console.log('>> initMilestones(' + JSON.stringify(miles) + ')');
        let milestones = [];
        for (let i = 0; i < miles.length; i++)
        {
            console.log('MilestoneDevName = ' + miles[i].ActivityMilestoneDeveloperName);
            milestones.push(this.buildMilestone(miles[i].Label, miles[i].ActivityMilestoneDeveloperName, miles[i].IsDefault));
        }
        this.nextMilestones = milestones;
        console.log('<< initMilestones()');
    }

    buildMilestone(name, id, isDefault)
    {
        let milestone = {};
        milestone.Name = name;
        milestone.Id = id;
        milestone.IsDefaultSelection = isDefault;
        return milestone;
    }

    async handelCreateNewActivity(evt)
    {
        console.log('>> handelCreateNewActivity()');
        this.isLoading = true;
        let nextActivity = this.template.querySelector('.next-activity');
        if (nextActivity && nextActivity.isValid())
        {
            console.log('entered if statement');
            let createRequest = {request: nextActivity.getActivity(this.opportunityId)};
            console.log("CreateActivity(request = " + JSON.stringify(createRequest) + ")");
            let createResponse = await CreateActivity(createRequest);
            showMessageIfSuccess(this, createResponse.IsSuccess, "Activity Successfully Created", "An Unexpected Error has Occurred Unable to create new Activity");
        }
        this.isLoading = false;
        this.doShowModal = false;

        const selectedEvent = new CustomEvent('activitycreated', {
            detail: null
        });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);

        console.log('<< handelCreateNewActivity()');
    }

    hadleCloseModal() {
        this.dispatchEvent(
            new CustomEvent('modalclosed', {
                detail: null
            })
        );
    }
}