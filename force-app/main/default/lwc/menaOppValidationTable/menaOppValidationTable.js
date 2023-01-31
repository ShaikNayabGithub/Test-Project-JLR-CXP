import { LightningElement, api, track, wire } from 'lwc';

import validator from '@salesforce/apex/HandovervalidatorController.validateHandover';
import Result from '@salesforce/label/c.Result';
import RDA_Description from '@salesforce/label/c.RDA_Description';
import Handovertype from '@salesforce/label/c.Handover_type_of';
import Errorloading from '@salesforce/label/c.Error_loading_from_SF';
import Successful_Validation from '@salesforce/label/c.Successful_Validation';
import NodataFound from '@salesforce/label/c.No_Data_Found';
import HandoverProcessed from '@salesforce/label/c.Handover_Processed';
import Refresh from '@salesforce/label/c.RDA_Refresh';
import { refreshApex } from '@salesforce/apex';
export default class MenaOppValidationTable extends LightningElement {
    Label = {
        RDA_Description,
        Result,
        Handovertype,
        Errorloading,
        NodataFound,
        Successful_Validation,
        HandoverProcessed,
        Refresh
    };
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
                console.log("No Existing Handover");
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
                this.rdaType = this.Label.HandoverProcessed;
                console.log("Found Bad processed" +this.HandoverProcessed);
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