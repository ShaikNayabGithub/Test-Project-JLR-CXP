/**
 * Created by GrantMillgate-EasyTe on 20/09/2019.
 */

import {LightningElement, api} from 'lwc';

export default class FileManager extends LightningElement {
    @api recordId;

    connectedCallback()
    {
        if (this.recordId === undefined)
        {
            this.recordId = '0061l00000IGGKoAAP';
        }
    }

    get acceptedFormats() {
        return ['.pdf', '.png'];
    }

    handleUploadFinished(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        console.log(uploadedFiles);
        alert("No. of files uploaded : " + uploadedFiles.length);
    }
}