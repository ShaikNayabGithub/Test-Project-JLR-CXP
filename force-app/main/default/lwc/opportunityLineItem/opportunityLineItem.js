/**
 * Created by GrantMillgate-EasyTe on 21/11/2019.
 */

import {LightningElement, api, track} from 'lwc';

export default class OpportunityLineItem extends LightningElement {

    @api product;

    handleClearProductItem(evt){
        const selectedEvent = new CustomEvent('opitemcleared', {
            detail: this.product
        });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }

}