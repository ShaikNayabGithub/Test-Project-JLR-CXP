import { LightningElement,wire, api } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { getRecord } from 'lightning/uiRecordApi';
import HandleGoodwillApprovalKorea from '@salesforce/apex/CaseGoodwillApprovalHandler.HandleGoodwillApprovalKorea';
import GoodwillButtonStatusKorea from '@salesforce/apex/CaseGoodwillApprovalHandler.GoodwillButtonStatusKorea';
import Goodwill__c from '@salesforce/schema/Case.Goodwill__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import hasSubmitApproval from '@salesforce/customPermission/KR_Case_Submit_for_Approval_button';



export default class CaseGoodwillButton extends LightningElement {

    @api recordId;
    showButton = false;

    @wire(getRecord, { recordId: '$recordId', fields: [Goodwill__c] })
    wiredGoodwill({ error, data }) {
        if (data) {
            this.error = undefined;
            console.log('  data --> ' + JSON.stringify(data) + ' error -->  ' + JSON.stringify(error) );
            console.log ('value is'+ data.fields.Goodwill__c.value );
            if (data.fields.Goodwill__c.value == 'Yes'&& hasSubmitApproval == true) {
                this.showButton = true;        
            }
       
        } else if (error) {
            this.error = error;
            this.record = undefined;
        }
    }
    

    handleGoodwillApproval(event) {
        console.log('recordId');
        console.log(this.recordId);
        console.log('has permission on submit approval');
        console.log(hasSubmitApproval);

        HandleGoodwillApprovalKorea({caseId: this.recordId})
        .then(result => {
          const evt = new ShowToastEvent({
              title: 'Success - Need to convert to Korean language',
              message: 'Sent for Approval - Need to convert to Korean language ',
              variant: 'success'
          });
          this.dispatchEvent(evt);
        })
        .catch((error) => {
            console.log('Fail for now');

            console.log(error);
            const evt = new ShowToastEvent({
              title: 'Error (Pending Korean Message)',
              message: 'Please let a member of staff know (Pending Korean Message)',
              variant: 'error'
          });
          this.dispatchEvent(evt);
        })

    }


        //get data on goodwill if it is yes or no
/*     @wire(GoodwillButtonStatusKorea({ 
        Id : this.recordId }))
    loadRetailerData({error, data}) {
        if(error) {
            console.log('error loading goodwill yes or no');
            console.log(error);
        }
        if(data) {
            const output = JSON.parse(data);
            console.log ('goodwill data from apex')
            console.log(output)
            try {
                showButton = output.showButton;
            } catch (error) {
                // do nothing
            }
            
        }
    } */
}