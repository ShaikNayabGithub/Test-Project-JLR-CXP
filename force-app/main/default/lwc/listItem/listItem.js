/**
 * Created by GrantMillgate-EasyTe on 14/08/2019.
 */

import {LightningElement,api} from 'lwc';

export default class ListItem extends LightningElement {

    @api item;

    handleClick(event) {
        // 1. Prevent default behavior of anchor tag click which is to navigate to the href url
        event.preventDefault();
        console.log('Click');
        console.log(this.item.Id);

        // Creates the event with the account ID data.
        const selectedEvent = new CustomEvent('itemselected', {
            detail: this.item
            //,  bubbles: true
        });

        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }
}