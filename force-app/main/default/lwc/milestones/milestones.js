/**
 * Created by GrantMillgate-EasyTe on 14/10/2019.
 */

import {LightningElement, api, track, wire} from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import GetMilestones from '@salesforce/apex/OpportunitiesController.getMilestones';
import {NavigationMixin} from "lightning/navigation";
import SyncDms from '@salesforce/apex/OpportunitiesController.sendOpportunityToDms';
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import createAndCloseActivity from  "@salesforce/apex/ActivitiesController.createAndCloseActivity";
import deleteActivity from  "@salesforce/apex/ActivitiesController.deleteActivity";
import {toastErrorOnFail} from 'c/common';
// import DOWN_ARROW_URL from '@salesforce/resourceUrl/GreenDownArrow1';


export default class Milestones extends NavigationMixin(LightningElement) {

    @api
    disabled = false;

    initialized = false;
    @api opportunityId;
    @api selectedVariantId;
    @api lastName;
    @api pricebookId;
    @api isPersonAccount;
    @track activityId;

    @api corporateEligibilityEnabled;
    @api corporateEligibilityMessage;

    //MilestoneItem
    @track milestoneDisplayName;
    @track milestoneApiName;
    @track relatedMilestone;


    //Qualification
    @track isQualificationChecked = false;
    @track isQualificationInProgress = false;
    @track qualificationId;

    //Test Drive
    @track isTestDriveChecked = false;
    @track isTestDriveInProgress = false;
    @track testDriveId;

    //Select Vehicle
    @track isVehicleSelectionChecked = false;
    @track isVehicleSelectionInProgress = false;
    @track vehicleSelectionId;

    //Appraisal
    @track isAppraisalChecked = false;
    @track isAppraisalInProgress = false;
    @track appraisalId;

    //Negotiation
    @track isNegotiationChecked = false;
    @track isNegotiationInProgress = false;
    @track negotiationId;

    //OrderTaken
    @track isOrderTakenChecked = false;
    @track isOrderTakenInProgress = false;
    @track orderTakenId;

    //Handover
    @track isHandoverChecked = false;
    @track isHandoverInProgress = false;
    @track handoverId;

    //QFF
    @track showValidateQff = false;

    //Corporate Service Plan
    @track showCorporateEligibility = false;

    @track showModal = false;
    @track showMilestoneModal = false;
    @track showMilestoneTask = false;
    @track showMilestoneEvent = false;
    @track showActivitiesTimeLine = false;
    @track showCreateActivityModal = false;

    connectedCallback() {
        if (!this.initialized) {
            this.getMilestones();
        }
    }

    processResultErrors(response){
        if (response.Errors !== undefined && response.Errors.length !== 0) {
            this.showErrorToastMsg(JSON.stringify(response.Errors[0].Detail));
        }
    }

    @api
    hasAnOpenMilestone()
    {
        console.log('>> hasAnOpenMilestone()');
        //let isCheckedList = [this.isQualificationChecked, this.isTestDriveChecked, this.isVehicleSelectionChecked, this.isAppraisalChecked, this.isNegotiationChecked, this.isOrderTakenChecked, this.isHandoverChecked];
        let isInProgress = [this.isQualificationInProgress, this.isTestDriveInProgress, this.isVehicleSelectionInProgress, this.isAppraisalInProgress, this.isNegotiationInProgress, this.isOrderTakenInProgress, this.isHandoverInProgress];
        let result = !isInProgress.every(x => !x);
        console.log('<< hasAnOpenMilestone() = ' + result);
        return result;
    }

    get shouldCreateActivity() {
        if (!this.opportunityId) return false;

        let result = !this.hasAnOpenMilestone();

        console.log('<< shouldCreateActivity() = ' + result);

        return result;
    }

    handelOpenCreateActivityModal() {
        this.showCreateActivityModal = true;
    }

    handelActivityCreated() {
        this.getMilestones();
        this.showCreateActivityModal = false;
    }

    handleModalClosed() {
        this.showCreateActivityModal = false;
    }

    showSuccessToastMsg(msg) {
        const toast = new ShowToastEvent({
            title: "Success",
            message: msg,
            variant: "success"
        });
        this.dispatchEvent(toast);
    }

    showErrorToastMsg(msg) {
        const toast = new ShowToastEvent({
            title: "Error",
            message: msg,
            variant: "error"
        });
        this.dispatchEvent(toast);
    }

    @api
    getMilestones() {
        console.log('>> getMilestones()');
        this.initialized = true;
        let request = {};
        request.OpportunityId = this.opportunityId;
        toastErrorOnFail(GetMilestones({
            request: request
        }))
            .then(result => {
                console.log('Milestones: ' + JSON.stringify(result));
                this.parseResponse(result);
            })
            .catch(error => {
                this.resetMilestones();
                console.log("Errors: " + JSON.stringify(error));
                this.showErrorToastMsg(JSON.stringify(error));
            });
        console.log('<< getMilestones');
    }

    parseResponse(result) {
        //Qualification
        this.isQualificationChecked = result.IsQualificationComplete;
        this.isQualificationInProgress = result.IsQualificationInProgress;
        this.qualificationId = result.QualificationId;

        //Test Drive
        this.isTestDriveChecked = result.IsTestDriveComplete;
        this.isTestDriveInProgress = result.IsTestDriveInProgress;
        this.testDriveId = result.TestDriveId;

        //Vehicle Selection
        this.isVehicleSelectionChecked = result.IsVehicleSelectionComplete;
        this.isVehicleSelectionInProgress = result.IsVehicleSelectionInProgress;
        this.vehicleSelectionId = result.VehicleSelectionId;

        //Appraisal
        this.isAppraisalChecked = result.IsAppraisalComplete;
        this.isAppraisalInProgress = result.IsAppraisalInProgress;
        this.appraisalId = result.AppraisalId;

        //Negotiation
        this.isNegotiationChecked = result.IsNegotiationComplete;
        this.isNegotiationInProgress = result.IsNegotiationInProgress;
        this.negotiationId = result.NegotiationId;

        //OrderTaken
        this.isOrderTakenChecked = result.IsOrderTakenComplete;
        this.isOrderTakenInProgress = result.IsOrderTakenInProgress;
        this.orderTakenId = result.OrderTakenId;

        //Handover
        this.isHandoverChecked = result.IsHandoverComplete;
        this.isHandoverInProgress = result.IsHandoverInProgress;
        this.handoverId = result.HandoverId;
    }

    resetMilestones() {
        this.isQualificationChecked = false;
        this.isQualificationInProgress = false;
        this.isTestDriveChecked = false;
        this.isTestDriveInProgress = false;
        this.isVehicleSelectionChecked = false;
        this.isVehicleSelectionInProgress = false;
        this.isNegotiationChecked = false;
        this.isNegotiationInProgress = false;
        this.isOrderTakenChecked = false;
        this.isOrderTakenInProgress = false;
        this.isHandoverChecked = false;
        this.isHandoverInProgress = false;
        this.isAppraisalChecked = false;
        this.isAppraisalInProgress = false;
    }

    handleValidateClick(evt) {
        console.log('>> handleValidateClick');
        this.showModal = true;
        this.showValidateQff = true;
    }

    handleSyncToDmsClick() {
        console.log('>> handleSyncToDmsClick');
        this.syncToDms();
        console.log('<< handleSyncToDmsClick');
    }

    syncToDms() {
        console.log('>> syncToDms');
        let request = {};
        request.OpportunityId = this.opportunityId;
        console.log('SyncToDmsRequest : ' + JSON.stringify(request));
        toastErrorOnFail(SyncDms({
            request: request
        }))
            .then(result => {
                console.log('SyncDmsResult: ' + JSON.stringify(result));
                if (result.Errors !== undefined && result.Errors.length !== 0) {
                    this.showErrorToastMsg(JSON.stringify(result.Errors[0].Detail));
                } else {
                    this.showSuccessToastMsg("Synced To DMS");
                }

            })
            .catch(error => {
                console.log('SyncDmsError: ' + JSON.stringify(error));
                this.showErrorToastMsg(JSON.stringify(error));
            });
        console.log('<< syncToDms');
    }

    verifyEligibilityCorporate() {
        console.log('>> verifyEligibilityCorporate()');
        this.showModal = true;
        this.showCorporateEligibility = true;
        console.log('<< verifyEligibilityCorporate()');
    }

    //Activities that are in progress will have a recordId
    handleMilestoneClicked(evt) {
        console.log('>> handleMilestoneClicked' + JSON.stringify(evt));

        let activityId = evt.detail.recordId;
        if (activityId != undefined) {
            this.navigateToRecordViewPage(activityId);
        } else {
            this.milestoneApiName = evt.detail.milestoneApiName;
            this.milestoneDisplayName = evt.detail.milestoneDisplayName;
            this.relatedMilestone = evt.detail.relatedMilestone;
        }

    }

    async handelMilestoneCheckboxClicked(evt)
    {
        console.log('evt = ' + JSON.stringify(evt));
        if (evt.detail.isChecked)
        {
            // create and close Activity
            let activityRequest = {};
            activityRequest.ActivityType = 'Task';
            activityRequest.OpportunityId = this.opportunityId;
            activityRequest.Subject =  evt.detail.relatedMilestone;
            activityRequest.DueDateTime = new Date();
            activityRequest.DoSetReminder = false;
            activityRequest.Comments = 'Ticked Off Not Completed';
            activityRequest.RelatedMilestone =  evt.detail.relatedMilestone;
            console.log('createAndCloseActivity(' + JSON.stringify(activityRequest) + ')');
            let res = await toastErrorOnFail(createAndCloseActivity({ request: activityRequest }));
            console.log('res = ' + JSON.stringify(res));
        }
        else
        {
            // delete activity
            let activityRequest = {};
            console.log('recordId = ' + evt.detail.recordId);
            activityRequest.RelatedMilestone = evt.detail.relatedMilestone;
            activityRequest.OpportunityId = this.opportunityId;
            console.log('deleteActivity(' + JSON.stringify(activityRequest) + ')');
            let res = await toastErrorOnFail(deleteActivity({ request: activityRequest }));
            console.log('res = ' + JSON.stringify(res));
        }

    }

    handleMilestoneCreateTaskClicked(evt) {
        console.log('>> handleMilestoneCreateTaskClicked' + JSON.stringify(evt));
        this.showMilestoneTask = true;
        this.showMilestoneModal = false;
        this.showModal = true;

    }

    handleMilestoneCreateEventClicked(evt) {
        console.log('>> handleMilestoneCreateEventClicked' + JSON.stringify(evt));
        this.showMilestoneEvent = true;
        this.showMilestoneModal = false;
        this.showModal = true;

    }

    handleCloseModal() {
        this.hideAllModals();
    }

    hideAllModals() {
        this.showModal = false;
        this.showValidateQff = false;
        this.showMilestoneModal = false;
        this.showMilestoneTask = false;
        this.showMilestoneEvent = false;
        this.showCorporateEligibility = false;
    }

    handleActivityCreated() {
        this.getMilestones();
    }

    //Go To Record
    navigateToRecordViewPage(record) {
        // View a custom object record.
        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
                recordId: record,
                objectApiName: "Opportunity", // objectApiName is optional
                actionName: "view"
            }
        });
    }

    handleCorporateAccountUpdated(evt) {
        this.hideAllModals()
        let corporatePartner = evt.detail;
        const selectedEvent = new CustomEvent('corporateaccountupdated', {
            detail: corporatePartner
        });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }

    get personAccountFlowUrl()
    {
        return '/change-account-type/?opportunityId=' + this.opportunityId + '&flowName=Create_Person_Account_from_Opportunity';
    }

    get corpAccountFlowUrl()
    {
        return '/change-account-type/?opportunityId=' + this.opportunityId + '&flowName=Create_Corporate_Account_from_Person_Account_on_Opportunity';
    }

    handelConvertToPersonAccountLink()
    {
        console.log('opporunityId = ' + this.opportunityId);
        this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: this.personAccountFlowUrl
                }
            },
            false
        );
    }

    handelConvertToCorpAccountLink()
    {
        console.log('opporunityId = ' + this.opportunityId);
        this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: this.corpAccountFlowUrl
                }
            },
            false
        );
    }
}