/**
 * Created by Ethan Sargent on 17/2/20.
 */

import {LightningElement, api, track} from 'lwc';
import sendToMailjet from '@salesforce/apex/InvocableSmsController.SendToMailjet';
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import { FlowNavigationFinishEvent } from 'lightning/flowSupport';

export default class FlowScreenSmsSend extends LightningElement {
    @api
    get jsonData() {
        return this._jsonData;
    }
    set jsonData(value) {
        this._jsonData = JSON.parse(value);
    };
    @track _jsonData;

    smsBody;

    @track sendingSMS = false;
    @track smsTextSize = 0;

    handleSMSBodyChange(e)
    {
        this.smsBody = e.currentTarget.value;

        this.smsTextSize = this.smsBody.length;
    }

    handleSend(e)
    {

        if (!this.smsBody)
        {
            this.dispatchEvent(new ShowToastEvent(
                {
                title: 'Error',
                message: 'You must supply an SMS body before sending.',
                variant: 'error'
            }));
        }
        console.log(this.jsonData);
        let request = this.jsonData;
        request.Text = this.smsBody;
        console.log('sendToMailjet(' + JSON.stringify(request) + ')');
        this.sendingSMS = true;
        sendToMailjet({request: request})
            .then(result => {
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success',
                    message: 'SMS Successfully sent!',
                    variant: 'success'
                }));
                const finishEvent = new FlowNavigationFinishEvent();
                this.dispatchEvent(finishEvent);
            })
            .catch(error => {
                this.dispatchEvent(new ShowToastEvent(
                    {
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error'
                    }));
                console.log(JSON.stringify(error));
            })
    }
}