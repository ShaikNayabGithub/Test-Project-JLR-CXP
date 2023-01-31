/**
 * Created by caleb on 30/01/2020.
 */

import {LightningElement, api} from 'lwc';

export default class MilestoneCheckbox extends LightningElement {
    @api checkboxName = "";
    @api isChecked = false;

    handleClick(evt){
        console.log('Click');
        this.isChecked = evt.target.checked;
        // Creates the event with the account ID data.
        const selectedEvent = new CustomEvent('valuechange', {
            detail: this.isChecked
        });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }

    renderedCallback()
    {
        console.log(">> renderedCallback()");
        let checkBox = this.template.querySelector('.input-check-box');
        checkBox.checked = this.isChecked;

        console.log("<< renderedCallback()");
    }
}