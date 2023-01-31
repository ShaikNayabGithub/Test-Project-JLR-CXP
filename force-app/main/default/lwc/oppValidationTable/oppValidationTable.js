import { LightningElement, api, track, wire } from 'lwc';

import validator from '@salesforce/apex/RdaValidatorController.validateRDA';

import { refreshApex } from '@salesforce/apex';
export default class OppValidationTable extends LightningElement {
    @api
    recordId;
    @api getIdFromParent;
   wiredValidatorResults;
renderedCallback() {
    console.log(this.recordId);
}



@track _tableRefresh;
@api
get tableRefresh() {
  return this._tableRefresh;
}
set tableRefresh(value) {
  this._tableRefresh = value;
  this.refreshDataTable();
}

    @track existingRda;
    @track checkCount;
    @track rdaType;
    @track error;
    @track checkResults;
  @wire(validator, {oppId: '$getIdFromParent'})     
    wiredValidator(result){
       
       this.wiredValidatorResults = result;
       var tickExists = false;
        if(result.data){
            console.log("Data Obtained");
            this.existingRda = result.data.existingRda;
            tickExists = true;
            this.checkResults = result.data.rdaResults;
            if(!this.existingRda){
                console.log("No Existing RDA");
                this.rdaType = result.data.RdaType;
                this.error = undefined;
                if(this.checkResults && this.checkResults != null)
                {
                    for(var i = 0; i < this.checkResults.length ; i++){
                        console.log("Value: " + i + " " + this.checkResults[i].Pass);
                        if(!this.checkResults[i].Pass)
                        {
                            console.log("Found Bad Value");
                            tickExists = false;
                        }
                    }
                }
            }
            else
            {
                this.rdaType = 'RDA has been Processed';
            }
        } else if (result.error) {
            this.error = result.error;
            this.checkResults = undefined;
        }
        console.log(result);
        console.log(result.data);
        
        this.checkCount = tickExists;
        this.progress(tickExists);
        
    }

    progress(value){
        const custEvent = new CustomEvent(
            'calltickevent', {
                detail: value
            });
        this.dispatchEvent(custEvent);
    }

    refreshDataTable() {
        console.log("REFRESH TABLE!");
        refreshApex(this.wiredValidatorResults);      
  
    }
    
}