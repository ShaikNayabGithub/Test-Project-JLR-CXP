/**
 * Created by caleb on 30/01/2020.
 */

import {LightningElement, api} from 'lwc';

export default class MilestoneNavigation extends LightningElement {

    @api nextText = "Next";
    @api backText = "Back";
    @api alternateText;

    handelClickNext(evt)
    {
        console.log('Click ' + this.nextText);

        // Creates the event with the account ID data.
        const selectedEvent = new CustomEvent('nextclick', {
            detail: this.nextText
        });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }

    handelClickBack(evt)
    {
        console.log('Click ' + this.backText);

        // Creates the event with the account ID data.
        const selectedEvent = new CustomEvent('backclick', {
            detail: this.backText
        });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }

    handelClickAlternate(evt)
    {
        console.log('Click ' + this.alternateText);

        // Creates the event with the account ID data.
        const selectedEvent = new CustomEvent('alternateclick', {
            detail: this.alternateText
        });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }

}