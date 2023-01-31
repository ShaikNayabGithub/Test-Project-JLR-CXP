/**
 * Created by caleb on 17/03/2021.
 */

import {LightningElement, track, api} from 'lwc';
import GetConversionData from '@salesforce/apex/OpportunityConversionController.getConversionData';
import GetAccountsOpportunities from '@salesforce/apex/OpportunityConversionController.getAccountsOpportunities';
import ConvertLead from '@salesforce/apex/OpportunityConversionController.ConvertLead';
import {toastErrorOnFail} from 'c/common';
import {showToastSuccess} from "c/utilToastMessages";

export default class OpportunityCustomConvert extends LightningElement
{
    @api recordId;
    @track
    leadFirstName;
    @track
    leadLastName;
    @track
    leadEmail;
    @track
    leadPhoneMobile;
    @track
    matchingPersonAccounts;
    @track
    opportunityName;

    @track
    doShowModal = false
    @track
    isLoading = false
    @track
    errors = []

    columns = [
        { label: 'First Name', fieldName: 'PersonFirstName' },
        { label: 'Last Name', fieldName: 'PersonLastName' },
        { label: 'Email', fieldName: 'PersonEmail', type: 'email' },
        { label: 'Mobile Phone', fieldName: 'PersonPhoneMobile', type: 'phone' },
        { label: 'Match Confidence', fieldName: 'MatchPercentage', type: 'percent' }
    ];

    opportunityColumns = [
        { label: 'Name', fieldName: 'Name' },
        { label: 'Make', fieldName: 'Make' },
        { label: 'Model', fieldName: 'Model' }
    ];

    get createNew()
    {
        let createNewInput = this.template.querySelector('.create-new-input');
        return createNewInput.checked;
    }

    set createNew(val)
    {
        if (val === true)
        {
            let createNewInput = this.template.querySelector('.create-new-input');
            if (createNewInput) createNewInput.checked = true;
            let useExistingInput = this.template.querySelector('.use-existing-input');
            if (useExistingInput) useExistingInput.checked = false;

            // set the selected rows back to not selected
            let existingAccTable = this.template.querySelector('.existing-account-table');
            if (existingAccTable) existingAccTable.selectedRows = [];

            let useExistingOpportunityInput = this.template.querySelector('.use-existing-opportunity');
            if (useExistingOpportunityInput) useExistingOpportunityInput.disabled = true;

            this.createNewOpportunity = true;

            this.matchingOpportunities = [];
            this.selectedAccountId = undefined;
        }
        else
        {
            let createNewInput = this.template.querySelector('.create-new-input');
            if (createNewInput) createNewInput.checked = false;
            let useExistingInput = this.template.querySelector('.use-existing-input');
            if (useExistingInput) useExistingInput.checked = true;

            let useExistingOpportunityInput = this.template.querySelector('.use-existing-opportunity');
            if (useExistingOpportunityInput) useExistingOpportunityInput.disabled = false;
        }
    }

    get createNewOpportunity()
    {
        let createNewInput = this.template.querySelector('.create-new-opportunity');
        return createNewInput.checked;
    }

    set createNewOpportunity(val)
    {
        if (val === true)
        {
            let createNewInput = this.template.querySelector('.create-new-opportunity');
            if (createNewInput) createNewInput.checked = true;
            let useExistingInput = this.template.querySelector('.use-existing-opportunity');
            if (useExistingInput) useExistingInput.checked = false;

            // set the selected rows back to not selected
            let existingAccTable = this.template.querySelector('.existing-opportunity-table');
            if (existingAccTable) existingAccTable.selectedRows = [];
            this.selectedOpportunityId = undefined;
        }
        else
        {
            let createNewInput = this.template.querySelector('.create-new-opportunity');
            if (createNewInput) createNewInput.checked = false;
            let useExistingInput = this.template.querySelector('.use-existing-opportunity');
            if (useExistingInput) useExistingInput.checked = true;
        }
    }

    async connectedCallback()
    {
        this.createNew = true;
        this.createNewOpportunity = true;
    }

    handleCreateNewSelected()
    {
        this.createNew = true;
    }

    handleUseExistingSelected()
    {
        console.log('existing selected');
        this.createNew = false;
    }

    handleOpportunityCreateNewSelected()
    {
        this.createNewOpportunity = true;
    }

    handleOpportunityUseExistingSelected()
    {
        this.createNewOpportunity = false;
    }

    @track
    selectedAccountId;
    @track
    matchingOpportunities;
    @track
    selectedOpportunityId;

    async handleRowSelected(evt)
    {
        this.selectedAccountId = evt?.detail?.selectedRows?.[0]?.Id;
        this.createNew = false;
        console.log('this.selectedAccountId = ' + this.selectedAccountId);
        this.matchingOpportunities = await toastErrorOnFail(GetAccountsOpportunities({accountId: this.selectedAccountId}));

    }

    handleOpportunityRowSelected(evt)
    {
        this.selectedOpportunityId = evt?.detail?.selectedRows?.[0]?.Id;
        this.createNewOpportunity = false;
        console.log('this.selectedOpportunityId = ' + this.selectedOpportunityId);
    }

    async handleSubmit()
    {
        if (!this.selectedAccountId && !this.createNew)
        {
            this.errors = [{id: 1, message: "please select an existing account"}]
            return;
        }
        if (!this.selectedOpportunityId && !this.createNewOpportunity)
        {
            this.errors = [{id: 1, message: "please select an existing opportunity"}]
            return;
        }

        let request = {
            leadId: this.recordId,
            accountId: this.selectedAccountId,
            opportunityId: this.selectedOpportunityId,
            opportunityName: this.opportunityName,
            accountFirstName: this.leadFirstName,
            accountLastName: this.leadLastName,
            accountEmail: this.leadEmail,
            accountMobile: this.leadPhoneMobile
        };

        this.isLoading = true;

        await toastErrorOnFail(ConvertLead({req: request}));

        showToastSuccess('Opportunity Converted Successfully');

        this.isLoading = false;
        this.doShowModal = false;
    }

    async handleOpenModal()
    {
        let res = await toastErrorOnFail(GetConversionData({leadId: this.recordId}));
        this.leadFirstName = res.leadFirstName;
        this.leadLastName = res.leadLastName;
        this.leadEmail = res.leadEmail;
        this.leadPhoneMobile = res.leadPhoneMobile;
        this.opportunityName = res.opportunityName;
        this.matchingPersonAccounts = res.MatchingPersonAccounts.map(x =>
        {
            x.MatchPercentage = (1 - x.MatchScore / 10);
            return x;
        });
        this.matchingPersonAccounts = this.matchingPersonAccounts.slice(0, 16);

        this.doShowModal = true;
    }

    handleCancel()
    {
        this.doShowModal = false;
    }
}