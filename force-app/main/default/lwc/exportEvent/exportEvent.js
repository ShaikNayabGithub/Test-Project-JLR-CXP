import { LightningElement, api } from 'lwc';
import {NavigationMixin} from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Downloadinvite from '@salesforce/apex/CalendarInvite.downloadinvite'
//delay to reload
const DELAY = 300;


export default class ExportEvent extends NavigationMixin(LightningElement) {
    
    @api recordId;

    connectedCallback(){
        this.DonwloadInvite();
    }

    DonwloadInvite(){
        //this.isButtonDisplayed = false;
        console.log('rec id in js :'+this.recordId);
        Downloadinvite({recordId : this.recordId})
        .then(result => {
            console.log('result is :'+result);
            console.log(typeof result);
            console.log( result instanceof Blob);
            // this.downloadBlob(new Blob(result));

             // Convert your blob into a Blob URL (a special url that points to an object in the browser's memory)
            const blobUrl = URL.createObjectURL(new Blob([result], {type: "text/html"}));

            // Create a link element
            const link = document.createElement("a");
        
            // Set link's href to point to the Blob URL
            link.href = blobUrl;
            link.download = "Event.ics";
        
            // Append link to the body
            document.body.appendChild(link);

            link.click();
            document.body.removeChild(link);

            this.handleSuccess();
        })
        .catch(error => {
            console.log('Error: ' + JSON.stringify(error));
        });
        
    }

    handleSuccess() {
        const evt = new ShowToastEvent({
            title: "Success!",
            message: "Event Download Initiated",
            variant: "success",
        });
        this.dispatchEvent(evt);

        this.delayTimeout = setTimeout(() => {
            this[NavigationMixin.Navigate]({
                type: "standard__recordPage",
                attributes: {
                   recordId: this.recordId,
                   objectApiName: "Event",
                   actionName: "view"
                }
             })
          }, DELAY) ;   

/*
        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
               recordId: this.recordId,
               objectApiName: "Event",
               actionName: "view"
            }
         });
         */
    }
}