/**
 * Created by Ethan Sargent on 2/3/20.
 */

import {LightningElement, api, track, wire} from 'lwc';
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import {NavigationMixin} from "lightning/navigation";
import getOpportunities from '@salesforce/apex/OpportunityMatchController.getOpportunities'
import {toastErrorOnFail} from 'c/common';

const personColumns = [
    {label: 'Full Name', fieldName: 'PersonName'},
    {label: 'Email', fieldName: 'PersonEmail'},
    {label: 'Mobile', fieldName: 'PersonPhoneMobile'}
];

const opportunityColumns = [
    {label: "Opportunity Name", fieldName: "OpportunityName"},
    {label: "Brand", fieldName: "VehicleBrand"},
    {label: "Primary Model of Interest", fieldName: "VehicleModel"},
    {label: "Primary Contact", fieldName: "PrimaryContact"},
    {label: "Owner", fieldName: "Owner"},
    {label: "Created Date", fieldName: "CreatedDate"}
];


export default class AddOpportunityDeduplication extends NavigationMixin(LightningElement)
{
    @api isCompany;
    @api accountData;

    contactId = null;
    accountId = null;
    contactFirstName = null;
    contactLastName = null;
    companyName = null;
    contactMobile = null;
    contactEmail = null;

    @track personColumns = personColumns;

    @track showOpportunity = false;

    @track opportunityColumns = opportunityColumns;

    @track opportunityData;

    cancelHandler()
    {
        this.fireCancelEvent();
    }

    fireCancelEvent()
    {
        this.dispatchEvent(new CustomEvent('cancel'));
    }

    createNewHandler()
    {
        this.fireFinishEvent();
    }

    fireFinishEvent()
    {
        this.dispatchEvent(new CustomEvent('finish', {
            detail: {
                accountId: this.accountId,
                contactId: this.contactId,
                accountName: this.companyName,
                firstName: this.contactFirstName,
                lastName: this.contactLastName,
                companyName: this.companyName,
                contactMobile: this.contactMobile,
                contactEmail: this.contactEmail
            }
        }));
    }

    handleContactSelected(e)
    {
        console.log('Contact Selected');
        console.log('Contact Event:');
        console.log(e);
        this.contactId = e.detail.contactId;
        this.accountId = e.detail.accountId;
        this.companyName = e.detail.accountName;
        this.contactFirstName = e.detail.contactFirstName;
        this.contactLastName = e.detail.contactLastName;
        this.contactMobile = e.detail.contactMobile;
        this.contactEmail = e.detail.contactEmail;
        console.log('ContactId: ' + this.contactId);
        console.log('accountId: ' + this.accountId);
        this.modalStageForward();
        this.dispatchEvent(new ShowToastEvent({
            title: 'Success',
            message: 'The selected record will be used for the new opportunity.',
            variant: 'success'
        }))
    }

    handleRowSelected(e)
    {
        const selectedRows = e.detail.selectedRows;
        this.contactId = selectedRows[0].PersonContactId;
        this.accountId = selectedRows[0].Id;
        this.contactFirstName = selectedRows[0].PersonFirstName;
        this.contactLastName = selectedRows[0].PersonLastName;
        this.contactEmail = selectedRows[0].PersonEmail;
        this.contactMobile = selectedRows[0].PersonPhoneMobile;
        this.modalStageForward();
    }

    opportunityCancelHandler()
    {
        this.modalStageBackward();
    }

    async modalStageForward()
    {
        if (this.contactId)
        {
            let req = {
                ContactId: this.contactId
            };
            console.log('getOpportunities(' + JSON.stringify(req) + ')');
            let response = await toastErrorOnFail(getOpportunities({request: req}));
            console.log('getOpportunities -> ' + JSON.stringify(response));

            if (response.Opportunities.length > 0)
            {
                this.opportunityData = response.Opportunities;
                this.showOpportunity = true;
            }
            else
            {
                this.dispatchEvent(new ShowToastEvent(
                    {
                        title: 'Success',
                        message: 'No duplicate opportunities found',
                        variant: 'success'
                    }));
                this.fireFinishEvent();
            }
        }
        else
        {
            this.dispatchEvent(new ShowToastEvent(
                {
                    title: 'Success',
                    message: 'New contact will be created',
                    variant: 'success'
                }));
            this.fireFinishEvent();
        }

    }

    modalStageBackward()
    {
        this.showOpportunity = false;
    }

    handleOpportunitySelected(e)
    {
        const selectedOpp = e.detail.selectedRows[0];
        console.log(selectedOpp);
        console.log('Opportunity Id: ' + selectedOpp.Id);
        try
        {
            this[NavigationMixin.Navigate]({
                type: "standard__recordPage",
                attributes: {
                    recordId: selectedOpp.Id,
                    objectApiName: "Opportunity", // objectApiName is optional
                    actionName: "view"
                }
            });
            console.log('Post Navigate?');
        }
        catch (exc)
        {
            console.log(exc);
        }
    }
}