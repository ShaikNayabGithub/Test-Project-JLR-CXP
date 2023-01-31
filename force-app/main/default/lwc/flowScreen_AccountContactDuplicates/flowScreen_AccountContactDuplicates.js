/**
 * Created by Ethan Sargent on 26/3/20.
 */

import {LightningElement, api, track, wire} from 'lwc';
import getAccounts from '@salesforce/apex/OpportunityMatchController.getAccounts'
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import {FlowAttributeChangeEvent, FlowNavigationNextEvent} from 'lightning/flowSupport';

export default class FlowScreenAccountContactDuplicates extends LightningElement
{
    @api account;
    @api selectedAccount = null;
    @api selectedContact = null;
    @api companyName;

    @track accountData;

    connectedCallback()
    {
        this.fetchAccounts();
    }

    async fetchAccounts() {
        let request = { request: {
                AccountName: this.companyName,
                ContactNameFirst: this.account.FirstName,
                ContactNameLast: this.account.LastName,
                ContactEmail: this.account.ContactEmail,
                ContactPhoneMobile: this.account.ContactPhoneMobile
            }
        };
        console.log('request: ' + JSON.stringify(request));
        let response = await getAccounts(request);
        console.log('getAccounts -> Result = ' + JSON.stringify(response));
        if (response.IsSuccess) {
            if (response.Accounts.length === 0) {
                const accountChange = new FlowAttributeChangeEvent('selectedAccount', null);
                this.dispatchEvent(accountChange);
                const contactChange = new FlowAttributeChangeEvent('selectedContact', null);
                this.dispatchEvent(contactChange);
                const nextEvent = new FlowNavigationNextEvent();

                this.dispatchEvent(nextEvent);
            }
        } else {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'An error occurred when trying to retrieve duplicate records. Please contact your Salesforce' +
                    ' Administrator for more details',
                variant: 'error'
            }));
        }
        this.accountData = response;

    }

    handleContactSelected (e)
    {
        this.selectedContact = e.detail.contactId;
        this.selectedAccount = e.detail.accountId;

        const accountChange = new FlowAttributeChangeEvent('selectedAccount', this.selectedAccount);
        this.dispatchEvent(accountChange);
        const contactChange = new FlowAttributeChangeEvent('selectedContact', this.selectedContact);
        this.dispatchEvent(contactChange);

        console.log('selectedAccount = ' + this.selectedAccount);
        console.log('selectedContact = ' + this.selectedContact);
        this.accountData.Accounts.forEach(account => {
            this.updateCompanyNameAttribute(account);
        });

        const nextPageEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(nextPageEvent);
    }

    updateCompanyNameAttribute(account)
    {
        console.log('accountId =' + account.Id + ' selectedAccountId =' + this.selectedAccount);
        if (account.Id === this.selectedAccount)
        {
            console.log('changing companyName to: ' + account.accountName);
            const companyNameChange = new FlowAttributeChangeEvent('companyName', account.AccountName);
            this.dispatchEvent(companyNameChange);
        }
    }

    createNewHandler ()
    {
        this.selectedAccount = null;
        this.selectedContact = null;
        const accountChange = new FlowAttributeChangeEvent('selectedAccount', null);
        const contactChange = new FlowAttributeChangeEvent('selectedContact', null);
        this.dispatchEvent(accountChange);
        this.dispatchEvent(contactChange);
    }
}