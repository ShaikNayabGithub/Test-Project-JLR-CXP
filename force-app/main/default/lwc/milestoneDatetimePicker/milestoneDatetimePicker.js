/**
 * Created by caleb on 31/01/2020.
 */

import {LightningElement, api, track} from 'lwc';

export default class MilestoneDatetimePicker extends LightningElement {
    @api datePickerName;
    @api errors = [];
    @api dateTime;

    handleDateChange(evt)
    {
        console.log(">> handleDateChange()");
        this.dateTime = evt.target.value;

        const selectedEvent = new CustomEvent('valuechange', {
            detail: this.dateTime
        });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
        console.log(">> handleDateChange()");
    }

    renderedCallback()
    {
        console.log(">> renderedCallback()");
        this.setDatetime(this.dateTime);
        console.log("<< renderedCallback()");
    }

    connectedCallback()
    {
        console.log(">> connectedCallback()");
        console.log("datetime = " + this.dateTime);
        console.log("<< connectedCallback()");
    }

    @api
    setDatetime(val)
    {
        console.log('>> setDatetime(' + val + ')');
        let datePicker = this.template.querySelector('.input-datetime');
        console.log(datePicker);
        if (datePicker !== undefined && datePicker !== null)
        {
            datePicker.value = val;
        }
        this.dateTime = val;
        console.log('<< setDatetime()');
    }
}