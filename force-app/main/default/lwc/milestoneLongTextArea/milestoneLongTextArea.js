/**
 * Created by caleb on 31/01/2020.
 */

import {api, track, LightningElement} from 'lwc';

export default class MilestoneLongTextArea extends LightningElement {
    @track _text;
    @api textAreaName;

    @api set text(val)
    {
        console.log('>> text(' + val + ')');
        let textArea = this.template.querySelector('.input-text');
        console.log(textArea);
        if (textArea !== undefined && textArea !== null)
        {
            textArea.value = val;
        }
        console.log('<< text()');
    }

    get text()
    {
        return this._text;
    }


    handleTextChange(evt)
    {
        console.log(">> handleCommentsChange()")
        this._text = evt.target.value;

        const selectedEvent = new CustomEvent('valuechange', {
            detail: this._text
        });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);

        console.log("<< handleCommentsChange()")
    }
}