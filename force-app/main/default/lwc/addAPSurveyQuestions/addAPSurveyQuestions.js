import {  LightningElement, wire, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getObject from '@salesforce/apex/addAPSurveyQsController.getdata';

export default class AddQuestions extends LightningElement {
    @api recordId;
    @track showAddAnswers = false;
    @track surveyQrecID = null;
    @track tempQuestionID;
    @track isSurveyCreated = false;
    @track showCreateData = true;
    @track showcancel = false;
    @track showClose = true;
    @track wrapobj;
    @track sName;
    @track sType;
    @track showques = true;
    @track showanswers = false;
    @track isText = true;
   
    @wire(getObject, { qId: '$recordId' })
    wiredSessions({ error, data }) {
        if (data) {
            this.wrapobj = data;
            this.sType = data.strSurveyName;
            this.sName = data.strSurveyId;
        } else if (error) {
            this.wrapobj = null;
            throw new Error('Failed to retrieve data');
        }
    }

    handleSuccess(event) {
        this.showAddAnswers = true;
        let msg = this.surveyQrecID === null ? 'Question created successfully' : 'Question updated successfully';
        const toast = new ShowToastEvent({
            title: 'Success',
            message: msg,
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(toast);
        this.surveyQrecID = event.detail.id;
        this.isSurveyCreated = true;
        this.showCreateData = false;
        console.log('Event Details', event.detail.fields.Answer_Type__c.value)
        if(event.detail.fields.Answer_Type__c.value == 'Text'){
            this.isText = false;
        }else{
            this.isText = true;
        }
       
    }

    handleSubmit(event) {
        event.preventDefault();
        console.log('wrapper' + JSON.stringify(this.wrapobj));
        const fields = event.detail.fields;
        console.log('survey Question__c' + fields.Name);
        console.log('this.wrapobj.existingQuestion.length' + this.wrapobj.existingQuestion[0]);
        if (this.wrapobj.existingQuestion.length > 0) {
            for (let i = 0; i < this.wrapobj.existingQuestion.length; i++) {
                console.log('data' + this.wrapobj.existingQuestion[i]);
                if (fields.Name == this.wrapobj.existingQuestion[i]) {
                    const toast = new ShowToastEvent({
                        title: 'Error',
                        message: 'Question # '+fields.Name+' already exist for this Survey',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(toast);
                    return;
                }
            }
        }
        fields.AP_Survey__c = this.recordId;
        this.template.querySelector('lightning-record-edit-form').submit(fields);
        console.log('onsubmit event recordEditForm' + event.detail.fields);
    }

    handleSaveNew(event){
        this.showques = true;
        this.showanswers = false;
        this.showCreateData = true;
        this.isSurveyCreated = false;
        this.tempQuestionID = this.surveyQrecID;
        this.surveyQrecID = null;
        
    }

    handleChildCancel(event){
        this.showques = true;
        this.showanswers = false;
        this.showCreateData = false;
        this.isSurveyCreated = true;
        this.newMethod();
        
    }

    newMethod() {
        this.surveyQrecID = this.surveyQrecID;
    }

    handleEdit(event) {
        this.isSurveyCreated = false;
        this.showCreateData = true;
        this.showcancel = true;
        this.showClose = false;
        this.surveyQrecID = this.surveyQrecID;
    }
    handleCancel(event) {
        this.isSurveyCreated = true;
        this.showCreateData = false;
        this.surveyQrecID =  this.tempQuestionID;
    }

    handleClose() {
        const closeQA = new CustomEvent('close');
        this.dispatchEvent(closeQA);
    }

    handleAddAnswers(){
        console.log(this.surveyQrecID);
        this.showques = false;
        this.showanswers = true;
    }

}