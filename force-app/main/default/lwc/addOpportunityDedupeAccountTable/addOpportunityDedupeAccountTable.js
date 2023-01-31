/**
 * Created by Ethan Sargent on 2/3/20.
 */

import {LightningElement, api, track} from 'lwc';

const accountHeaderList = [
    'Account Name',
    'Contact Name',
    'Contact Email',
    'Contact Mobile',
    ''
];

export default class AddOpportunityDedupeAccountTable extends LightningElement
{

    @track accountHeaderList = accountHeaderList;
    @api accountData;

    //can't use null literal in template expressions so to send contactId = null this is annoyingly required.
    nullvar = null;

    handleContactSelection(e)
    {
        try
        {
            console.log(e);
            //console.log('contact Selected' + JSON.stringify(e));
            //console.log('contactId = ' + e.target.data.contactId + ', accountId = ' + event.currentTarget.data.accountId);
            this.dispatchEvent(new CustomEvent('contactselected', {
                detail: {
                    contactId: e.detail.contactId,
                    accountId: e.detail.accountId,
                    accountName: e.detail.accountName,
                    contactFirstName: e.detail.contactFirstName,
                    contactLastName: e.detail.contactLastName,
                    contactEmail: e.detail.contactEmail,
                    contactMobile: e.detail.contactMobile
                }
            }));
            console.log('Event dispatched')
        }
        catch (exc)
        {
            console.log('Error occurred somewhere');
            console.log(exc);
        }
    }

    handleNewContactSelection(e)
    {
        try
        {
            console.log(e);
            this.dispatchEvent(new CustomEvent('contactselected', {
                detail: {
                    contactId: null,
                    accountId: e.target.value
                }
            }));
            console.log('Event dispatched');
        }
        catch (exc)
        {
            console.log('Error occurred somewhere');
            console.log(exc);
        }
    }

}