/**
 * Created by caleb on 30/01/2020.
 */

import {LightningElement, api, track} from 'lwc';
import CreateActivity from '@salesforce/apex/ActivitiesController.createActivity';
import UpdateActivity from '@salesforce/apex/ActivitiesController.updateActivity';
import GetActivityInfo from '@salesforce/apex/ActivitiesController.GetActivityInfo';
import GetActivity from '@salesforce/apex/ActivitiesController.getActivities';
import CloseOpportunity from '@salesforce/apex/OpportunitiesController.closeMilestoneOpportunity';
import ForcedCloseOpportunity from '@salesforce/apex/OpportunitiesController.ForceCloseMilestoneOpportunity';
import GetMilestoneOpportunityInfo from '@salesforce/apex/OpportunitiesController.GetMilestoneOpportunityInfo';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import UpdateOpportunityContactDetails from '@salesforce/apex/ActivitiesController.updateOpportunityContactDetails';
import GetOpportunityContactMailingDetails from '@salesforce/apex/ActivitiesController.getOpportunityContactMailingDetails';


import {toastErrorOnFail} from 'c/common';

export default class MilestoneEventComplete extends NavigationMixin(LightningElement) {
    @track screenNumber = 1;
    @api activityType;
    @api recordId = "00T0Q000008zSrkUAE";
    @api opportunityId;

    @track opportunityEmail;

    @track doMarkComplete = false;
    @track doCloseOpportunity = false;
    @track doShowCloseOpportunityCheckBox = true;

    @track isLoading = false;

    @track nextMilestones;

    @track errors = [];

    ActivityWhatObjectType = undefined;

    accountId;

    // private requests
    closeOpportunityRequest = undefined;
    // used to force overwrite the default milestone in the new activity screen
    // if this is not undefined it will be used as the default milestone
    defaultMilestoneOverwrite = undefined;
    // used to overwrite the activity whatId
    whatIdOverwrite = undefined;
    // used to overwrite the activity whoId
    whoIdOverwrite = undefined;

    get isOnFirstScreen()
    {
        return this.screenNumber === 1;
    }
    get isOnSecondScreen()
    {
        return this.screenNumber === 2;
    }
    get isOnThirdScreen()
    {
        return this.screenNumber === 3;
    }

    get isOnForthScreen()
    {
        return this.screenNumber === 4;
    }

    get isOnFifthScreen()
    {
        return this.screenNumber === 5;
    }

    get isOnSixthScreen()
    {
        return this.screenNumber === 6;
    }

    get isOnSeventhScreen()
    {
        return this.screenNumber === 7;
    }

    async connectedCallback()
    {
        console.log(">> connectedCallback()");
        if (this.opportunityId === undefined)
        {
            this.isLoading = true;
            await this.getActivityAndSetMilestonesAndOpportunityId();
            // get isClosed from opportunity used to decide wheather to give the user the option to close the opporuntiy
            let res = await toastErrorOnFail(GetActivityInfo({activityId: this.recordId}));
            console.log('GetActivityInfo() = ' + JSON.stringify(res));
            this.ActivityWhatObjectType = res.WhatType;
            if (res.WhatType === 'Opportunity')
            {
                this.doShowCloseOpportunityCheckBox = !res.OpportunityIsClosed;
                this.opportunityEmail = res.OpportunityContactEmail;
            }
            if (res.WhatType === 'Account')
            {
                this.whatIdOverwrite = res.Id;
                this.accountId = res.Id;
                this.whoIdOverwrite = res.WhoId;
                this.doShowCloseOpportunityCheckBox = false;
            }

            this.isLoading = false;
        }
        console.log("<< connectedCallback()");
    }

    async getActivityAndSetMilestonesAndOpportunityId()
    {
        let request = { request: { ActivityId: this.recordId } };
        console.log(">> GetActivity(request = " + JSON.stringify(request) + ")");
        let result = await toastErrorOnFail(GetActivity(request));
        this.parseGetActivityResult(result);
    }


    async handelClickFinishCreateEvent()
    {
        let nextActivity = this.template.querySelector('.next-activity');
        let isValid = nextActivity.isValid();
        if (isValid)
        {
            this.isLoading = true;
            // create record in salesforce
            let createRequest = {request: nextActivity.getActivity(this.opportunityId)};
            // overwrite the whatId if not undefined;
            if (this.whatIdOverwrite) createRequest.request.WhatId = this.whatIdOverwrite;
            if (this.whoIdOverwrite) createRequest.request.WhoId = this.whoIdOverwrite;
            console.log("CreateActivity(request = " + JSON.stringify(createRequest) + ")");

            let updateRequest = {request: { ActivityId: this.recordId, ActivityType: this.activityType, IsCompleted: this.doMarkComplete}};
            console.log("UpdateActivity(request = " + JSON.stringify(updateRequest) + ")");

            const createTask = toastErrorOnFail(CreateActivity(createRequest));
            let createResult = await createTask;

            const updateTask = toastErrorOnFail(UpdateActivity(updateRequest));
            let updateResult = await updateTask;

            this.parseCreateActivityResult(createResult);
            this.showErrorIfNotSuccess(updateResult);
            // redirect to opportunity screen
            if (createResult.IsSuccess && updateResult.IsSuccess && this.accountId) this.redirectToAccountScreen();
            if (createResult.IsSuccess && updateResult.IsSuccess && !this.accountId) this.redirectToOppScreen();
            this.isLoading = false;
        }
    }

    async handelClickFinishWithoutFollowupActivity()
    {
        this.isLoading = true;
        let updateRequest = {request: { ActivityId: this.recordId, ActivityType: this.activityType, IsCompleted: this.doMarkComplete}};
        console.log("UpdateActivity(request = " + JSON.stringify(updateRequest) + ")");

        const updateTask = toastErrorOnFail(UpdateActivity(updateRequest));
        let updateResult = await updateTask;
        this.isLoading = false;
        this.redirectToOppScreen();
    }



    async afterOppClosedUpdateActivityAndNextScreen()
    {
        let updateActivityRequest = {request: { ActivityId: this.recordId, ActivityType: this.activityType, IsCompleted: true}};
        console.log("UpdateActivity(request = " + JSON.stringify(updateActivityRequest) + ")");

        const updateTask = toastErrorOnFail(UpdateActivity(updateActivityRequest));
        let updateResult = await updateTask;

        this.showErrorIfNotSuccess(updateResult);

        // todo - refactor milestone population so this can be parsed into the function
        //this.defaultMilestoneOverwrite = 'Handover_RDA';
        console.log('defaultMilestoneOverwrite = ' + this.defaultMilestoneOverwrite);
        await this.getActivityAndSetMilestonesAndOpportunityId();

        this.screenNumber = 5;
    }

    @track
    assetAlreadyAssignedModalTable;

    assetAlreadyAssignedModalProceed;

    async closeOpportunityAndNextScreen()
    {
        const closeTask = toastErrorOnFail(CloseOpportunity(this.closeOpportunityRequest));
        let closeResult = await closeTask;
        this.showErrorIfNotSuccess(closeResult);

        if (closeResult.DuplicateOpportunities.length > 0)
        {
            this.assetAlreadyAssignedModalTable = closeResult.DuplicateOpportunities;
            this.screenNumber = 6;
            this.assetAlreadyAssignedModalProceed = async () => {
                this.isLoading = true;
                let closeOppRes = await toastErrorOnFail(ForcedCloseOpportunity(this.closeOpportunityRequest));
                console.log('closeOppRes = ' + JSON.stringify(closeOppRes));
                await this.afterOppClosedUpdateActivityAndNextScreen();
                this.isLoading = false;
            }
            return;
        }

        await this.afterOppClosedUpdateActivityAndNextScreen();
    }

    @track
    isLost

    async checkAddressInfoBeforeClosingOpportunity()
    {
        //let res = await toastErrorOnFail(GetOpportunityContactMailingDetails({opportunityId: this.opportunityId}));
        //if (res. && !this.isLost)
        //{
        //    this.screenNumber = 7
        //    return
        //}
        if (!this.isLost)
        {
            this.screenNumber = 7;
            return;
        }
        await this.closeOpportunityAndNextScreen();
    }

    async updateAddressInfoBeforeClosingOpportunity()
    {
        this.isLoading = true;
        let updateActivity = this.template.querySelector('.update-address');
        if (!updateActivity.isValid())
        {
            this.isLoading = false;
            return;
        }
        console.log("UpdateOpportunityContactDetails(" + JSON.stringify({opportunityId: this.opportunityId, address: updateActivity.getAddressUpdate()}) + ")");
        await toastErrorOnFail(UpdateOpportunityContactDetails({opportunityId: this.opportunityId, address: updateActivity.getAddressUpdate()}));
        await this.closeOpportunityAndNextScreen();
        this.isLoading = false;
    }

    async handelClickFinishCloseOppConfirmation()
    {
        this.isLoading = true;

        console.log("CloseOpportunity(request = " + JSON.stringify(this.closeOpportunityRequest) + ")");

        await this.checkAddressInfoBeforeClosingOpportunity();
        this.isLoading = false;
    }

    async handelClickFinishCloseOpp()
    {
        let closeOpp = this.template.querySelector('.close-opportunity');
        let isValid = closeOpp.isValid();
        if (isValid)
        {
            this.isLoading = true;

            this.closeOpportunityRequest = { request: closeOpp.getActivityUpdate(this.opportunityId) };
            this.isLost = this.closeOpportunityRequest.request.OpportunityStage === "Lost";

            // this will validate you can close the opportunity will sometimes go to screen 4
            if(!await this.validateOpportunity(closeOpp, this.isLost))
            {
                this.isLoading = false;
                return;
            }

            console.log("CloseOpportunity(request = " + JSON.stringify(this.closeOpportunityRequest) + ")");

            await this.checkAddressInfoBeforeClosingOpportunity();
            this.isLoading = false;
        }
    }

    async validateOpportunity(errorObject, isLost)
    {
        // validate the opportunity is filled out
        errorObject.errors = [];
        console.log("opp id = " + this.opportunityId);

        let getOpportunityInfoRequest = {request: {OpportunityId: this.opportunityId}};
        console.log("GetMilestoneOpportunityInfo(request = " + JSON.stringify(getOpportunityInfoRequest) + ")");

        const getTask = toastErrorOnFail(GetMilestoneOpportunityInfo(getOpportunityInfoRequest));
        let getResult = await getTask;
        this.showErrorIfNotSuccess(getResult);

        if (!isLost)
        {
            if (!getResult.HasDerivativeSelected)
            {
                errorObject.errors = [{ id: "1", message: "Please Select a Derivative Before Closing the Opportunity" }];
                return false;
            }
            if (!getResult.HasAssetSelected)
            {
                this.screenNumber = 4;
                return false;
            }
        }
        else
        {
            this.whatIdOverwrite = getResult.AccountId;
        }

        return true;
    }

    parseGetActivityResult(result)
    {
        console.log("response = " + JSON.stringify(result));
        let isSuccess = result.IsSuccess;
        if (isSuccess && result.Tasks.length)
        {
            this.activityType = "Task";
            this.opportunityId = result.Tasks[0].Attributes.WhatId;
            this.initMilestones(result.Tasks[0].NextMilestone);

            console.log("activityType = " + this.activityType);
            console.log("opportunityId = " + this.opportunityId);
        }
        else if (isSuccess && result.Events.length)
        {
            this.activityType = "Event";
            this.opportunityId = result.Events[0].Attributes.WhatId;
            this.initMilestones(result.Events[0].NextMilestone);

            console.log("activityType = " + this.activityType);
            console.log("opportunityId = " + this.opportunityId);
        }
        else
        {
            this.showToastError("An Unexpected Error has Occurred Unable to Obtain OpportunityId");
        }
    }

    // milestones
    initMilestones(miles)
    {
        console.log('>> initMilestones(' + JSON.stringify(miles) + ')');
        let milestones = [];
        for (let i = 0; i < miles.length; i++)
        {
            if (this.defaultMilestoneOverwrite)
            {
                console.log('MilestoneDevName = ' + miles[i].ActivityMilestoneDeveloperName);
                milestones.push(this.buildMilestone(miles[i].Label, miles[i].ActivityMilestoneDeveloperName, this.defaultMilestoneOverwrite === miles[i].ActivityMilestoneDeveloperName));
            }
            else
            {
                console.log('MilestoneDevName = ' + miles[i].ActivityMilestoneDeveloperName);
                milestones.push(this.buildMilestone(miles[i].Label, miles[i].ActivityMilestoneDeveloperName, miles[i].IsDefault));
            }
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

    parseCreateActivityResult(result)
    {
        console.log("response = " + JSON.stringify(result));
        let isSuccess = result.IsSuccess;
        // set event as complete

        // show toast event
        if (isSuccess)
        {
            const event = new ShowToastEvent({
                title: "Success",
                message: "Activity Created",
                variant: "success"
            });
            this.dispatchEvent(event);
        }
        else
        {
            this.showToastError("An Unexpected Error has Occurred Unable to create new Activity");
        }
    }

    showErrorIfNotSuccess(result)
    {
        console.log("response = " + JSON.stringify(result));
        let isSuccess = result.IsSuccess;

        if (!isSuccess)
        {
            this.showToastError("An Unexpected Error has Occurred Unable to Complete Request");
        }
    }

    showToastError(message)
    {
        const event = new ShowToastEvent({
            title: "Error",
            message: message,
            variant: "error"
        });
        this.dispatchEvent(event);
    }

    //region Handelers
    handelDoMarkCompleteChange(evt)
    {
        this.doMarkComplete = evt.detail;
        console.log("doMarkComplete = " + this.doMarkComplete);
    }

    handelDoCloseOpportunityChange(evt)
    {
        this.doCloseOpportunity = evt.detail;
        console.log("doCloseOpportunity = " + this.doCloseOpportunity);
    }

    handelClickNext(evt)
    {
        if (this.screenNumber === 1)
        {
            this.errors = [];
            if (!this.doCloseOpportunity && !this.doMarkComplete)
            {
                this.errors = [{ id: "1", message: "Please select at least one of the above" }];
            }
            else if (!this.doShowCloseOpportunityCheckBox)
            {
                // opportunity is already closed
                this.screenNumber = 5;
            }
            else if (this.doCloseOpportunity === true)
            {
                this.screenNumber = 3;
            }
            else if (this.doCloseOpportunity === false)
            {
                this.screenNumber = 2;
            }
        }
    }

    handelClickNextGotoCreateActivity(evt)
    {
        this.screenNumber = 2;
    }

    handelClickBack(evt) {
        this.screenNumber = 1;
    }

    async handelClickCancel()
    {
        // if the opp was already closed we have not yet closed the activity and we should do so
        if (this.doMarkComplete && !this.doShowCloseOpportunityCheckBox)
        {
            this.isLoading = true
            let updateRequest = {request: { ActivityId: this.recordId, ActivityType: this.activityType, IsCompleted: this.doMarkComplete}};
            console.log("UpdateActivity(request = " + JSON.stringify(updateRequest) + ")");

            const updateTask = toastErrorOnFail(UpdateActivity(updateRequest));
            let updateResult = await updateTask;
            this.isLoading = false
        }

        this.redirectToOppScreen();
    }
    //endregioners


    redirectToOppScreen()
    {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.opportunityId,
                actionName: 'view'
            }
        });
    }

    redirectToAccountScreen()
    {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.accountId,
                actionName: 'view'
            }
        });
    }

}