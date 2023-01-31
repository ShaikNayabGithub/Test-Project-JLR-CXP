/**
 * Created by GrantMillgate-EasyTe on 13/01/2020.
 */

import {LightningElement, track, api} from 'lwc';

export default class MatchedContactItem extends LightningElement {
    @api contact;

    handleClick(){
        console.log('>> handleClick()');
            const selectedEvent = new CustomEvent('matchedcontactselected', {
                detail: this.contact
            });
            // Dispatches the event.
            this.dispatchEvent(selectedEvent);
        console.log('<< handleClick()');
    }
}