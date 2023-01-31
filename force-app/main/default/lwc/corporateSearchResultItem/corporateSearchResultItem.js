/**
 * Created by GrantMillgate-EasyTe on 28/11/2019.
 */

import {LightningElement, api, track} from 'lwc';

export default class CorporateSearchResultItem extends LightningElement {
@api item;

    handleClick(){
        const selectedEvent = new CustomEvent('corporateaccountselected', {
            detail: this.item
        });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }
}