/**
 * Created by caleb on 30/01/2020.
 */

import {api, track, LightningElement} from 'lwc';

export default class MilestoneRadioButtonGroup extends LightningElement {

    @api radioGroupName;
    @api options;
    @api selectedValue;

    handleValueChange(evt) {
        this.selectedValue = evt.target.value;

        const selectedEvent = new CustomEvent('valuechange', {
            detail: this.selectedValue
        });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }

    renderedCallback()
    {
        console.log(">> renderedCallback()");
        console.log("selectedValue = " + this.selectedValue);
        let radioGroup = this.template.querySelector('.input-group');
        radioGroup.value = this.selectedValue;
        console.log("<< renderedCallback()");
    }
}