/**
 * Created by caleb on 1/07/2021.
 */

import GetOpportunityContactMailingDetails from '@salesforce/apex/ActivitiesController.getOpportunityContactMailingDetails';
import {LightningElement, track, api} from 'lwc';
import {toastErrorOnFail} from 'c/common';
const REGEX_EMAIL = '(?:[a-z0-9!#$%&\'*+\/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&\'*+\/=?^_`{|}~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])';
const REGEX_PHONE = '^(?:\\+?(61))? ?(?:\\((?=.*\\)))?(0?[2-57-8])\\)? ?(\\d\\d(?:[- ](?=\\d{3})|(?!\\d\\d[- ]?\\d[- ]))\\d\\d[- ]?\\d[- ]?\\d{3})$';


export default class MilestoneUpdateAddress extends LightningElement
{
    @api email;
    @api mobilePhone;
    @api mailingStreet;
    @api mailingCity;
    @api mailingState;
    @api mailingPostCode;
    @api mailingCountry;

    @track willSendLetter = false;

    @track letterOptOut = false;

    @track addressIsInit = false;

    @api opportunityId;

    async connectedCallback() {
        let res = await toastErrorOnFail(GetOpportunityContactMailingDetails({opportunityId: this.opportunityId}));
        this.email = res.Email;
        this.mobilePhone = res.MobilePhone;
        this.mailingStreet = res.MailingStreet;
        this.mailingCity = res.MailingCity;
        this.mailingState = res.MailingState;
        this.mailingPostCode = res.MailingPostCode;
        this.mailingCountry = res.MailingCountry;
        this.willSendLetter = res.WillSendLetter;
        this.addressIsInit = true;
    }

    isInvalidAddress(str)
    {
        return !str || str.trim() === '' || (str.length < 3)
    }

    @api
    isValid()
    {
        let emailInput = this.template.querySelector('.input-email');
        let phoneInput = this.template.querySelector('.input-phone');
        let streetInput = this.template.querySelector('.input-street');
        let cityInput = this.template.querySelector('.input-city');
        let stateInput = this.template.querySelector('.input-state');
        let postCodeInput = this.template.querySelector('.input-postcode');
        let countryInput = this.template.querySelector('.input-country');

        emailInput.errors = [];
        phoneInput.errors = [];
        streetInput.errors = [];
        cityInput.errors = [];
        stateInput.errors = [];
        postCodeInput.errors = [];
        countryInput.errors = [];

        let isValid = true;

        console.log('regmatch = ' + RegExp(REGEX_EMAIL).test(this.email));
        if (!RegExp(REGEX_EMAIL).test(this.email))
        {
            emailInput.errors = [{ id: "1", message: "Email Address is invalid" }];
            isValid = false;
        }
        console.log('regmatch = ' + RegExp(REGEX_PHONE).test(this.mobilePhone));
        if (!RegExp(REGEX_PHONE).test(this.mobilePhone))
        {
            phoneInput.errors = [{ id: "1", message: "Phone number is invalid" }];
            isValid = false;
        }
        if (this.isInvalidAddress(this.mailingStreet) && !this.letterOptOut)
        {
            streetInput.errors = [{ id: "1", message: "Please Fill In Street (Must be non empty at least 3 characters)" }];
            isValid = false;
        }
        if (this.isInvalidAddress(this.mailingCity) && !this.letterOptOut)
        {
            cityInput.errors = [{ id: "1", message: "Please Fill In City (Must be non empty at least 3 characters)" }];
            isValid = false;
        }
        if (this.isInvalidAddress(this.mailingState) && !this.letterOptOut)
        {
            stateInput.errors = [{ id: "1", message: "Please Fill In State (Must be non empty at least 3 characters)" }];
            isValid = false;
        }
        if (this.isInvalidAddress(this.mailingPostCode) && !this.letterOptOut)
        {
            postCodeInput.errors = [{ id: "1", message: "Please Fill In PostCode (Must be non empty at least 3 characters)" }];
            isValid = false;
        }
        if (this.isInvalidAddress(this.mailingCountry) && !this.letterOptOut)
        {
            countryInput.errors = [{ id: "1", message: "Please Fill In Country (Must be non empty at least 3 characters)" }];
            isValid = false;
        }

        return isValid;
    }

    @api
    getAddressUpdate()
    {
        return {
            Email: this.email,
            MobilePhone: this.mobilePhone,
            MailingStreet: this.mailingStreet,
            MailingCity: this.mailingCity,
            MailingState: this.mailingState,
            MailingPostCode: this.mailingPostCode,
            MailingCountry: this.mailingCountry,
            LetterOptOut: this.letterOptOut
        }
    }

    handelEmailChange(evt)
    {
        this.email = evt.detail;
        console.log("email = " + this.email);
    }

    handelMobileChange(evt)
    {
        this.mobilePhone = evt.detail;
        console.log("mobilePhone = " + this.mobilePhone);
    }

    handelStreetChange(evt)
    {
        this.mailingStreet = evt.detail;
        console.log("mailingStreet = " + this.mailingStreet);
    }

    handelCityChange(evt)
    {
        this.mailingCity = evt.detail;
        console.log("mailingCity = " + this.mailingCity);
    }

    handelStateChange(evt)
    {
        this.mailingState = evt.detail;
        console.log("mailingState = " + this.mailingState);
    }

    handelPostCodeChange(evt)
    {
        this.mailingPostCode = evt.detail;
        console.log("mailingPostCode = " + this.mailingPostCode);
    }

    handelCountryChange(evt)
    {
        this.mailingCountry = evt.detail;
        console.log("mailingCountry = " + this.mailingCountry);
    }

    handelLetterOptOutChange(evt)
    {
        this.letterOptOut = evt.detail;
        console.log("letterOptOut = " + this.letterOptOut);
    }
}