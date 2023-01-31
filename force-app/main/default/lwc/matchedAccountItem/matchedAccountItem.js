/**
 * Created by GrantMillgate-EasyTe on 13/01/2020.
 */

import {LightningElement, track, api} from 'lwc';

export default class MatchedAccountItem extends LightningElement {
    @api account;

    handleClick(){
        console.log('>> handleClick()');
        const selectedEvent = new CustomEvent('matchedaccountselected', {
            detail: this.account
        });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
        console.log('<< handleClick()');
    }
}