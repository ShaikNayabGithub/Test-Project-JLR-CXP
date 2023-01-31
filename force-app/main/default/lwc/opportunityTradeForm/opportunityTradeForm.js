import { LightningElement, track, api} from 'lwc'
import getMake from '@salesforce/apex/OpportunityTradeInController.getMakeFromModel';
import getVehicle from '@salesforce/apex/OpportunityTradeInController.getVehicleFromVin';
import updateTradeIn from '@salesforce/apex/OpportunityTradeInController.updateOpportunityTrade';
import getTradeIn from '@salesforce/apex/OpportunityTradeInController.getPredoneData';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class OpportunityTradeForm extends LightningElement {
  @track _recordId;
  @api
  get recordId() { return this._recordId;}
  set recordId(val)
  {
    if(val){
      this._recordId = val;
    }
    
    getTradeIn({idNum : this.recordId})
    .then(result =>
    {
      //console.log('REQUEST SENT PRESET VALUES');
        //console.log(JSON.stringify(result));
        //console.log(result);
        if (result != null)
        {
          if(result.TradeIn) //result.Make || result.Model || result.Mileage || result.Value || result.JlrTrade || result.modelYear || result.Service || result.Vin || result.TradeIn)
          {
            // BELOW TWO LINES ARE MOST LIKELY UNEEDED DUE TO CODE EXISTING INSIDE FIRST FUNCTION CALL.
            //let tradecheckbox =  this.template.querySelector('[data-id="tradecheckbox"]');
            //tradecheckbox.checked = true;
            this.toggleTradeVisibility(true);
            //console.log('REQUEST RECEIVED FOR PRESET VALUES: ' + JSON.stringify(result));

            // SETTING VALUES FROM RESULT
            this.makeValue = result.Make;
            this.modelValue = result.Model;
            this.mileageValue = result.Mileage;
            this.tradeValue = result.Value;

            // DETERMINING JLR TRADE VIABILITY, IF TRUE, SETS VALUES AND REVEALS SECONDARY FORM
            if(result.JlrTrade){
              let checkbox =  this.template.querySelector('[data-id="jlrcheckbox"]');
              checkbox.checked = true;
              this.toggleJlrVisibility(true);
              this.modelYear = result.ModelYear;
              // ABOVE LINE MIGHT NEED FUNCTION CALL IF NOT AUTO
            }
            else{
              this.modelYear = null;
            }
            if(result.Service)
            {
              //console.log(result.Service);
              this.serviceValue = result.Service;
            }
            this.vin = result.Vin;
            this.getVehicle();
          }

        }
    })
    .catch(error =>
    {
        //console.log('Error: ' + JSON.stringify(error));
    });
  }

  @track makeId;
  @track _makeValue;
  @api makeValue
  get makeValue() { return this._makeValue}
  set makeValue(value) {
    //console.log(value + ": MAKE VALUE");
    if(value){
      //console.log("MAKE VALUE CHANGED");
      this._makeValue = value;
    }
    else {
      this._makeValue = null;
      this.makeId = null;
    }
  }
  @track makeSoql = 'recordtype.name = \'Make\'';

  @track modelId;
  @track _modelValue;
  @api modelValue
  get modelValue() { return this._modelValue}
  set modelValue(value) {
    //console.log(value + ": MODEL VALUE");
    if(value){
      //console.log("MODEL VALUE CHANGED");
      this._modelValue = value;
    }
    else {
      this._modelValue = null;
      this.modelId = null;
    }
  }
  @track modelSoql = 'recordtype.name = \'Model\'';
  
  @track assetValue;

  @track tradeJlr = false;
  @track tradeIn = false;
  @track readOnly = false;

  @track _mileageValue;
  @api mileageValue
  get mileageValue() { return this._mileageValue}
  set mileageValue(value) {
    if(value){
      this._mileageValue = value;
    }
    else {
      this._mileageValue = null;
    }
  }
  
  updateMileageValue(event){
    this.mileageValue = event.target.value;
  }

  
  @track modelYear;
  handleYearChange(event) {
    this.modelYear = event.target.value;
  }

  @track _tradeValue;
  @api tradeValue
  get tradeValue() { return this._tradeValue}
  set tradeValue(val) {
    if(val){
      this._tradeValue = val;
    }
    else { 
      this._tradeValue = null;
    }
  }

  updateTradeValue(event) {
    this.tradeValue = event.target.value;
  }
  @track vin;
  handleVinChange(event) {
    //console.log('ON VIN CHANGE :' + event.target.value);
    this.vin = event.target.value;
    //console.log('VIN CHANGE: ' + this.vin);
    this.tryUpdateVin();
  }

  tryUpdateVin(){

    if(this.tradeJlr)
    {
      getVehicle({ID : this.vin})
      .then(result =>
      {
        //console.log('REQUEST SENT');
          //console.log(JSON.stringify(result));
          //console.log(result);
          if (result !== null)
          {
            //console.log('REQUEST RECEIVED: ' + result);
            this.assetValue = result.vehicleId;
            this.modelValue = result.modelId;
            this.makeValue = result.makeId;
            this.modelYear = result.modelYear;
          }
      })
      .catch(error =>
      {
          //console.log('Error: ' + JSON.stringify(error));
      });
    }
  }

  getVehicle(){
    if(this.tradeJlr)
    {
      getVehicle({ID : this.vin})
      .then(result =>
      {
        //console.log('REQUEST SENT');
          //console.log(JSON.stringify(result));
          //console.log(result);
          if (result !== null)
          {
            //console.log('REQUEST RECEIVED: ' + result);
            this.assetValue = result.vehicleId;
          }
      })
      .catch(error =>
      {
          //console.log('Error: ' + JSON.stringify(error));
      });
    }
  }

  @track _serviceValue = null;
  @api serviceValue
  get serviceValue() { return this._serviceValue}
  set serviceValue(val) {
    if(val)
    {
      this._serviceValue = val;
    }
    else
    {
      this._serviceValue = null;
    }
  }

  handleServiceChange(event) {
    //console.log(event.detail + ' SERVICEVALUECHANGE');
    this.serviceValue = event.detail;
  }

  CSS_CLASS_JLR_HIDDEN = 'jlr-hidden';

  handleMakeLookup (event) {
    this.makeId = event.detail;
    this.makeValue = this.makeId;
    if(this.makeId)
    {
      this.modelSoql = 'recordtype.name = \'Model\' AND make__c = \'' + this.makeId +'\'';
    }
    else
    {
      this.modelSoql = 'recordtype.name = \'Model\'';
    }
  }
  handleModelLookup (event) {
    this.modelId = event.detail;
    this.modelValue = this.modelId;
    if(this.modelId)
    {
      getMake({ID : this.modelId})
      .then(result =>
      {
          //console.log(JSON.stringify(result));
          //console.log(result);
          if (result !== null && result.length > 0)
          {
              this.makeValue = result;
          }
      })
      .catch(error =>
      {
          //console.log('Error: ' + JSON.stringify(error));
      });
    }
    else
    {
      this.makeValue = null;
    }
  }

  // Event to handle change to trade in Checkbox
  handleTradeIn(event) {
    //console.log('test123');
    this.toggleTradeVisibility(event.target.checked);
  }

  toggleTradeVisibility(value) 
  {
    let checkbox =  this.template.querySelector('[data-id="tradecheckbox"]');
    if(checkbox.checked != value)
    {
      checkbox.checked = true;
    }
    //console.log('Started');
    if(value){
      this.expandTradeForm();
      this.tradeIn = true;
    }
    else {
      
      this.tradeJlr = false;
      this.readOnly = false;

      this.clearAllValues();
      this.tradeIn = false;


      //console.log("Read only to false");
      this.hideTradeForm();
      //console.log("Hide trade form");
      this.hideJlrTradeForm();
      //console.log("Hide jlr form");

      this.updateOpportunity();

    }
  }

  // Event to handle change in JLR Checkbox
  handleJlrTradeIn(event) {
    this.toggleJlrVisibility(event.target.checked);
  }

  toggleJlrVisibility(value)
  {
    if(value){
      this.showJlrTradeForm();
      this.tradeJlr = true;
      this.readOnly = true;
      this.tryUpdateVin();
    }
    else {
      this.hideJlrTradeForm();
      this.clearAllValues();
      this.readOnly = false;
      this.tradeJlr = false;
      this.modelYear = null;
      this.assetValue = null;
    }
  }


  // FOLLOWING TWO FUNCTIONS TOGGLE THE VISIBILITY OF THE MAIN FORM
  hideTradeForm(){
    this.getTradeCheckbox().classList.add(this.CSS_CLASS_JLR_HIDDEN);
    this.getMainForm().classList.add(this.CSS_CLASS_JLR_HIDDEN);
  }

  expandTradeForm(){
    this.getTradeCheckbox().classList.remove(this.CSS_CLASS_JLR_HIDDEN);
    this.getMainForm().classList.remove(this.CSS_CLASS_JLR_HIDDEN);
  }

  // QUERIES MAIN FORM
  getMainForm() {
    return this.template.querySelector('.form-body');
  }

  getTradeCheckbox() {
    return this.template.querySelector('.jlr-trade-checkbox');
  }

  // FOLLOWING TWO FUNCTIONS TOGGLE THE VISIBILITY OF THE SECONDARY FORM
  hideJlrTradeForm() {
    this.getjlrTradeFormFirst().classList.add(this.CSS_CLASS_JLR_HIDDEN);
    this.getjlrTradeFormSecond().classList.add(this.CSS_CLASS_JLR_HIDDEN);
  }
  showJlrTradeForm() {
    this.getjlrTradeFormFirst().classList.remove(this.CSS_CLASS_JLR_HIDDEN);
    this.getjlrTradeFormSecond().classList.remove(this.CSS_CLASS_JLR_HIDDEN);
  }

  // QUERIES SECONDARY FORM
  getjlrTradeFormFirst() {
    return this.template.querySelector('.jlr-trade-item1');
  }
  getjlrTradeFormSecond() {
    return this.template.querySelector('.jlr-trade-item2');
  }

  updateOpportunity(){
      //console.log('TRADE IN BOOL: ' + this.tradeJlr);
      if(this.serviceValue != null || !this.tradeIn) 
      {
            
          updateTradeIn({
            ID: this.recordId,
            Mileage: this.mileageValue,
            Service: this.serviceValue,
            Value: this.tradeValue,
            makeId: this.makeValue,
            modelId: this.modelValue,
            regNum: this.vin,
            modelYear: this.modelYear,
            tradeIn: this.tradeIn,
            jlrTrade: this.tradeJlr
        })
        .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Record Is Updated',
                    variant: 'success',
                }),
            );
        })
        .catch(error => {
          //console.log(JSON.stringify(error) + "ERROR");
          //console.log("Model Id " + this.modelValue);
          //console.log("Make Id " + this.makeValue);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error on data save',
                    //message: error.message.body,
                    message: 'Record Update Failed : ' + error.body.message,
                    variant: 'error',
                }),
            );
        });
      }
      else
      {
        console.log('Dispatch Toast');
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Missing Data',
                //message: error.message.body,
                message: 'Service History must have a value',
                variant: 'error',
            }),
        );
      }
  }

  clearAllValues() {
      // CLEAR VALUES due to form being closed
      this.modelYear = null;
      this.mileageValue = null;
      this.serviceValue = null;
      this.tradeValue = null;
      this.modelValue = null;
      this.modelId = null;
      this.makeValue = null;
      this.makeId = null;
      this.vin = null;
      this.jlrTrade = false;
      let checkbox =  this.template.querySelector('[data-id="jlrcheckbox"]');
      checkbox.checked = false;
  }
}