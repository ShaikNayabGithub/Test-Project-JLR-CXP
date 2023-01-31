/**
 * Created by caleb on 30/01/2020.
 */

import {LightningElement, api} from 'lwc';

export default class MilestoneDropDown extends LightningElement {
    @api options;
    @api placeholder;
    @api dropdownName;
    @api errors = [];

    handelSelectionChange(evt)
    {
        console.log(">> handelSelectionChange()")

        const selectedEvent = new CustomEvent('valuechange', {
            detail: evt.target.value
        });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);

        console.log("<< handelSelectionChange()")
    }

}