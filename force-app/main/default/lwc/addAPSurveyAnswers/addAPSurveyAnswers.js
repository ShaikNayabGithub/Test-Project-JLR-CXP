import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
const FIELDS = ['AP_Survey_Question__c.Answer_Type__c', 'AP_Survey_Question__c.Question_Type__c', 'AP_Survey_Question__c.Name', 'AP_Survey_Question__c.Burmese__c', 'AP_Survey_Question__c.Cambodian__c', 'AP_Survey_Question__c.Chinese__c', 'AP_Survey_Question__c.English__c', 'AP_Survey_Question__c.French__c', 'AP_Survey_Question__c.Laos__c', 'AP_Survey_Question__c.Mongolian__c', 'AP_Survey_Question__c.Thai__c', 'AP_Survey_Question__c.Vietnamese__c'];

export default class AddAnswers extends LightningElement {
    @api surveyqid;
    @track questionId = this.surveyqid;
    @track name;
    @track objData;
    Burmese_Question;
    Cambodian_Question;
    Chinese_Question;
    English_Question;
    French_Question;
    Laos_Question;
    Mongolian_Question;
    Thai_Question;
    Vietnamese_Question;
    @track Answer_Type;
    @track isStarRating = false;
    @track defDynamicrow;
    @track choiceLabel = 'Number of Choices';

    @wire(getRecord, { recordId: '$surveyqid', fields: FIELDS })
    wiredRecord({ error, data }) {
        if (error) {
            let message = 'Unknown error';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading questions',
                    message,
                    variant: 'error',
                }),
            );
        } else if (data) {
            this.objData = data;
            console.log(JSON.stringify(this.objData));
            this.name = this.objData.fields.Question_Type__c.value;
            this.Cambodian_Question = this.objData.fields.Cambodian__c.value;
            this.Chinese_Question = this.objData.fields.Chinese__c.value;
            this.English_Question = this.objData.fields.English__c.value;
            this.French_Question = this.objData.fields.French__c.value;
            this.Laos_Question = this.objData.fields.Laos__c.value;
            this.Mongolian_Question = this.objData.fields.Mongolian__c.value;
            this.Thai_Question = this.objData.fields.Thai__c.value;
            this.Vietnamese_Question = this.objData.fields.Vietnamese__c.value;
            this.Burmese_Question = this.objData.fields.Burmese__c.value;
            this.Answer_Type = this.objData.fields.Answer_Type__c.value;
            if(this.Answer_Type == 'Star Rating'){
                this.isStarRating = true;
                this.choiceLabel = 'Number of Stars'
            }
        }
    }

    @track itemList = [ { id: 1 }];

    handleApplyEng(event) {
       if(event.target.checked){
        
       }
    }

    handleAddDynamicRows(event){        
      if(event.keyCode == 13){
        this.itemList = [];
        for(let i = 1; i<= event.target.value; i++){
            var newItem = [{ id: i }];
            this.itemList = this.itemList.concat(newItem);
          }
      }              
    }

    handleSubmitAnswers(event) {
        var isVal = true;
        this.template.querySelectorAll('lightning-input-field').forEach(element => {
            isVal = isVal && element.reportValidity();
        });
        if (isVal) {
            const inputFields = this.template.querySelectorAll( 'lightning-input-field'  );
            if (inputFields) {
                inputFields.forEach(field => {
                    console.log(field.fieldName);
                    if(field.fieldName == 'Question__c')                    
                        field.value = this.surveyqid;
                 
                });
            }
            console.log(event.target.name);
            this.template.querySelectorAll('lightning-record-edit-form').forEach(element => {
                element.submit();
                if(event.target.name == 'save'){
                    this.itemList = [];                    
                }else{
                    const savevent = new CustomEvent("savenew");
                    this.dispatchEvent(savevent)
                }
                const toast = new ShowToastEvent({
                    title: 'Success',
                    message: 'Answers created successfully',
                    variant: 'success',
                    mode: 'dismissable'
                });
                this.dispatchEvent(toast);
            });
            
            
        } else {
           
        }
    }

     isEmpty(val){
        return (val === undefined || val == null || val.length <= 0) ? true : false;
    }

    handleCancelAnswers(){
        const childcancelvent = new CustomEvent("childcancel");
                    this.dispatchEvent(childcancelvent)
    }

}