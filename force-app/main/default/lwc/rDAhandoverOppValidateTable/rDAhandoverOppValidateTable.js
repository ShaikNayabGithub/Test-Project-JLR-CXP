/**
 * Created by Grant Millgate - Argo Logic | grant@argologic.com.au on 16/10/2019.
 */

 import { LightningElement, wire, track, api } from 'lwc';
 import { getRecord } from 'lightning/uiRecordApi';
 // importing Custom Label
import Utilities from '@salesforce/label/c.UTILITIES';
import UsedLabel from '@salesforce/label/c.Used';
import NewLabel from '@salesforce/label/c.New';
import CheckHandover from '@salesforce/label/c.CHECK_READY_FOR_HANDOVER';

 import Countrycodelabel from '@salesforce/label/c.RDAHandoverCountryCodes';
 import USER_ID from '@salesforce/user/Id'; 
 import HideLightningHeader from '@salesforce/resourceUrl/HideLightningHeader';
 import {loadStyle, loadScript} from 'lightning/platformResourceLoader';
 import GetOpportunityData from '@salesforce/apex/OpportunitiesController.getOpportunityData';
 import UpdateOpportunity from '@salesforce/apex/OpportunitiesController.updateOpportunity';
 import DeleteOpportunityProduct from '@salesforce/apex/OpportunitiesController.deleteOpportunityProduct';
 import GetOpportunityProducts from '@salesforce/apex/OpportunityLineItemsController.get';
 import GetServicePlan from '@salesforce/apex/ServicePlanController.getServicePlan';
 import SetAsset from '@salesforce/apex/OpportunitiesController.setAsset';
 import SetVariant from '@salesforce/apex/OpportunitiesController.setVariant';
 import GetMilestoneOpportunityInfo from '@salesforce/apex/OpportunitiesController.GetMilestoneOpportunityInfo';
 import DeleteAllOpportunityProducts from '@salesforce/apex/OpportunityLineItemsController.deleteAll';
 import SetAssetWithMultiAssignCheck from '@salesforce/apex/AssetsController.SetAssetWithMultiAssignCheck'
 import SetAssetForced from '@salesforce/apex/AssetsController.SetAssetForced'
 import {NavigationMixin} from "lightning/navigation";
 import {ShowToastEvent} from "lightning/platformShowToastEvent";
 import {toastErrorOnFail} from 'c/common';
 
 // MESSAGE SERVICE IMPORTS
 //import { publish, MessageContext } from 'lightning/messageService';
 //import MessageChannel from '@salesforce/messageChannel/ValidatorMessageChannel__c';
 
 const SELECTED_SALE_TYPE_CLASS = 'jlr-button-cell-inverse-colours';
 const SALE_TYPES_NEW = 'new';
 const SALE_TYPES_DEMO = 'demo';
 
 const SERVICE_PLAN_TYPE_CORPORATE = 'Corporate';
 const SERVICE_PLAN_TYPE_COMPLIMENTARY = 'Complimentary';
 
 //const SALE_TYPES_APO = 'apo';
 const SALE_TYPES_PRE_OWNED = 'pre-owned';
 const PICKLIST_VAL_SALE_TYPE_NEW = 'New';
 const PICKLIST_VAL_SALE_TYPE_DEMONSTRATOR = 'Demonstrator';
 const PICKLIST_VAL_SALE_TYPE_PRE_OWNED = 'Pre_Owned';
 //const PICKLIST_VAL_SALE_TYPE_APPROVED_PRE_OWNED = 'Approved_Pre_Owned';
 
 export default class RDAhandoverOppValidateTable extends NavigationMixin(LightningElement) {
 labelCode = {
        Utilities,
        UsedLabel,
        NewLabel,
        CheckHandover
        
    };
     renderedCallback() {
         console.log('>> opportunitySpa.renderedCallback()');
         console.log('<< opportunitySpa.renderedCallback()');
     }
 
     @api recordId;
     @track Isvisible = false;
     @track isSelected_currentOpportunity = false;
     @track isSelected_relatedInformation = false;
     @track isSelected_allActivities = false;
     @track opportunityId;
     @track opportunityName;
     @track opportunityStage;
     @track nameLast;
     @track products;
     @track errorMessages;
     @track corporatePartner;
     @track enquiryType;
     @track leadSource;
     @track isPersonAccount;
     @track primaryContactName;
     @track primaryContactId;
     @track isClosed;
     @track hasBeenRdad;
     @track rdaId;
     @track rdaName;
     @track label= [];
    label = Countrycodelabel.split(',');  
 
 
 
     //Contact
     @track contactPhoneMobile;
     @track contactEmail;
 
     //Account
     @track accountId;
     @track accountName;
     @track pricebook2id;
      isExDemo=true;
 
     // using wire service getting current user data
     @wire(getRecord, { recordId: USER_ID, fields: ['user.Country_ISO_Code__c' ,'User.IsActive'] })
     userData({error, data}) {
         if(data) {
             window.console.log('data ====> '+JSON.stringify(data));            
             let objCurrentData = data.fields;
 
             this.objUser = {
                 CountryCode : objCurrentData.Country_ISO_Code__c.value,
                 IsActive : objCurrentData.IsActive.value,
             }
             console.log('CountryCode ! :'+ objCurrentData.Country_ISO_Code__c.value);
             if(this.label.includes(this.objUser.CountryCode)){
             this.Isvisible =true;
             }
         } 
         else if(error) {
             window.console.log('error ====> '+JSON.stringify(error))
         } 
     }
     
     // RDA Validator
     @track tickBoolValue = false;
     tickEvent(event){
         console.log("TICKBOOLVALUE! : " + event.detail);
         this.tickBoolValue = event.detail;
     }
 
     @track corporateEligibilityEnabled;
     @track corporateEligibilityMessage;
 
     // MESSAGING SERVICE WIRE
     // @wire(MessageContext)
     // messageContext;
 
     // // SEND MESSAGE FOR SERVICE
     // sendMessage(){
     //     console.log('Sent Message');
     //     const message ={
     //         message: 'HANDOVER CHECKED'
     //     };
     //     publish(this.messageContext, MessageChannel, message);
     // }
 
     // BOOLEAN VALUE, TOGGLE THE VALUE BETWEEN TRUE / FALSE AND THE VALIDATION TABLE WILL RESET. TABLE REFRESH
     @track validationTableRefresh = true;
 
     showCreateActivityModal = false;
 
     handleAccountNameClick() {
         this[NavigationMixin.Navigate]({
             type: "standard__recordPage",
             attributes: {
                 recordId: this.accountId,
                 objectApiName: "Account",
                 actionName: "view"
             }
         });
     }
 
     handelContactNameClick()
     {
         this[NavigationMixin.Navigate]({
             type: "standard__recordPage",
             attributes: {
                 recordId: this.primaryContactId,
                 objectApiName: "Contact",
                 actionName: "view"
             }
         });
     }
 
 
     @track selectedSaleType;
     @track selectedProductDescription;
     @track selectedProductModel;
     @track selectedProductBrand;
     @track selectedProductTrim;
     @track selectedProductName;
     @track selectedProductEngine;
     @track selectedProductModelYear;
     @track selectedProductServicePlan;
     @track selectedProductServicePlanType;
     @track selectedMakeId;
     @track selectedModelId;
     @track doShowAssetSelector = true;
 
     get mailToLink() {
         return "mailto:" + this.contactEmail;
     }
 
     get hasExistingOrComplimentaryServicePlan()
     {
         return this.selectedProductServicePlanType === 'Existing' || this.selectedProductServicePlanType === SERVICE_PLAN_TYPE_COMPLIMENTARY;
     }
 
     get doShowPlanSelector() {
         return this.selectedVariantId !== undefined && this.selectedProductServicePlanType !== SERVICE_PLAN_TYPE_COMPLIMENTARY && this.selectedProductServicePlanType !== SERVICE_PLAN_TYPE_CORPORATE && this.selectedProductServicePlanType !== 'Existing';
     }
 
     async connectedCallback() {
         console.log('isExDemo'+this.isExDemo);
         
         console.log('>> OpportunitySpa.connectedCallback');
         loadStyle(this, HideLightningHeader);
         if (this.recordId !== undefined) {
             this.clearAsset()
             this.handleCurrentOpportunityClick();
             //this.getOpportunity();
             await this.getOpportunity2();
 
             let assetSelector = this.template.querySelector('c-asset-selector');
             if (assetSelector)
             {
                 assetSelector.variantId = this.selectedVariantId;
             }
 
             this.setChildComponentComplexObject(this.selectedVariantComplex);
         }
         console.log('<< OpportunitySpa.connectedCallback');
     }
 
     processResultErrors(response) {
         if (response.Errors !== undefined && response.Errors.length !== 0) {
             this.showErrorToastMsg(JSON.stringify(response.Errors[0].Detail));
         }
     }
 
     get shouldCreateActivity() {
         console.log('>> shouldCreateActivity()');
 
         let milestones = this.template.querySelector('c-milestones');
 
         if (!this.recordId || !milestones) return false;
 
         let result = !milestones.hasAnOpenMilestone();
 
         console.log('<< shouldCreateActivity() = ' + result);
 
         return result;
     }
 
     handleModalClosed() {
         this.showCreateActivityModal = false;
     }
 
     handelOpenCreateActivityModal() {
         this.showCreateActivityModal = true;
     }
 
     showSuccessToastMsg(msg) {
         const toast = new ShowToastEvent({
             title: "Success",
             message: msg,
             variant: "success"
         });
         this.dispatchEvent(toast);
     }
 
     showErrorToastMsg(msg) {
         const toast = new ShowToastEvent({
             title: "Error",
             message: msg,
             variant: "error"
         });
         this.dispatchEvent(toast);
     }
 
     @track selectedVariantId;
 
     get selectedVariantComplex()
     {
         let v = {};
         v.VariantName = this.selectedProductName;
         v.VariantId = this.selectedVariantId;
         v.ServicePlanId = this.selectedServicePlanId;
         v.Pricebook2Id = this.pricebook2id;
         v.OpportunityId = this.opportunityId;
         v.Make = this.selectedProductBrand;
         v.Model = this.selectedProductModel;
         v.ModelYear = this.selectedProductModelYear;
         v.Engine = this.selectedProductEngine;
         return v;
     }
     @track selectedPricebookEntryId;
     @track selectedServicePlanId;
     @track selectedServicePlanContractId;
     @track correctStage;
     //@track showsaletypecmp = false;
 
     async handleServicePlanSelected(evt) {
         console.log('>> handleServicePlanSelected(evt: ' + JSON.stringify(evt) + ')');
         this.selectedServicePlanId = evt.detail;
         this.collapsePlanSelector();
         await this.connectedCallback();
         console.log('<< handleServicePlanSelected()');
     }
 
     clearAsset() {
         console.log('>> clearAsset');
         this.selectedAsset = undefined;
         this.selectedAssetName = undefined;
         this.selectedAssetExteriorColour = undefined;
         //this.setAsset();
         console.log('<< clearAsset');
     }
 
     async setVariant(variantId) {
 
         console.log('>> setVariant()');
         let request = {};
         request.VariantId = variantId;
         request.PricebookId = this.pricebook2id;
         request.PricebookEntryId = this.selectedPricebookEntryId;
         request.OpportunityId = this.opportunityId;
 
         console.log('SetVariant Request: ' + JSON.stringify(request));
         let result = await toastErrorOnFail(SetVariant({
             request: request
         }))
             .catch(error => {
                 console.log('SetVariant Errors: ' + JSON.stringify(this.error));
                 this.error = error;
                 this.products = undefined;
             });
 
         console.log('SetVariant - Result: ' + JSON.stringify(result));
         await this.connectedCallback();
         console.log('<< setVariant()');
     }
 
     async getOpportunity2()
     {
         console.log('>> getOpportunity3()');
         let res = await toastErrorOnFail(GetOpportunityData({oppId : this.recordId}));
         console.log('GetOpportunityData FM(' + JSON.stringify({oppId : this.recordId}) + ') = ' + JSON.stringify(res));
         console.log('<< this.correctStage: '+JSON.stringify(this));
         this.opportunityId = res.OpportunityId
         this.opportunityName = res.OpportunityName;
         this.opportunityStage = res.OpportunityStage;
         this.leadSource = res.OpportunityLeadSource;
         this.enquiryType = res.OpportunityEnquiryType;
         this.setSelectedSaleType(res.OpportunitySaleType, false);
         this.isClosed = res.OpportunityIsClosed;
         this.correctStage = this.opportunityStage;
         this.selectedProductBrand = res.MakeName;
         this.selectedMakeId = res.MakeId;
         this.selectedProductModel = res.ModelName;
         this.selectedModelId = res.ModelId;
         this.selectedProductName = res.DerivativeName;
         this.selectedVariantId = res.DerivativeId;
         this.selectedProductModelYear = res.DerivativeModelYear;
         this.selectedProductEngine = res.DerivativeEngine;
         this.isExDemo=res.Isexdemo;
         this.selectedAsset = res.AssetId;
         this.selectedAssetName = res.AssetName;
 
         this.isPersonAccount = res.IsPersonAccount;
         this.accountName = res.AccountName;
         this.accountId = res.AccountId;
         this.primaryContactName = res.ContactName;
         this.primaryContactId = res.ContactId;
         this.contactEmail = res.Email;
         this.contactPhoneMobile = res.Mobile;
 
         if (res.CorporatePartnerId)
         {
             this.corporatePartner = {};
             this.corporatePartner.Name = res.CorporatePartnerName;
             this.corporatePartner.Id = res.CorporatePartnerId;
         }
         else
         {
             this.corporatePartner = undefined;
         }
 
         this.selectedProductServicePlanType = res.ServicePlanType;
         this.selectedProductServicePlan = res.ServicePlanName;
         this.selectedServicePlanId = res.ServicePlanId;
 
         this.pricebook2id = res.Pricebook2Id;
 
         this.hasBeenRdad = res.OpportunityHasBeenRdad;
         this.rdaName = res.RdaName;
         this.rdaId = res.RdaId;
 
         this.corporateEligibilityEnabled = res.CorporateEligibilityEnabled;
         this.corporateEligibilityMessage = res.CorporateEligibilityMessage;
 
         console.log('<< getOpportunity4()');
         console.log('Exdemo final value from Salesforce : ' + res.Isexdemo);
         console.log('<< this.correctStage: '+JSON.stringify(this.correctStage));
         if (this.correctStage != 'Order Taken' && this.correctStage != 'Handover & RDA' && this.correctStage != 'Lost'){
              console.log('<< getcorrectStage'+this.correctStage);
             this.Isvisible = false;
         }
     }
    
     setChildComponentComplexObject(v) {
         console.log('>> setChildComponentComplexObject()');
         console.log('VariantComplex: ' + JSON.stringify(v));
         //const child = this.template.querySelector("c-variant-selector");
         //console.log('child: ' + child);
         //child.setSelectedDerivativeComplexObject(v);
         console.log('>> setChildComponentComplexObject()');
     }
 
     rdaClicked()
     {
         this[NavigationMixin.Navigate]({
             type: "standard__recordPage",
             attributes: {
                 recordId: this.rdaId,
                 objectApiName: "Rda__c",
                 actionName: "view"
             }
         });
     }
 
     isSaleTypeNew() {
         return this.selectedSaleType === SALE_TYPES_NEW || this.selectedSaleType === PICKLIST_VAL_SALE_TYPE_NEW;
 
     }
 
     isSaleTypeDemo() {
         return this.selectedSaleType === SALE_TYPES_DEMO || this.selectedSaleType === PICKLIST_VAL_SALE_TYPE_DEMONSTRATOR;
 
     }
 
     handleCurrentOpportunityClick() {
         this.isSelected_currentOpportunity = true;
         this.isSelected_relatedInformation = false;
         this.isSelected_allActivities = false;
     }
 
     handleRelatedInformationClick() {
         this.isSelected_currentOpportunity = false;
         this.isSelected_relatedInformation = true;
         this.isSelected_allActivities = false;
     }
 
     handleAllActivitiesClick() {
         this.isSelected_currentOpportunity = false;
         this.isSelected_relatedInformation = false;
         this.isSelected_allActivities = true;
     }
 
     handleAllOpportunitiesClick() {
         this.isSelected_currentOpportunity = false;
         this.isSelected_relatedInformation = false;
         this.isSelected_allActivities = false;
     }
 
     CSS_CLASS_JLR_HIDDEN = 'jlr-hidden';
 
     handleVehicleSelectionExpand() {
         // stop this from expanding if this opp has been rdad as it is in read only mode
         if (this.hasBeenRdad) return;
 
         this.getVehicleSelectionExpandBtn().classList.add(this.CSS_CLASS_JLR_HIDDEN);
 
         this.getVehicleSelectionCollapseBtn().classList.remove(this.CSS_CLASS_JLR_HIDDEN);
 
         this.getVariantSelector().classList.remove(this.CSS_CLASS_JLR_HIDDEN);
     }
 
     handleVehicleSelectionCollapse() {
         this.collapseVehicleSelector();
     }
 
     collapseVehicleSelector() {
         this.getVehicleSelectionExpandBtn().classList.remove(this.CSS_CLASS_JLR_HIDDEN);
 
         this.getVehicleSelectionCollapseBtn().classList.add(this.CSS_CLASS_JLR_HIDDEN);
 
         this.getVariantSelector().classList.add(this.CSS_CLASS_JLR_HIDDEN);
     }
 
     getVehicleSelectionCollapseBtn() {
         return this.template.querySelector('.jlr-vehicle-selection-collapse-button');
     }
 
     getVehicleSelectionExpandBtn() {
         return this.template.querySelector('.jlr-vehicle-selection-expand-button');
     }
 
     getVariantSelector() {
         return this.template.querySelector('.jlr-variant-selector');
     }
 
 
     //ASSET SELECTION
 
     handleAssetSelectionExpand() {
         // stop this from expanding if this opp has been rdad as it is in read only mode
         if (this.hasBeenRdad) return;
 
         this.getAssetSelectionExpandBtn().classList.add(this.CSS_CLASS_JLR_HIDDEN);
 
         this.getAssetSelectionCollapseBtn().classList.remove(this.CSS_CLASS_JLR_HIDDEN);
 
         this.getAssetSelector().classList.remove(this.CSS_CLASS_JLR_HIDDEN);
     }
 
     handleAssetSelectionCollapse() {
         this.collapseAssetSelector();
     }
 
     collapseAssetSelector() {
         this.getAssetSelectionExpandBtn().classList.remove(this.CSS_CLASS_JLR_HIDDEN);
 
         this.getAssetSelectionCollapseBtn().classList.add(this.CSS_CLASS_JLR_HIDDEN);
 
         this.getAssetSelector().classList.add(this.CSS_CLASS_JLR_HIDDEN);
     }
 
     getAssetSelectionCollapseBtn() {
         return this.template.querySelector('.jlr-asset-selection-collapse-button');
     }
 
     getAssetSelectionExpandBtn() {
         return this.template.querySelector('.jlr-asset-selection-expand-button');
     }
 
     getAssetSelector() {
         return this.template.querySelector('.jlr-asset-selector');
     }
 
     //END ASSET SELECTION
 
     handlePlansExpand() {
         // stop this from expanding if this opp has been rdad as it is in read only mode
         if (this.hasBeenRdad) return;
 
         this.hidePlansExpandButton();
 
         this.showCollapsePlansButton();
 
         this.showPlansDiv();
     }
 
     showPlansDiv() {
         let plansDiv = this.getPlansDiv();
         plansDiv.classList.remove(this.CSS_CLASS_JLR_HIDDEN);
     }
 
     showCollapsePlansButton() {
         this.getPlansCollapseBtn().classList.remove(this.CSS_CLASS_JLR_HIDDEN);
     }
 
     hidePlansExpandButton() {
         this.getPlansExpandBtn().classList.add(this.CSS_CLASS_JLR_HIDDEN);
     }
 
     getPlansDiv() {
         return this.template.querySelector('.jlr-plans');
     }
 
     handlePlansCollapse() {
         this.collapsePlanSelector();
     }
 
     collapsePlanSelector() {
         this.hidePlansCollapseButton();
 
         this.showPlansExpandButton();
 
         this.hidePlansDiv();
     }
 
     showPlansExpandButton() {
         this.getPlansCollapseBtn().classList.add(this.CSS_CLASS_JLR_HIDDEN);
     }
 
     hidePlansCollapseButton() {
         this.getPlansExpandBtn().classList.remove(this.CSS_CLASS_JLR_HIDDEN);
     }
 
     getPlansExpandBtn() {
         return this.template.querySelector('.jlr-plans-expand-button');
     }
 
     getPlansCollapseBtn() {
         return this.template.querySelector('.jlr-plans-collapse-button');
     }
 
     hidePlansDiv() {
         this.getPlansDiv().classList.add(this.CSS_CLASS_JLR_HIDDEN);
     }
     //RDA Validator START
     handleRDAValidatorExpand() {
 
         this.getRDAValidationExpandBtn().classList.add(this.CSS_CLASS_JLR_HIDDEN);
 
         this.getRDAValidationCollapseBtn().classList.remove(this.CSS_CLASS_JLR_HIDDEN);
 
         this.getRDAValidation().classList.remove(this.CSS_CLASS_JLR_HIDDEN);
     }
 
     handleRDAValidatorCollapse() {
         this.collapseRDAValidation();
     }
 
     collapseRDAValidation() {
         this.getRDAValidationExpandBtn().classList.remove(this.CSS_CLASS_JLR_HIDDEN);
 
         this.getRDAValidationCollapseBtn().classList.add(this.CSS_CLASS_JLR_HIDDEN);
 
         this.getRDAValidation().classList.add(this.CSS_CLASS_JLR_HIDDEN);
     }
 
     getRDAValidationCollapseBtn() {
         return this.template.querySelector('.jlr-rda-validator-collapse-button');
     }
 
     getRDAValidationExpandBtn() {
         return this.template.querySelector('.jlr-rda-validator-expand-button');
     }
 
     getRDAValidation() {
         return this.template.querySelector('.jlr-rda-validator');
     }
 
 
     //RDA Validator END
     // Trade Form START
 
     handleTradeFormExpand() {
 
         this.getTradeFormExpandBtn().classList.add(this.CSS_CLASS_JLR_HIDDEN);
 
         this.getTradeFormCollapseBtn().classList.remove(this.CSS_CLASS_JLR_HIDDEN);
 
         this.getTradeForm().classList.remove(this.CSS_CLASS_JLR_HIDDEN);
     }
 
     handleTradeFormCollapse() {
         this.collapseTradeForm();
     }
 
     collapseTradeForm() {
         this.getTradeFormExpandBtn().classList.remove(this.CSS_CLASS_JLR_HIDDEN);
 
         this.getTradeFormCollapseBtn().classList.add(this.CSS_CLASS_JLR_HIDDEN);
 
         this.getTradeForm().classList.add(this.CSS_CLASS_JLR_HIDDEN);
 
     }
 
     getTradeFormCollapseBtn() {
         console.log('Expand getTradeFormCollapseBtn');
         return this.template.querySelector('.jlr-trade-form-collapse-button');
     }
 
     getTradeFormExpandBtn() {
         return this.template.querySelector('.jlr-trade-form-expand-button');
 
     }
 
     getTradeForm() {
         return this.template.querySelector('.jlr-trade-form');
     }
     // Trade Form END
 
     //Op Line Items
     handleOpLineItemsExpand() {
 
         this.getOpLineItemsExpandBtn().classList.add(this.CSS_CLASS_JLR_HIDDEN);
 
         this.getOpLineItemsCollapseBtn().classList.remove(this.CSS_CLASS_JLR_HIDDEN);
 
         this.getOpLineItemsDiv().classList.remove(this.CSS_CLASS_JLR_HIDDEN);
     }
 
     handleOpLineItemsCollapse() {
         this.getOpLineItemsExpandBtn().classList.remove(this.CSS_CLASS_JLR_HIDDEN);
 
         this.getOpLineItemsCollapseBtn().classList.add(this.CSS_CLASS_JLR_HIDDEN);
 
         this.getOpLineItemsDiv().classList.add(this.CSS_CLASS_JLR_HIDDEN);
     }
 
 
     handleOpLineItemRemoved(evt) {
         console.log('>> handleOpLineItemRemoved(evt: ' + JSON.stringify(evt));
         this.products = evt.detail;
         let isVehicle = false;
         for (let i = 0; i < this.products.length; i++) {
             let prod = this.products[i];
             if (prod.IsVehicle) {
                 console.log('Is Vehicle');
                 isVehicle = true;
                 break;
             }
         }
         if (!isVehicle) {
             console.log('There is no vehicle');
             this.selectedServicePlanId = undefined;
             this.selectedVariantId = undefined;
             this.selectedPricebookEntryId = undefined;
         } else {
             console.log('There is still a vehicle');
         }
     }
 
     getOpLineItemsDiv() {
         return this.template.querySelector('.jlr-op-line-items');
     }
 
     getOpLineItemsCollapseBtn() {
         return this.template.querySelector('.jlr-op-line-items-collapse-button');
     }
 
     getOpLineItemsExpandBtn() {
         return this.template.querySelector('.jlr-op-line-items-expand-button');
     }
 
     async handleCorporateAccountUpdated(evt) {
         this.corporatePartner = evt.detail;
         await this.connectedCallback();
     }
 
     handleSaleType_NewClick() {
         console.log('>>  handleSaleType_NewClick()');
         // if this has been rdad the user cannot change the sales type
         if (this.hasBeenRdad) return;
         this.setSaleTypeDivAsSelected(SALE_TYPES_NEW, true);
         console.log('<<  handleSaleType_NewClick()');
     }
 
     handleSaleTypeDemoorUsed(){
         console.log('Exdemo final value' +this.isExDemo);
        if(this.isExDemo){
        this.handleSaleType_DemoClick();
        }else{
         this.handleSaleType_PreOwnedClick();
        }
      }
 
     handleSaleType_DemoClick() {
         console.log('>>  handleSaleType_DemoClick()');
         // if this has been rdad the user cannot change the sales type
         if (this.hasBeenRdad) return;
         this.setSaleTypeDivAsSelected(SALE_TYPES_DEMO, true);
         console.log('<<  handleSaleType_DemoClick()');
     }
 
     handleSaleType_PreOwnedClick() {
         console.log('>>  handleSaleType_PreOwnedClick()');
         // if this has been rdad the user cannot change the sales type
         if (this.hasBeenRdad) return;
         this.setSaleTypeDivAsSelected(SALE_TYPES_PRE_OWNED, true);
         console.log('<<  handleSaleType_PreOwnedClick()');
     }
 
  /*   handleSaleType_ApoClick() {
         console.log('>>  handleSaleType_ApoClick()');
         // if this has been rdad the user cannot change the sales type
         if (this.hasBeenRdad) return;
         this.setSaleTypeDivAsSelected(SALE_TYPES_APO, true);
         console.log('<<  handleSaleType_ApoClick()');
     }   */
 
     getSaleTypeDiv(saleType) {
         let cls = '.jlr-sale-type-' ;
         console.log('>> getSaleTypeDiv(saleType : ' + saleType + ')');
         if(saleType=='new'){
         cls = cls + saleType;
         }else if(saleType=='demo'||saleType=='pre-owned'){
             cls = cls + 'pre-owned';
         }
         console.log('>> cls ' + cls );
         //console.log('Looking for : ' + cls);
         let div = this.template.querySelector(cls);
         console.log('<< getSaleTypeDiv');
         return div;
     }
 
     setSaleTypeDivAsSelected(saleType, doUpdateOpportunity) {
         this.unsetAllSaleTypes();
         console.log('SELECTED_SALE_TYPE_CLASS'+SELECTED_SALE_TYPE_CLASS);
         console.log('saleType'+saleType);
         this.getSaleTypeDiv(saleType).classList.add(SELECTED_SALE_TYPE_CLASS);
         if (doUpdateOpportunity) {
             this.updateOpportunitySaleType(saleType);
         }
     }
 
     unsetAllSaleTypes() {
         this.unsetSaleType(SALE_TYPES_NEW);
        // this.unsetSaleType(SALE_TYPES_DEMO);
         //this.unsetSaleType(SALE_TYPES_APO);
         this.unsetSaleType(SALE_TYPES_PRE_OWNED)
     }
 
     unsetSaleType(saleType) {
        // console.log('SELECTED_SALE_TYPE_CLASS'+SELECTED_SALE_TYPE_CLASS);
         this.getSaleTypeDiv(saleType).classList.remove(SELECTED_SALE_TYPE_CLASS);
     }
 
     setSelectedSaleType(saleType, doUpdateOpportunity) {
         console.log('>> setSelectedSaleType()');
         console.log('SaleType: ' + saleType);
         this.selectedSaleType = saleType;
         if (saleType === undefined) {
             this.unsetAllSaleTypes();
         } else if (saleType === PICKLIST_VAL_SALE_TYPE_NEW) {
             this.setSaleTypeDivAsSelected(SALE_TYPES_NEW, doUpdateOpportunity);
         } else if (saleType === PICKLIST_VAL_SALE_TYPE_DEMONSTRATOR&&this.isExDemo) {
             this.setSaleTypeDivAsSelected(SALE_TYPES_DEMO, doUpdateOpportunity);
         } else if (saleType === PICKLIST_VAL_SALE_TYPE_PRE_OWNED&&!this.isExDemo) {
             this.setSaleTypeDivAsSelected(SALE_TYPES_PRE_OWNED, doUpdateOpportunity);
         }/* else if (saleType === PICKLIST_VAL_SALE_TYPE_APPROVED_PRE_OWNED) {
             this.setSaleTypeDivAsSelected(SALE_TYPES_APO, doUpdateOpportunity);
         } */else {
             console.log('No match for saleType : ' + saleType);
         }
         console.log('<< setSelectedSaleType()');
     }
 
     updateOpportunitySaleType(saleType) {
         console.log('>> updateOpportunitySaleType(saleType : ' + saleType + ')');
         this.selectedSaleType = saleType;
         let request = {};
         request.OpportunityId = this.opportunityId;
         request.SaleType = saleType;
         toastErrorOnFail(UpdateOpportunity({
             request: request
         }))
 
             .then(result => {
                 JSON.stringify(result);
             })
 
             .catch(error => {
                 JSON.stringify(error);
                 this.showErrorToastMsg(JSON.stringify(error));
 
             });
 
         console.log('<< updateOpportunitySaleType()');
     }
 
 
     //Asset
 
     @track selectedAsset;
     @track selectedAssetName;
     @track selectedAssetExteriorColour;
 
     //handle the selection of an asset
     async handleAssetSelected(evt) {
         console.log('>> handleAssetSelected()');
         console.log('Event Details: ' + JSON.stringify(evt.detail));
         this.selectedAsset = evt.detail.Id;
         this.selectedAssetName = this.selectedAsset.Vin;
         this.selectedAssetExteriorColour = this.selectedAsset.ExteriorColour;
         this.selectedProductBrand = this.selectedAsset.Make;
         this.selectedProductModel = this.selectedAsset.Model;
         this.selectedProductTrim = this.selectedAsset.Trim;
         this.selectedProductName = this.selectedAsset.Name;
         this.collapseAssetSelector();
         // awaiting result as if the asset is set after the varient it will be deleted
         await this.setVariant(evt.detail.DerivativeProduct2Id);
         this.selectedAsset = evt.detail.Id;
         await this.setAsset();
         console.log('<< handleAssetSelected()');
 
         // SENDING MESSAGE OVER MSG CHANNEL
         console.log('MESSAGE SENT');
         this.refreshValidationTable();
         //MESSAGE SERVICE
         //this.sendMessage();
     }
 
     refreshValidationTable(){
 
         // REFRESHING TABLE
         this.validationTableRefresh = !this.validationTableRefresh;
     }
 
     handleSelectedAssetVinClick() {
         console.log('>> handleSelectedAssetVinClicked');
         this[NavigationMixin.Navigate]({
             type: "standard__recordPage",
             attributes: {
                 recordId: this.selectedAsset.Id,
                 objectApiName: "Asset",
                 actionName: "view"
             }
         });
         console.log('<< handleSelectedAssetVinClicked');
     }
 
     handleSelectedServicePlanClick() {
         console.log('>> handleSelectedServicePlanClicked');
         if (!this.selectedServicePlanContractId)
         {
             this[NavigationMixin.Navigate]({
                 type: "standard__recordPage",
                 attributes: {
                     recordId: this.selectedServicePlanId,
                     objectApiName: "Product2",
                     actionName: "view"
                 }
             });
         }
 
         console.log('<< handleSelectedServicePlanClicked');
     }
 
     @track
     showAssetAlreadyAssignedModal = false;
 
     assetAlreadyAssignedModalTable;
 
     assetAlreadyAssignedModalProceed;
 
     assetModelCancel()
     {
         this.showAssetAlreadyAssignedModal = false;
     }
 
     async setAsset() {
         let result = await toastErrorOnFail(SetAssetWithMultiAssignCheck({
             opportunityId: this.opportunityId,
             assetId: this.selectedAsset.Id
         }));
 
         if (result.AssetAlreadyAssignedToOpportunity)
         {
             // show modal
             this.assetAlreadyAssignedModalTable = [{
                 OpportunityName: result.OpportunityName,
                 OpportunityCloseDate: result.OpportunityCloseDate,
                 OpportunitySalesOwnerName: result.OpportunitySalesOwnerName
             }];
             this.showAssetAlreadyAssignedModal = true;
             this.assetAlreadyAssignedModalProceed = async () => {
                 await toastErrorOnFail(SetAssetForced({
                         opportunityId: this.opportunityId,
                         assetId: this.selectedAsset.Id,
                         removePriceProtection: false
                     }));
                 await this.connectedCallback();
             }
             return;
         }
 
         await this.connectedCallback();
         console.log('<< setAsset()');
     }
 
     @track
     showDeleteConformationBox;
 
     submitDeleteFunc;
 
     async handelProductDeleted()
     {
         console.log('>> handelProductDeleted()');
         this.submitDeleteFunc = async () =>
         {
             console.log('>> submitDeleteFunc()');
             await toastErrorOnFail(DeleteOpportunityProduct
             (
                 {
                     request: {
                         OpportunityId: this.opportunityId,
                         DoDeleteProduct: true,
                         DoDeleteAsset: true,
                         DoDeleteServicePlan: true
                     }
                 }
             ));
             await this.connectedCallback();
             console.log('<< submitDeleteFunc()');
         }
         this.showDeleteConformationBox = true;
 
         console.log('<< handelProductDeleted()');
     }
 
     async handelAssetDeleted()
     {
         console.log('>> handelAssetDeleted()');
         this.submitDeleteFunc = async () =>
         {
             console.log('>> submitDeleteFunc()');
             await toastErrorOnFail(DeleteOpportunityProduct
             (
                 {
                     request: {
                         OpportunityId: this.opportunityId,
                         DoDeleteProduct: false,
                         DoDeleteAsset: true,
                         DoDeleteServicePlan: true
                     }
                 }
             ));
             await this.connectedCallback();
             console.log('<< submitDeleteFunc()');
         }
         this.showDeleteConformationBox = true;
 
         console.log('<< handelAssetDeleted()');
     }
 
     async handelServicePlanDeleted()
     {
         console.log('>> handelServicePlanDeleted()');
         this.submitDeleteFunc = async () =>
         {
             console.log('>> submitDeleteFunc()');
             await toastErrorOnFail(DeleteOpportunityProduct
             (
                 {
                     request: {
                         OpportunityId: this.opportunityId,
                         DoDeleteProduct: false,
                         DoDeleteAsset: false,
                         DoDeleteServicePlan: true
                     }
                 }
             ));
             await this.connectedCallback();
             console.log('<< submitDeleteFunc()');
         }
         this.showDeleteConformationBox = true;
 
         console.log('<< handelServicePlanDeleted()');
     }
 
     async handelDeleteConformation()
     {
         await this.submitDeleteFunc();
         this.showDeleteConformationBox = false;
     }
 
     async handelDeleteCancel()
     {
         this.showDeleteConformationBox = false;
     }
 }