/**
 * Created by caleb on 3/02/2020.
 */

const REGEX_EMAIL = '(?:[a-z0-9!#$%&\'*+\/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&\'*+\/=?^_`{|}~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])';
import GetOpportunityContactMailingDetails from '@salesforce/apex/ActivitiesController.getOpportunityContactMailingDetails';
import {LightningElement, track, api} from 'lwc';
import {toastErrorOnFail} from 'c/common';

export default class MilestoneCloseOpportunity extends LightningElement
{
    @track wonLostTypes = [{label: 'Won', value: 'Won'}, {label: 'Lost', value: 'Lost'}];
    @track currentWonLost = "Won";
    @track lostReasons;
    @track currentLostReason;
    @track lostDescription = "";
    @track handoverDate;
    @api opportunityEmail;
    @api opportunityId;

    @api errors = [];

    get isLost()
    {
        return this.currentWonLost === "Lost";
    }

    async connectedCallback() {
        if (this.relatedMilestones === undefined)
        {
            this.initLostReasons();
        }
    }

    // milestones
    initLostReasons() {
        console.log('>> initLostReasons()');
        let lostReasons = [];
        lostReasons.push(this.buildLostReason("Bought from other JLR dealer", "Bought from other JLR dealer"));
        lostReasons.push(this.buildLostReason("Bought other brand", "Bought other brand"));
        lostReasons.push(this.buildLostReason("Bought other JLR Product", "Bought other JLR Product"));
        lostReasons.push(this.buildLostReason("Cancelled Order", "Cancelled Order"));
        lostReasons.push(this.buildLostReason("Duplicate Lead", "Duplicate Lead"));
        lostReasons.push(this.buildLostReason("Finance Declined", "Finance Declined"));
        lostReasons.push(this.buildLostReason("Invalid Contact details or lead", "Invalid Contact details or lead"));
        lostReasons.push(this.buildLostReason("Location", "Location"));
        lostReasons.push(this.buildLostReason("Mystery Shopper", "Mystery Shopper"));
        lostReasons.push(this.buildLostReason("Other reason", "Other reason"));
        lostReasons.push(this.buildLostReason("Postponed Purchase", "Postponed Purchase"));
        lostReasons.push(this.buildLostReason("Price", "Price"));
        lostReasons.push(this.buildLostReason("Product", "Product"));
        lostReasons.push(this.buildLostReason("Trade price not attractive", "Trade price not attractive"));
        lostReasons.push(this.buildLostReason("Unable to Contact", "Unable to Contact"));
        lostReasons.push(this.buildLostReason("Vehicle not available", "Vehicle not available"));
        this.lostReasons = lostReasons;
        console.log('<< initLostReasons()');
    }

    buildLostReason(name, id) {
        let lostReason = {};
        lostReason.Name = name;
        lostReason.Id = id;
        lostReason.IsDefaultSelection = false;
        return lostReason;
    }

    @api
    isValid()
    {
        let lostReasonDropDown = this.template.querySelector('.input-lost-reason-dropdown');
        let handoverDateSelector = this.template.querySelector('.input-handover-date');
        let emailInput = this.template.querySelector('.input-email');

        let isValid = true;
        if (this.currentWonLost === "Lost")
        {
            lostReasonDropDown.errors = [];
            if (this.currentLostReason === undefined)
            {
                lostReasonDropDown.errors = [{ id: "1", message: "Please Select a Lost Reason" }];
                isValid = false;
            }
        }
        if (this.currentWonLost === "Won")
        {
            handoverDateSelector.errors = [];
            if (this.handoverDate === undefined)
            {
                handoverDateSelector.errors = [{ id: "1", message: "Please Select a Handover Date" }];
                isValid = false;
            }
            else if (new Date(this.handoverDate).setHours(0,0,0,0) < (new Date()).setHours(0,0,0,0))
            {
                handoverDateSelector.errors = [{ id: "1", message: "Please Select a Handover Date After the Current Date" }];
                isValid = false;
            }
        }
        return isValid;
    }

    @api
    getActivityUpdate(opportunityId)
    {
        let activityRequest = {};
        activityRequest.OpportunityId = opportunityId;
        activityRequest.OpportunityStage = this.currentWonLost;
        activityRequest.LostReason = this.currentLostReason;
        activityRequest.LostDescription = this.lostDescription;
        activityRequest.PlanedHandoverDate = this.handoverDate;
        //activityRequest.OpporunityEmail = this.opportunityEmail;

        return activityRequest;
    }

    handelWonLostChange(evt)
    {
        this.currentWonLost = evt.detail;
        console.log("currentWonLost = " + this.currentWonLost);
    }

    handelLostReasonChange(evt)
    {
        this.currentLostReason = evt.detail;
        console.log("currentLostReason = " + this.currentLostReason);
    }

    handelLostDescriptionChange(evt)
    {
        this.lostDescription = evt.detail;
        console.log("lostDescription = " + this.lostDescription);
    }

    handelHandoverDateChange(evt)
    {
        this.handoverDate = evt.detail;
        console.log("handoverDate = " + this.handoverDate);
    }

    /*
    handelOpportunityEmailChange(evt)
    {
        this.opportunityEmail = evt.detail;
        console.log("opportunityEmail = " + this.opportunityEmail);
    }
    */
}