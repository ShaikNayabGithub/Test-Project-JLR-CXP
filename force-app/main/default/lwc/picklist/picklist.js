import {LightningElement, api, track, wire} from 'lwc';
import {getPicklistValues, getObjectInfo} from 'lightning/uiObjectInfoApi';

export default class Picklist extends LightningElement {
    @api objAPIName;
    @api fieldAPIName;
    @track options = [];
    // pick list label
    @track picklistlabel;
    @track _value;
    @api
    get value() { return this._value;}
    set value(val) {
        if(val)
        {
            console.log('SETTING VALUE: ' + val);
            this._value = val;
        }
        else
        {
            this._value = null;
        }
    }

    @track error;

    recordTypeId;
    objfieldAPIName;

    @wire(getObjectInfo, {objectApiName: '$objAPIName'})
    objectInfo(result) {
        if(result.data) {
            // Field Data
            let fieldData = result.data.fields[this.fieldAPIName];
            if(fieldData) {
                this.picklistlabel = fieldData.label;
            
                this.objfieldAPIName = {};
                this.objfieldAPIName.fieldApiName = fieldData.apiName;
                this.objfieldAPIName.objectApiName = result.data.apiName;
    
                this.recordTypeId = result.data.defaultRecordTypeId;
            }
            else {
                this.error = 'Please enter valid field api name';
            }
        }
        else if(result.error) {
            this.error = JSON.stringify(result.error);
        }
    }
    
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: '$objfieldAPIName'})
    picklistValues({error, data}) {
        if (data) {

            let picklistOptions = [{ label: '--None--', value: '--None--'}];

            // Picklist values
            data.values.forEach(key => {
                picklistOptions.push({
                    label: key.label, 
                    value: key.value
                })
            });
            
            this.options = picklistOptions.slice(1);

        } else if (error) {
            this.error = JSON.stringify(error);
        }
    }


    handleValueChange(event) {
        this.value = event.target.value;
        console.log(this.value);
        if(this.value == '--None--')
        {
            const selected = new CustomEvent('selected', {
            detail: null
          })
          this.dispatchEvent(selected)
        }
        else
        {
            const selected = new CustomEvent('selected', {
            detail: this.value
          })
          this.dispatchEvent(selected)

        }
    }
}