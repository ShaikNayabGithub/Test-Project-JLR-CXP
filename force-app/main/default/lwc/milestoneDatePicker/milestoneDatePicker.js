/**
 * Created by caleb on 30/01/2020.
 */

import {LightningElement, api, track} from 'lwc';

export default class MilestoneDatePicker extends LightningElement {
    @api datePickerName;
    @api errors = [];
    @api date;

    handleDateChange(evt)
    {
        console.log(">> handleDateChange()");
        this.date = evt.target.value;

        const selectedEvent = new CustomEvent('valuechange', {
            detail: this.date
        });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
        console.log("<< handleDateChange()");
    }

    renderedCallback()
    {
        console.log(">> renderedCallback()");
        this.setDate(this.date);
        console.log("<< renderedCallback()");
    }

    @api
    setDate(val)
    {
        console.log('>> setDate(' + val + ')');
        let datePicker = this.template.querySelector('.input-date');
        console.log(datePicker);
        if (datePicker !== undefined && datePicker !== null)
        {
            datePicker.value = val;
        }
        this.date = val;
        console.log('<< setDate()');
    }

}