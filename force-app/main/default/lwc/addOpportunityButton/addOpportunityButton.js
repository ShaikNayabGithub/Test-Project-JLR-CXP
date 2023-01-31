/**
 * Created by caleb on 23/03/2020.
 */

import {LightningElement, api, track} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import GetContact from '@salesforce/apex/ContactsController.getContacts';

export default class AddOpportunityButton extends NavigationMixin(LightningElement)
{
    @api
    contactId;

    @api
    personAccountId;

    @track
    showButton = false;

    async connectedCallback()
    {
        let request = { request: { ContactId: this.contactId, PersonAccountId: this.personAccountId } };
        let response = await GetContact(request);
        console.log('response = ' + JSON.stringify(response));
        if (response.Data.length === 1
            && (response.Data[0].Attributes.IsCorporateContact
            || response.Data[0].Attributes.IsPersonAccount))
        {
            this.showButton = true;
            this.contactId = response.Data[0].Id;
        }
    }


    handelButtonClick()
    {
        this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: '/new-opportunity?contactId=' + this.contactId
                }
            },
            false
        )
    }
}