/**
 * Created by Ethan Sargent on 13/2/20.
 */

import {api, LightningElement, track, wire} from 'lwc';
import getContacts from '@salesforce/apex/FlowContactSelectionController.getContacts'
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import {FlowAttributeChangeEvent, FlowNavigationNextEvent} from 'lightning/flowSupport';


const columns = [
    {label: 'First Name', fieldName: 'FirstName'},
    {label: 'Last Name', fieldName: 'LastName'},
    {label: 'Email', fieldName: 'Email', type: 'email'},
    {label: 'Mobile Phone', fieldName: 'MobilePhone', type: 'phone'}
];

export default class FlowContactSelection extends LightningElement
{
    @api contact;
    @api accountId;
    @api preselectedContactId;

    @track reloadScreen;

    @track columns = columns;

    @track contacts = [];
    @track selectedContacts = [];
    @track _selectedContacts = [];
    @track updateScreen;

    renderedCallback()
    {
        if (this.selectedContacts !== this._selectedContacts) {
            // updates screen after wire assignment
            this.selectedContacts = this._selectedContacts;
        }
    }

    @wire(getContacts, {accId: '$accountId'})
    setContacts(result)
    {
        if (result.data)
        {
            console.log('Data returned successfully: ' + JSON.stringify(result.data));

            this._selectedContacts = [this.preselectedContactId];
            console.log('selectedContacts = ' + this._selectedContacts);

            this.contacts = this.makePrimaryContactFirst(result.data);
            const attrChange = new FlowAttributeChangeEvent('contact', this.contacts[0]);
            this.dispatchEvent(attrChange);

            this.reloadScreen = this.reloadScreen + 'a';
        }
        else if (result.error)
        {
            console.log('An error occurred: ' + JSON.stringify(result.error));
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'An error occurred when trying to display contacts. Please contact your Salesforce' +
                    ' Administrator for more details',
                variant: 'error'
            }));
        }

    }

    handleContactRowSelection(event)
    {
        let selectedRows = event.detail.selectedRows;
        console.log('Contact Selected: ' + JSON.stringify(selectedRows));
        const attrChange = new FlowAttributeChangeEvent('contact', selectedRows[0]);
        this.dispatchEvent(attrChange);
        console.log('Attribute change event fired');
    }

    handleCreateNewContact(e)
    {
        this.contactId = null;
        const attrChange = new FlowAttributeChangeEvent('contact', null);
        this.dispatchEvent(attrChange);
        const finishEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(finishEvent);
        console.log('Contact deselected in backend.');
    }

    makePrimaryContactFirst(contactsList = [])
    {
        // excluding 0 as we do not want to assign contactsList[0] to contactsList[0]
        if (contactsList.length === 0) {
            this.reloadScreen += 'a';
        }
        for (let i = 1; i < contactsList.length; i++)
        {
            if (contactsList[i].Id === this.preselectedContactId) {
                let tmp = contactsList[i];
                contactsList[i] = contactsList[0];
                contactsList[0] = tmp;
                break;
            }
        }

        return contactsList;
    }
}