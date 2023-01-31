/**
 * Created by Ethan Sargent on 3/3/20.
 */

import {LightningElement, api} from 'lwc';

export default class ClickableContactOppDedupe extends LightningElement
{

    @api contactId;
    @api accountId;
    @api accountName;
    @api contactName;
    @api contactFirstName;
    @api contactLastName;
    @api contactMobile;
    @api contactEmail;

    fireSelectionEvent()
    {
        this.dispatchEvent(new CustomEvent('customselection', {
            detail: {
                accountId: this.accountId,
                accountName: this.accountName,
                contactId: this.contactId,
                contactFirstName: this.contactFirstName,
                contactLastName: this.contactLastName,
                contactEmail: this.contactEmail,
                contactMobile: this.contactMobile
            }
        }))
    }
}