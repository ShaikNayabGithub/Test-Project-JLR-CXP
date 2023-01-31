/**
 * Created by caleb on 25/06/2021.
 */

import {api, LightningElement} from 'lwc';

export default class MilestoneTextInput extends LightningElement
{
    @api textInputName;
    @api errors = [];
    @api text;
    @api helpText;

    handleTextChange(evt)
    {
        console.log(">> handleTextChange()");
        this.text = evt.target.value;

        const selectedEvent = new CustomEvent('valuechange', {
            detail: this.text
        });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
        console.log("<< handleTextChange()");
    }

    renderedCallback()
    {
        console.log(">> renderedCallback()");
        this.setText(this.text);
        console.log("<< renderedCallback()");
    }

    @api
    setText(val)
    {
        console.log('>> setText(' + val + ')');
        let datePicker = this.template.querySelector('.input-date');
        console.log(datePicker);
        if (datePicker !== undefined && datePicker !== null)
        {
            datePicker.value = val;
        }
        this.text = val;
        console.log('<< setText()');
    }
}