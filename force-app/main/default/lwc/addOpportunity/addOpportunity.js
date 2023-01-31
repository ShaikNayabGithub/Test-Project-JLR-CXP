/**
/**
 * Created by GrantMillgate-EasyTe on 10/09/2019.
 * Updated by MaoficKarin on 13/09/2022.
 */

import {LightningElement, api, track, wire} from 'lwc';
// import DOWN_ARROW_URL from '@salesforce/resourceUrl/GreenDownArrow1';
import CreateOpportunity from '@salesforce/apex/OpportunitiesController.create';
import GetPricebook from '@salesforce/apex/OpportunitiesController.getPricebook2Id';
import GetCampaigns from '@salesforce/apex/CampaignsController.getCampaigns';
import {NavigationMixin} from "lightning/navigation";
import SearchForAccounts from '@salesforce/apex/CustomSearchController.searchForAccounts';
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import getAccounts from '@salesforce/apex/OpportunityMatchController.getAccounts';
import getPersonAccounts from '@salesforce/apex/OpportunityMatchController.getPersonAccounts';
import GetMakes from '@salesforce/apex/ProductsController.getMakes';
import GetModels from '@salesforce/apex/ProductsController.getModels';
import GetContacts from '@salesforce/apex/ContactsController.getContacts';
import {ValidationUtility} from 'c/validationUtility';

const REGEX_EMAIL = '(?:[a-z0-9!#$%&\'*+\/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&\'*+\/=?^_`{|}~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])';
const REGEX_PHONE = '^(?:\\+?(61))? ?(?:\\((?=.*\\)))?(0?[2-57-8])\\)? ?(\\d\\d(?:[- ](?=\\d{3})|(?!\\d\\d[- ]?\\d[- ]))\\d\\d[- ]?\\d[- ]?\\d{3})$';
const DELAY = 300;
const MILESTONES_TEST_DRIVE = 'Test_Drive';
const MILESTONE_QUALIFICATION = 'Qualified';
const ACTIVITY_TYPES_EVENT = 'Event';
const ACTIVITY_TYPES_TASK = 'Task';

export default class AddOpportunity extends NavigationMixin(LightningElement)
{
    validationUtility = new ValidationUtility();

    stageInitialized = false;
    @track doShowEmailOrMobileError = false;
    pricebookId = undefined;

    renderedCallback()
    {
        console.log('>> renderedCallback');
        if (this.doShowReminder !== undefined && this.dueDate !== undefined && this.dueDate !== '' && this.reminderDateTime === undefined)
        {
            console.log('Trying to set the reminder date');
            this.setReminderDate(this.dueDate + 'T00:00:00.000Z');
        }
        console.log('<< renderedCallback');

    }

    @api objectName;
    async connectedCallback()
    {
        if (this.leadSources === undefined)
        {
            this.buildLeadSources();
        }
        if (this.enquiryTypes === undefined)
        {
            this.buildEnquiryType();
        }
        if (this.initialSalesTypes === undefined)
        {
            this.buildInitialSalesType();
        }

        if (this.campaigns === undefined)
        {
            this.buildCampaigns();
        }
        if (this.activityTypes === undefined)
        {
            this.initActivityTypes();
        }

        if (this.relatedMilestones === undefined)
        {
            this.initMilestones(false);
        }

        if (this.pricebookId === undefined)
        {
            this.initPricebook();
        }

        await this.prePopulateContactInfoWithContactIdUrlParam();

        if (!this.makes)
        {
            await this.setMakes();
            this.modelsUnfilterd = (await GetModels());
        }
    }

    showErrorToastMsg(msg)
    {
        const toast = new ShowToastEvent({
            title: "Error",
            message: msg,
            variant: "error"
        });
        this.dispatchEvent(toast);
    }

    buildCampaigns()
    {
        let request = {};
        GetCampaigns({
            request: request
        })

            .then(result =>
            {
                this.parseCampaignResults(result);
            })

            .catch(error =>
            {
                this.campaigns = undefined;
                console.log(JSON.stringify(error));
            });
    }

    parseCampaignResults(results)
    {
        console.log('>> parseCampaignResults()');
        console.log('results: ' + JSON.stringify(results));
        this.campaigns = [];
        for (let i = 0; i < results.Data.length; i++)
        {
            console.log('result number : ' + i);
            let campaign = {};
            const result = results.Data[i];
            campaign.Id = result.Id;
            campaign.Name = result.Attributes.Name;
            console.log('campaign: ' + JSON.stringify(campaign));
            this.campaigns.push(campaign);
        }
        console.log('campaigns: ' + JSON.stringify(this.campaigns));
        console.log('<< parseCampaignResults()');
    }

    buildEnquiryType()
    {
        let enquiryTypePicklist=[];

        //Financial Service
        let financialService = {};
        financialService.Name = 'Financial Services';
        financialService.Id = 'Financial Services';
        enquiryTypePicklist.push(financialService);

        //Fleet & Business Enquiry
        let fleetAndBusinessEnquiry = {};
        fleetAndBusinessEnquiry.Name = 'Fleet and Business Enquiry';
        fleetAndBusinessEnquiry.Id = 'Fleet and Business Enquiry';
        enquiryTypePicklist.push(fleetAndBusinessEnquiry);

        //Service Interception
        let serviceInterception = {};
        serviceInterception.Name = 'Service Interception';
        serviceInterception.Id = 'Service Interception';
        enquiryTypePicklist.push(serviceInterception);

        //Generic
        let generic = {};
        generic.Name = 'Generic';
        generic.Id = 'Generic';
        enquiryTypePicklist.push(generic);

        this.enquiryTypes = enquiryTypePicklist;
    }

    buildInitialSalesType()
    {
        let initialSalesTypePicklist=[];

        //New Vehicle
        let newVehicle = {};
        newVehicle.Name = 'New';
        newVehicle.Id = 'New';
        initialSalesTypePicklist.push(newVehicle);

        //Demo Vehicle
        let demoVehicle = {};
        demoVehicle.Name = 'Demonstrator';
        demoVehicle.Id = 'Demonstrator';
        initialSalesTypePicklist.push(demoVehicle);

        //Approve Pre-Owned Vehicle
        let approvePreOwnedVehicle = {};
        approvePreOwnedVehicle.Name = 'Approved Pre Owned';
        approvePreOwnedVehicle.Id = 'Approved_Pre_Owned';
        initialSalesTypePicklist.push(approvePreOwnedVehicle);

        //Pre-Owned Vehicle
        let preOwnedVehicle = {};
        preOwnedVehicle.Name = 'Pre Owned';
        preOwnedVehicle.Id = 'Pre_Owned';
        initialSalesTypePicklist.push(preOwnedVehicle);

        this.initialSalesTypes = initialSalesTypePicklist;

    }

    buildLeadSources()
    {
        //todo - make dynamic from standard value set
        let sources = [];

        //walkin
        let walkIn = {};
        walkIn.Name = 'Walk-in';
        walkIn.Id = 'Walk-in';
        sources.push(walkIn);

        //email
        let email = {};
        email.Name = 'Email';
        email.Id = 'Email';
        sources.push(email);

        //phone
        let phone = {};
        phone.Name = 'Phone-in';
        phone.Id = 'Phone-in';
        sources.push(phone);

        //referral
        let referral = {};
        referral.Name ='Referral';
        referral.Id = 'Referral';
        sources.push(referral);

        //referral
        let existingCustomer = {};
        existingCustomer.Name ='Existing Customer';
        existingCustomer.Id = 'Existing Customer';
        sources.push(existingCustomer);


        this.leadSources = sources;
    }

    @track
    firstName;
    @track
    doShowNameFirstError = false;

    handleFirstNameChange(evt)
    {
        this.doShowNameFirstError = false;
        this.firstName = evt.target.value;
    }

    @track
    lastName;
    @track
    doShowNameLastError = false;

    handleLastNameChange(evt)
    {
        this.doShowNameLastError = false;
        let lastName = evt.target.value;
        this.lastName = lastName;
        // Old deduplication method, to be deprecated
        //this.updateSearchKey(lastName);
    }

    @track
    company;

    handleCompanyChange(evt)
    {
        let company = evt.target.value;
        this.company = company;
        // Old Dedupe method, to be removed
        // this.updateSearchKey(company);
    }

    @track
    email = '';
    @track
    doShowInvalidEmailError = false;

    handleEmailChange(evt)
    {
        this.doShowEmailOrMobileError = false;
        this.doShowInvalidEmailError = false;
        this.email = evt.target.value;
    }

    @track
    campaigns;
    @track
    campaign;

    handleCampaignChange(evt)
    {
        if (evt.target.value !== '- select -') {
            this.campaign = evt.target.value;
        }
        else {
            this.campaign = undefined;
        }
        console.log(this.campaign);
    }

    @track
    mobileNumber = '';
    @track
    doShowInvalidPhoneError = false;

    handleMobileChange(evt)
    {
        this.doShowEmailOrMobileError = false;
        this.doShowInvalidPhoneError = false;
        this.mobileNumber = evt.target.value;
    }

    @track
    leadSource;
    @track
    leadSources;
    @track
    doShowLeadSourceError = false;

    handleLeadSourceChange(evt)
    {
        if (evt.target.value !== '- select -') {
            this.leadSource = evt.target.value;
        }
        else {
            this.leadSource = undefined;
        }
        console.log(this.leadSource);
    }

    @track
    enquiryType;
    @track
    enquiryTypes;
    @track
    doShowEnquiryTypeError = false;

    handleEnquiryTypeChange(evt)
    {

        if (evt.target.value !== '- select -') {
            this.enquiryType = evt.target.value;
        }
        else {
            this.enquiryType = undefined;
        }
        console.log(this.enquiryType);
    }

    @track
    initialSalesType;
    @track
    initialSalesTypes;
    @track
    doShowInitialSalesTypeError = false;

    handleInitialSalesTypeChange(evt)
    {

        if (evt.target.value !== '- select -') {
            this.initialSalesType = evt.target.value;
        }
        else {
            this.initialSalesType = undefined;
        }
        console.log(this.initialSalesType);
    }


    @track
    isOpportunityQualified = false;

    handleOpportunityQualificationChange(evt)
    {
        console.log('>> handleOpportunityQualificationChange()');
        let isChecked = evt.target.checked;
        console.log('isChecked: ' + isChecked);
        this.isOpportunityQualified = isChecked;
        if (this.isOpportunityQualified)
        {
            this.setDefaultMilestone(MILESTONES_TEST_DRIVE);
        }
        else
        {
            this.setDefaultMilestone(MILESTONE_QUALIFICATION);
        }
        console.log('<< handleOpportunityQualificationChange()');
    }

    initPricebook()
    {
        console.log('>> initPricebook');
        GetPricebook()
            .then(result =>
            {
                if (result !== null && result.length > 0)
                {
                    this.pricebookId = result;
                }
            })
            .catch(error =>
            {
                console.log('Error: ' + JSON.stringify(error));
            });

        console.log('<< initPricebook');
    }

    async handleClick()
    {
        console.log('>> handleClick()');
        if (await this.validateUi())
        {
            console.log('UI entries are valid');
            this.createOpportunity();
        }
        else
        {
            console.log('UI is not valid');
        }
        console.log('<< handleClick()');
    }

    @track doShowSubmittingInProgress = false;

    createOpportunity()
    {
        console.log('>> createOpportunity()');
        let request = this.buildCreateOpportunityRequest();
        console.log('Request: ' + JSON.stringify(request));
        if (request !== undefined && request !== null)
        {
            this.doShowSubmittingInProgress = true;
            CreateOpportunity({
                request: request
            })

                .then(result =>
                {
                    console.log('result: ' + JSON.stringify(result));
                    if (result.Errors !== undefined && result.Errors.length > 0)
                    {
                        this.doShowSubmittingInProgress = false;
                        this.showErrorToastMsg(JSON.stringify(result.Errors));
                    }
                    this.navigateToRecordViewPage(result.OpportunityId);
                })

                .catch(error =>
                {
                    this.doShowSubmittingInProgress = false;
                    this.showErrorToastMsg(JSON.stringify(error));
                    console.log('error: ' + JSON.stringify(error));
                });
        }
        else
        {
            console.log('Request is null');
        }
        console.log('<< createOpportunity()');
    }

    buildCreateOpportunityRequest()
    {
        console.log('buildCreateOpportunityRequest()');
        try
        {
            let request = {};
            request.NameLast = this.lastName;
            request.NameFirst = this.firstName;
            request.Email = this.email;
            request.Company = this.company;
            request.AccountId = this.accountId;
            request.PhoneMobile = this.mobileNumber;
            request.LeadSource = this.leadSource;
            request.EnquiryType = this.enquiryType;
            request.InitialSalesType = this.initialSalesType;
            if (this.campaign !== undefined)
            {
                console.log('campaign: ' + JSON.stringify(this.campaign));
                request.CampaignId = this.campaign;
            }
            request.RelatedMilestoneId = this.relatedMilestone;
            request.RelatedMilestoneName = this.deriveMilestoneName(this.relatedMilestone);
            request.ActivityType = this.activityType;
            //Task
            request.DueDate = this.dueDate;

            //Event
            request.EventDateTimeStart = this.eventDateStart;
            request.EventDateTimeEnd = this.eventDateEnd;
            //no need to validate comments
            request.ActivityDescription = this.comments;
            request.IsOpportunityQualified = this.isOpportunityQualified;
            request.DoSetReminder = this.doSetReminder;

            request.PricebookId = this.pricebookId;
            request.ReminderDateTime = this.reminderDateTime;
            request.existingAccountId = this.duplicateAccountId;
            request.existingContactId = this.duplicateContactId;
            request.MakeId = this.selectedMake;
            request.ModelId = this.selectedModel;
            console.log('Request: ' + JSON.stringify(request));
            if (this.validateRequest(request))
            {
                console.log('request is valid');
                return request;
            }
            console.log('Invalid Request');
            this.showErrorToastMsg('Request is not valid');
            return null;
        }
        catch (err)
        {
            console.log(JSON.stringify(err));
            return null;
        }
    }

    validateRequest(request)
    {

        //validate date logic
        console.log('validate dates');
        if (this.doSetReminder !== undefined
            && this.doSetReminder
            && this.dueDate !== undefined
            && this.dueDate !== ''
            && this.reminderDateTime !== undefined
            && this.reminderDateTime !== ''
            && this.reminderDateTime > this.dueDate
        )
        {
            console.log('reminder is after due date');
            return false;
        }


        // Last Name
        console.log('validate nameLast');
        if (!this.validateString('NameLast', request.NameLast))
        {
            return false;
        }

        // First Name
        console.log('validate nameFirst');
        if (!this.validateString('NameFirst', request.NameFirst))
        {
            return false;
        }

        // Phone / email
        console.log('validate phone/email');
        if ((!this.validateString('PhoneMobile', request.PhoneMobile)) && (!this.validateString('Email', request.Email)))
        {
            return false;
        }

        // Related Milestone Id
        console.log('validate milestoneId');
        if (!this.validateString('RelatedMilestoneId', request.RelatedMilestoneId))
        {
            return false;
        }

        // Related Milestone Name
        console.log('validate milestoneName');
        if (!this.validateString('RelatedMilestoneName', request.RelatedMilestoneName))
        {
            return false;
        }

        // Lead Source
        console.log('validate leadSource');
        if (!this.validateString('LeadSource', request.LeadSource))
        {
            return false;
        }

        //Enquiry Type
        console.log('validate Enquiry Type');
        if (!this.validateString('EnquiryType', request.EnquiryType))
        {
            return false;
        }

        //Initial Sales Type
        console.log('validate Initial Sales Type');
        if (!this.validateString('InitialSalesType', request.InitialSalesType))
        {
            return false;
        }

        // Activity Type
        console.log('validate activityType');
        if ((request.ActivityType !== ACTIVITY_TYPES_EVENT) && (request.ActivityType !== ACTIVITY_TYPES_TASK))
        {
            console.log('ActivityType is not valid: ' + request.ActivityType);
            return false;
        }

        // Pricebook
        console.log('validate pricebook');
        if (!this.validateString('PricebookId', request.PricebookId))
        {
            console.log('PricebookId is not valid: ' + request.PricebookId);
        }

        // Reminder date
        console.log('validate reminderDate');
        if (request.DoSetReminder)
        {
            if (!this.validateString('ReminderDateTime', request.ReminderDateTime))
            {
                return false;
            }
        }

        // Task
        if (request.ActivityType === ACTIVITY_TYPES_TASK)
        {

            //Due Date
            console.log('validate dueDate');
            if (!this.validateString('DueDate', request.DueDate))
            {
                return false;
            }
        }

        // Event
        else if (request.ActivityType === ACTIVITY_TYPES_EVENT)
        {

            //Event Start
            console.log('validate eventStart');
            if (!this.validateString('EventDateTimeStart', request.EventDateTimeStart))
            {
                return false;
            }

            //Event End
            console.log('validate eventEnd');
            if (!this.validateString('EventDateTimeEnd', request.EventDateTimeEnd))
            {
                return false;
            }
        }

        // Something has gone wrong!
        else
        {
            console.log('ActivityType is invalid');
            return false;
        }

        //Everything is OK!
        console.log('Request seems to be valid');
        console.log('<< ValidateRequest()');
        return true;
    }

    validateString(propName, propVal)
    {
        console.log('>> validateString()');
        console.log('propName: ' + propName);
        console.log('propVal: ' + propVal);
        if (propVal === undefined || propVal === '')
        {
            console.log('Invalid Request Property: ' + propName);
            return false;
        }
        console.log(propName + ' is valid');
        return true;
    }

    async validateUi()
    {
        console.log('>> validateUiI()');
        let isValid = true;

        //reset errors
        this.doShowEmailOrMobileError = false;
        this.doShowLeadSourceError = false;
        this.doShowNameFirstError = false;
        this.doShowNameLastError = false;
        this.doShowInvalidEmailError = false;
        this.doShowInvalidPhoneError = false;
        this.doShowActivityTypeError = false;
        this.doShowReminderError = false;
        this.doShowEventStartError = false;
        this.doShowEventEndError = false;
        this.doShowDueDateError = false;
        this.doShowBadReminderDate = false;
        this.doShowEnquiryTypeError = false;
        this.doShowInitialSalesTypeError = false;

        //phone or mobile
        if (!this.email && !this.mobileNumber)
        {
            this.doShowEmailOrMobileError = true;
            isValid = false;
        }
        else
        {
            //invalid email
            if ((!RegExp(REGEX_EMAIL).test(this.email)) && this.email)
            {
                this.doShowInvalidEmailError = true;
                isValid = false;
            }

            //invalid phone
            //remove spaces
            if (this.mobileNumber)
            {
                this.mobileNumber = this.mobileNumber
                    .replace(' ', '')
                    .replace(' ', '')
                    .replace(' ', '');
            }


            if (!(await this.validationUtility.validatePhoneNumber(this.mobileNumber)) && this.mobileNumber)
            {
                this.doShowInvalidPhoneError = true;
                isValid = false;
            }

        }

        let inputMake = this.template.querySelector(".input-select-make");
        if (inputMake)
        {
            inputMake.errors = [];
            if (!this.selectedMake)
            {
                inputMake.errors = [{ id: "1", message: "Please Select a Make" }];
                isValid = false;
            }
        }

        let inputModel = this.template.querySelector(".input-select-model");
        if (inputModel)
        {
            inputModel.errors = [];
            if (!this.selectedModel)
            {
                inputModel.errors = [{ id: "1", message: "Please Select a Model" }];
                isValid = false;
            }
        }

        //Enquiry Type
        if (this.enquiryType === undefined)
        {
            this.doShowEnquiryTypeError = true;
            isValid = false;
        }

        //Initial Sales Type
        if (this.initialSalesType === undefined)
        {
            this.doShowInitialSalesTypeError = true;
            isValid = false;
        }

        //lead source
        if (this.leadSource === undefined)
        {
            this.doShowLeadSourceError = true;
            isValid = false;
        }

        //first name
        if (this.firstName === undefined || this.firstName === '')
        {
            this.doShowNameFirstError = true;
            isValid = false;
        }

        //last name
        if (this.lastName === undefined || this.lastName === '')
        {
            this.doShowNameLastError = true;
            isValid = false;
        }

        //activity type
        if (this.activityType === undefined)
        {
            this.doShowActivityTypeError = true;
            isValid = false;
        }
        else if (this.activityType === ACTIVITY_TYPES_TASK)
        {
            if (this.dueDate === undefined || this.dueDate === '')
            {
                this.doShowDueDateError = true;
                isValid = false;
            }
        }
        else if (this.activityType === ACTIVITY_TYPES_EVENT)
        {

            //event end
            if (this.eventDateEnd === undefined || this.eventDateEnd === '')
            {
                this.doShowEventEndError = true;
                isValid = false;
            }

            //event start
            if (this.eventDateStart === undefined || this.eventDateStart === '')
            {
                this.doShowEventStartError = true;
                isValid = false;
            }

        }

        //reminder date
        if (this.doSetReminder)
        {
            if (this.reminderDateTime === undefined || this.reminderDateTime === '')
            {
                this.doShowReminderError = true;
                isValid = false;
            }
        }

        if (this.doSetReminder !== undefined
            && this.doSetReminder
            && this.dueDate !== undefined
            && this.dueDate !== ''
            && this.reminderDateTime !== undefined
            && this.reminderDateTime !== ''
            && this.reminderDateTime > this.dueDate
        )
        {
            console.log('reminder is after due date');
            this.doShowBadReminderDate = true;
            isValid = false;
        }

        //activity
        console.log('return : ' + isValid);
        console.log('<< validateUiI()');
        return isValid;

    }

//Go To Record
    navigateToRecordViewPage(record)
    {
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

    resetSearchResults()
    {
        //contacts
        this.matchedContacts = undefined;
        this.matchedAccounts = undefined;
        this.doShowMatchedContacts = false;
        this.doShowSearchingInProgress = false;
    }

    //Search
    searchKey = '';

    @track doShowSearchingInProgress = false;

    doSearch()
    {
        console.log('>> doSearch()');
        console.log('SearchKey: ' + this.searchKey);

        //reset the search results
        this.resetSearchResults();

        if (this.searchKey !== undefined && this.searchKey !== '' && this.searchKey.length > 2)
        {
            this.doShowSearchingInProgress = true;

            SearchForAccounts({
                searchText: this.searchKey,
                searchType: 'customer'
            })

                .then(result =>
                {
                    console.log('Search Results: ' + JSON.stringify(result));
                    this.parseSearchResults(result);
                })

                .catch(error =>
                {
                    console.log('Errors: ' + JSON.stringify(error));
                });
        }
        console.log('<< doSearch()');

    }

    parseSearchResults(results)
    {
        console.log('>> parseSearchResults()');

        //hide spinner
        this.doShowSearchingInProgress = false;

        //accounts
        let accounts = results.resultAccountList;
        if (accounts !== undefined && accounts.length > 0)
        {
            //parse accounts
            this.parseAccounts(accounts);
        }

        //contacts
        let contacts = results.resultContactList;
        if (contacts !== undefined && contacts.length > 0)
        {
            this.parseContacts(contacts);
        }

        //assets
        let assets = results.resultAssetList;
        if (assets !== undefined)
        {
            //parse assets
            this.parseAssets(assets);
        }

        //opportunities
        let ops = results.resultOpportunityList;
        if (ops !== undefined)
        {
            //parse opportunities
            this.parseOpportunities(ops);
        }

        console.log('<< parseSearchResults()');
    }

    @track
    matchedContacts;
    @track
    doShowMatchedContacts = false;

    parseContacts(cons)
    {
        this.matchedContacts = [];
        for (let i = 0; i < cons.length; i++)
        {
            let con = cons[i];
            this.matchedContacts.push(con);
        }
        this.doShowMatchedContacts = true;
    }

    handleMatchedContactSelected(evt)
    {
        console.log('>> handleMatchedContactSelected()');
        console.log('matchedContact: ' + JSON.stringify(evt));
        let selectedContact = evt.detail;
        this.processSelectedMatch(selectedContact.Account.Id, selectedContact.Account.Name);
        console.log('<< handleMatchedContactSelected()');
    }

    @track matchedAccounts;
    @track doShowMatchedAccounts = false;

    parseAccounts(accounts)
    {
        this.matchedAccounts = [];
        for (let i = 0; i < accounts.length; i++)
        {
            let account = accounts[i];
            this.matchedAccounts.push(account);
        }
        this.doShowMatchedAccounts = true;
    }

    handleMatchedAccountSelected(evt)
    {
        console.log('>> handleMatchedAccountSelected()');
        let account = evt.detail;
        console.log('matchedAccount: ' + JSON.stringify(account));
        this.processSelectedMatch(account.Id, account.Name);
        console.log('<< handleMatchedAccountSelected()');
    }

    parseOpportunities(ops)
    {
        for (let i = 0; i < ops.length; i++)
        {
            let op = ops[i];

        }
    }

    @track doShowSelectedAccount = false;
    @track accountId;
    @track accountName;

    processSelectedMatch(accountId, accountName)
    {
        console.log('>> processSelectedMatch()');
        console.log('accountId: ' + accountId);
        console.log('accountName: ' + accountName);
        this.accountId = accountId;
        this.accountName = accountName;
        this.doShowSelectedAccount = true;
        this.doShowMatchedContacts = false;
        this.doShowMatchedAccounts = false;
        console.log('<< processSelectedMatch()');
    }

    parseAssets(assets)
    {
        //do nothing at the moment

    }


    // TODO: remove old deduplication methods from component (ask Grant on best method to do so).
    updateSearchKey(searchKey)
    {
        //console.log('>> updateSearchKey');
        this.searchKey = searchKey;
        // This method is debounced to avoid a very large number of apex calls, given
        // a delay of DELAY milliseconds.
        window.clearTimeout(this.delayTimeout);
        this.delayTimeout = setTimeout(() =>
        {
            this.doSearch();
        }, DELAY);

        //console.log('<< updateSearchKey');
    }

    //////////////////////////////////////////////////////////////////////
    // First Activity
    /////////////////////////////////////////////////////////////////////

    initActivityTypes()
    {
        let types = [];
        let task = {};
        task.Name = ACTIVITY_TYPES_TASK;
        task.Id = ACTIVITY_TYPES_TASK;
        types.push(task);
        let event = {};
        event.Name = ACTIVITY_TYPES_EVENT;
        event.Id = ACTIVITY_TYPES_EVENT;
        types.push(event);
        this.activityTypes = types;
    }

    @track activityTypes;
    @track activityType;
    @track doShowEventFields = false;
    @track doShowActivityTypeError = false;

    handleActivityTypeChange(evt)
    {
        console.log('>> handleActivityEventTypeChange')
        this.doShowActivityTypeError = false;
        let activityType = undefined;
        if (evt.target.value !== '- select -') {
            activityType = evt.target.value;
        }
        console.log('ActivityType: ' + activityType);
        this.activityType = activityType;
        this.doShowEventFields = this.activityType === 'Event';
        console.log('<< handleActivityEventTypeChange');
    }

    initMilestones(isQualified)
    {
        console.log('>> initMilestones()');
        console.log('isQualified: ' + isQualified);
        let milestones = [];
        let target = '';
        if (isQualified)
        {
            let tstDrv = this.buildMilestone('Test Drive', 'Test_Drive');
            tstDrv.IsDefaultSelection = true;
            milestones.push(tstDrv);
            target = tstDrv.Id;
        }
        else
        {
            let qual = this.buildMilestone('Qualification', 'Qualified');
            qual.IsDefaultSelection = true;
            milestones.push(qual);
            milestones.push(this.buildMilestone('Test Drive', 'Test_Drive'));
            target = qual.Id;
        }
        milestones.push(this.buildMilestone('Select Vehicle', 'Select Vehicle'));
        milestones.push(this.buildMilestone('Appraisal', 'Appraisal'));
        milestones.push(this.buildMilestone('Negotiation', 'Negotiation'));
        milestones.push(this.buildMilestone('Order Taken', 'Order_Taken'));
        milestones.push(this.buildMilestone('Handover & RDA', 'Handover_RDA'));
        this.relatedMilestones = milestones;
        this.relatedMilestone = target;
        console.log('<< initMilestones()');
    }

    buildMilestone(name, id)
    {
        let milestone = {};
        milestone.Name = name;
        milestone.Id = id;
        milestone.IsDefaultSelection = false;
        return milestone;
    }

    @track relatedMilestones;
    @track relatedMilestone;

    setDefaultMilestone(value)
    {
        console.log('>> setDefaultMilestone()');
        console.log('value: ' + value);

        if (value === MILESTONES_TEST_DRIVE)
        {
            this.initMilestones(true);
        }
        else
        {
            this.initMilestones(false);
        }


        for (let i = 0; i < this.relatedMilestones.length; i++)
        {
            //console.log('counter: ' + i);
            let ms = this.relatedMilestones[i];
            //console.log('ms.Id: ' + ms.Id);
            ms.IsDefaultSelection = ms.Id === value;
        }
        console.log('<< setDefaultMilestone()');
    }

    handleRelatedMilestoneChange(evt)
    {
        console.log('>> handleRelatedMilestoneChange()');
        let ms = evt.target.value !== '- select -' ? evt.target.value : undefined;
        console.log('value: ' + ms);
        this.relatedMilestone = ms;
        console.log('<< handleRelatedMilestoneChange()');
    }

    @track dueDate;
    @track doShowDueDateError = false;

    handleDueDateChange(evt)
    {
        let dueDate = evt.target.value;
        this.setReminderDate(dueDate + 'T00:00:00.000Z');
        console.log('Due Date: ' + dueDate);
        this.dueDate = dueDate;
    }

    setReminderDate(dt)
    {
        console.log('>> setReminderDate(' + dt + ')');
        //get the lightning-input
        let datePicker = this.template.querySelector('.input-reminder-date');
        if (datePicker !== undefined && datePicker !== null)
        {
            console.log('setting reminder date to : ' + dt);
            datePicker.value = dt;
            this.reminderDateTime = dt;
        }

        console.log('<< setReminderDate()');
    }

    @track eventDateStart;
    @track doShowEventStartError = false;

    handleEventDateStartChange(evt)
    {
        console.log('>> handleEventDateStart()');
        this.doShowEventStartError = false;
        let eventDateStart = evt.target.value;
        console.log('EventDateStart: ' + eventDateStart);
        this.eventDateStart = eventDateStart;
        this.setEventEnd(this.eventDateStart);
        console.log('<< handleEventDateStart()');
    }

    setEventEnd(dt)
    {
        console.log('>> setEventEnd');
        console.log('dt: ' + dt);
        //add 1 hour
        let endDt = new Date((new Date(dt)).getTime() + 60 * 60000);
        let endDatePicker = this.template.querySelector('.input-event-end');
        if (endDatePicker !== undefined && endDatePicker !== null)
        {
            console.log('Trying to set end date to : ' + endDt);
            endDatePicker.value = endDt.toISOString();
            this.eventDateEnd = endDt.toISOString();
        }
        console.log('<< setEventEnd');
    }

    @track eventDateEnd;
    @track doShowEventEndError = false;

    handleEventDateEndChange(evt)
    {
        console.log('>> handleEventDateEnd()');
        this.doShowEventEndError = false;
        let eventDateEnd = evt.target.value;
        console.log('EventDateEnd: ' + eventDateEnd);
        this.eventDateEnd = eventDateEnd;
        console.log('<< handleEventDateEnd()');
    }

    @track reminderDateTime;
    @track doShowReminderError = false;
    @track doShowBadReminderDate = false;

    handleReminderDateChange(evt)
    {
        console.log('>> handleReminderDateChange()');
        this.doShowReminderError = false;
        this.doShowBadReminderDate = false;
        let reminderDate = evt.target.value;
        console.log('Reminder Date: ' + reminderDate);
        this.reminderDateTime = reminderDate;
        console.log('<< handleReminderDateChange()');
    }

    @track doSetReminder = false;
    @track doShowReminder = false;

    handleDoSetReminderChange(evt)
    {
        console.log('>> handleDoSetReminderChange()');
        let isChecked = evt.target.checked;
        this.doSetReminder = isChecked;
        this.doShowReminder = this.doSetReminder;
        if (isChecked == false)
        {
            this.reminderDateTime = undefined;
        }
        console.log('isChecked: ' + isChecked);
        console.log('<< handleDoSetReminderChange()');
    }

    @track comments;

    handleCommentsChange(evt)
    {
        let comments = evt.target.value;
        console.log('Comments: ' + comments);
        this.comments = comments;
    }

    deriveMilestoneName(relatedMilestoneId)
    {
        console.log('>> deriveMilestoneName()');
        console.log('relatedMilestoneId: ' + relatedMilestoneId);
        for (let i = 0; i < this.relatedMilestones.length; i++)
        {
            let m = this.relatedMilestones[i];
            let mId = m.Id;
            console.log('comparing ' + mId + ' === ' + relatedMilestoneId);
            if (mId === relatedMilestoneId)
            {
                let nm = m.Name;
                console.log('return: ' + nm);
                console.log('<< deriveMilestoneName()');
                return nm;
            }
        }
        console.log('return: null');
        console.log('<< deriveMilestoneName()');
        return null;
    }


    // Deduplication Extension

    @track duplicateCheckActive = false;
    @track duplicateCheckComplete = false;
    @track duplicateAccountData = [];

    duplicateAccountId;
    duplicateContactId;

    async handleCheckForDuplicatesClicked()
    {

        var response = null;
        if (this.company)
        {
            let request = {
                AccountName: this.company,
                ContactNameFirst: this.firstName,
                ContactNameLast: this.lastName,
                ContactEmail: this.email,
                ContactPhoneMobile: this.mobileNumber
            };
            response = await getAccounts({request: request});
            console.log('getAccounts -> '+ JSON.stringify(response))
        }
        else
        {
            let request = {
                PersonNameFirst: this.firstName,
                PersonNameLast: this.lastName,
                PersonEmail: this.email,
                PersonPhoneMobile: this.mobileNumber
            };
            response = await getPersonAccounts({request: request});
            console.log('getPersonAccounts -> '+ JSON.stringify(response))
        }
        if (response.IsSuccess)
        {

            if (this.company)
            {
                if (response.Accounts.length !== 0)
                {
                    this.duplicateCheckActive = true;
                    this.duplicateAccountData = response;
                }
                else
                {
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Success',
                        message: 'No duplicates Found',
                        variant: 'success'
                    }));
                    this.duplicateCheckActive = false;
                    this.duplicateCheckComplete = true;
                }
            }
            else
            {
                if (response.PersonAccounts.length !== 0)
                {
                    this.duplicateCheckActive = true;
                    this.duplicateAccountData = {
                        IsSuccess: true,
                        Errors: null,
                        AdditionalResultsAvailable: null,
                        PersonAccounts: response.PersonAccounts.slice().sort((a, b) => a.MatchScore - b.MatchScore)
                    };
                }
                else
                {
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Success',
                        message: 'No duplicates Found',
                        variant: 'success'
                    }));
                    this.duplicateCheckActive = false;
                    this.duplicateCheckComplete = true;
                }
            }
        }
    }

    handleDuplicateCheckCancel()
    {
        this.duplicateCheckActive = false;
    }

    handleDuplicateCheckCreate(event)
    {
        this.duplicateCheckActive = false;
        this.duplicateAccountId = event.detail.accountId;
        this.duplicateContactId = event.detail.contactId;
        this.handlePrefillContactDetails(event.detail.contactEmail, event.detail.contactMobile, event.detail.accountName, event.detail.firstName, event.detail.lastName);
        this.duplicateCheckComplete = true;
        console.log('Duplicate check completed: ' + this.duplicateCheckComplete);
    }

    handlePrefillContactDetails(contactEmail, contactMobile, accountName, firstName, lastName)
    {
        console.log('Email: ' + contactEmail);
        console.log('Mobile: ' + contactMobile);
        console.log('accountName ' + accountName);
        console.log('firstName ' + firstName);
        console.log('lastName ' + lastName);

        if (!this.mobileNumber && contactMobile) {
            let mobileInput = this.template.querySelector('.input-phone-mobile');
            if (mobileInput) {
                mobileInput.value = contactMobile;
            }
            this.mobileNumber = contactMobile;
        }
        if (!this.email && contactEmail) {
            let emailInput = this.template.querySelector('.input-email');

            if (emailInput) {
                emailInput.value = contactEmail;
            }
            this.email = contactEmail;
        }
        if (this.company && accountName)
        {
            let accountNameInput = this.template.querySelector('.input-company');

            if (accountNameInput && accountName)
            {
                console.log('Setting Account Name input to ' + accountName);
                accountNameInput.value = accountName;
            }
            this.company = accountName;
        }
        let firstNameInput = this.template.querySelector('.input-first-name');

        if (firstNameInput && firstName)
        {
            console.log('Setting First Name input to ' + firstName);
            firstNameInput.value = firstName;
            this.firstName = firstName;
        }


        let lastNameInput = this.template.querySelector('.input-last-name');
        if (lastNameInput && lastName)
        {
            console.log('Setting Last Name input to ' + lastName);
            lastNameInput.value = lastName;
            this.lastName = lastName;
        }

    }

    //region Pre Populate
    async prePopulateContactInfoWithContactIdUrlParam()
    {
        const contactId = this.getUrlParam('contactId');
        if (contactId)
        {
            let request = { request: { ContactId: contactId } };
            console.log('GetContacts(' + JSON.stringify(request) + ')');
            let contactsDto = await GetContacts(request);
            console.log('GetContacts() = ' + JSON.stringify(contactsDto));
            if (contactsDto.Data.length != 1) this.showErrorToastMsg('No Contact Found To Prepopulate');

            let attributeDto = contactsDto.Data[0].Attributes;
            let mobileInput = this.template.querySelector('.input-phone-mobile');
            let emailInput = this.template.querySelector('.input-email');
            let companyInput = this.template.querySelector('.input-company');
            let firstNameInput = this.template.querySelector('.input-first-name');
            let lastNameInput = this.template.querySelector('.input-last-name');

            this.duplicateContactId = contactId;
            this.duplicateAccountId = attributeDto.AccountId;
            console.log('this.duplicateContactId = ' + this.duplicateContactId);
            console.log('this.duplicateAccountId = ' + this.duplicateAccountId);

            this.firstName = attributeDto.NameFirst;
            if (firstNameInput) firstNameInput.value = this.firstName;

            this.lastName = attributeDto.NameLast;
            if (lastNameInput) lastNameInput.value = this.lastName;

            this.email = attributeDto.Email;
            if (emailInput) emailInput.value = this.email;

            this.mobileNumber = attributeDto.PhoneMobile;
            if (mobileInput) mobileInput.value = this.mobileNumber;

            if (!attributeDto.IsPersonAccount)
            {
                this.company = attributeDto.NameCompany;
                if (companyInput) companyInput.value = this.company;
            }
            // because we are using an existing contact we do not need to perform the duplicate check
            this.duplicateCheckComplete = true;
        }

    }

    getUrlParam(key)
    {
        const url = window.location.href;
        return new URL(url).searchParams.get(key);
    }
    //endregion

    //region Make Model Selector
    @track makes;
    @track models;
    @track modelsUnfilterd;
    @track selectedMake;
    @track selectedModel;

    async setMakes()
    {
        console.log(">> setMakes()");
        let makesDtos = await GetMakes();

        console.log('makesResult: ' + JSON.stringify(makesDtos));

        this.makes = [];
        for (let i = 0; i < makesDtos.length; i++)
        {
            let make = {};
            make.Id = makesDtos[i].Id;
            make.Name = makesDtos[i].Name;
            this.makes.push(make);
        }
        console.log("<< setMakes()");
    }

    async setModels()
    {
        console.log(">> setModels()");

        let modelsDtos = this.modelsUnfilterd.filter(x => x.Make__c === this.selectedMake);

        console.log('modelsResult: ' + JSON.stringify(modelsDtos));

        this.models = [];
        for (let i = 0; i < modelsDtos.length; i++)
        {
            let model = {};
            model.Id = modelsDtos[i].Id;
            model.Name = modelsDtos[i].Name;
            this.models.push(model);
        }
        console.log("<< setModels()");
    }

    handelMakeChange(evt)
    {
        this.selectedMake = evt.detail !== '- select -' ? evt.detail : undefined;
        this.selectedModel = undefined;
        this.setModels();
        console.log("selectedMake = " + this.selectedMake);
    }

    handelModelChange(evt)
    {
        this.selectedModel = evt.detail !== '- select -' ? evt.detail : undefined;
        console.log("selectedModel = " + this.selectedModel);
    }
    //endregion
}