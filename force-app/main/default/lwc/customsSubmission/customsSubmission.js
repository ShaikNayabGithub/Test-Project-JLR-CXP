import { LightningElement, wire,api} from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getAssets from '@salesforce/apex/CustomsController.getAssets';
import submitCustoms from '@salesforce/apex/CustomsController.submitCustoms';
import getUserPermissions from '@salesforce/apex/CustomsController.getUserPermissions';

//Labels
import save from '@salesforce/label/c.Save'; import cancel from '@salesforce/label/c.Cancel';
import searchByVIN from '@salesforce/label/c.Search_By_VIN';
import searchByOptionCode from '@salesforce/label/c.Search_By_Option_Code';
import wholesaleAndCustomsManagementTitle from '@salesforce/label/c.Wholesale_Wholesales_and_customs_management';
import wholesaleSelectAView from '@salesforce/label/c.Wholesale_Select_A_View';
import wholesaleGuidanceNotRequested from '@salesforce/label/c.Wholesale_Guidance_Customs_Wholesale_Not_requested';
import wholesaleGuidanceClearanceReceipt from '@salesforce/label/c.Wholesale_Guidance_Customs_Clearance_receipt';
import wholesaleGuidanceReadyForClearance from '@salesforce/label/c.Wholesale_Guidance_Customs_Ready_for_clearance';
import wholesaleGuidanceWholesaleRequested from '@salesforce/label/c.Wholesale_Guidance_Wholesale_Requested';
import wholesaleGuidanceWholesaleCompleted from '@salesforce/label/c.Wholesale_Guidance_Wholesale_Completed';
import wholesaleSubmitForCustom from '@salesforce/label/c.Wholesale_Submit_for_Customs';
import wholesaleAcceptRejectCustom from '@salesforce/label/c.Wholesale_Accept_Reject_Customs';
import wholesaleCustomCompleted from '@salesforce/label/c.Wholesale_Customs_Completed';
import wholesaleCompleteWholesaleRequest from '@salesforce/label/c.Wholesale_Complete_Wholesale_Request';
import CancelCustomRequests from '@salesforce/label/c.Cancel_Custom_Requests';
import wholesaleAndCustomRequest from '@salesforce/label/c.Wholesale_and_custom_request';
import wholesaleAndCustomRequestGuidelines from '@salesforce/label/c.Wholesale_and_custom_request_Guidelines';
import wholesaleAndCustomRequestGuidelines2 from '@salesforce/label/c.Wholesale_and_custom_request_guidelines_2';
import SelectVheicle from '@salesforce/label/c.Wholesale_Select_Vehicle';
import WholesaleAcceptReject from '@salesforce/label/c.Wholesale_Accept_or_reject';
import WholesaleAcceptRejectGuidelines from '@salesforce/label/c.Wholesale_Accept_or_Reject_Guidelines';
import acceptButton from '@salesforce/label/c.Wholesale_AcceptButton';
import RejectButton from '@salesforce/label/c.Wholesale_RejectButton';
import WholesaleConfirmCustomCompleted from '@salesforce/label/c.Wholesale_Confirm_Customs_Completed';
import wholesaleCompleteRequest from '@salesforce/label/c.Wholesale_Complete_wholesale';
import wholesaleCompleteRequestMsg from '@salesforce/label/c.Wholesale_request_msg';
import CustomRequestMsg from '@salesforce/label/c.Custom_request_msg';
import wholesalecancelrequest from '@salesforce/label/c.Wholesale_Cancel_request';
import wholesaleCustomNotrequested from '@salesforce/label/c.Wholesale_Customs_Wholesale_Not_Requested';
import wholesaleCustomClearanceReceipt from '@salesforce/label/c.Wholesale_Customs_Clearance_Receipt';
import wholesaleCustomReadyForClearance from '@salesforce/label/c.Wholesale_Customs_Ready_for_Clearance';
import wholesaleCustomClearanceCompleted from '@salesforce/label/c.Wholesale_Customs_Clearance_Completed';
import wholesaleWholesaleRequested from '@salesforce/label/c.Wholesale_Wholesale_Requested';
import wholesaleWholesaleCompleted from '@salesforce/label/c.Wholesale_Wholesale_Completed';
import wholesaleExpecteddate from '@salesforce/label/c.Wholesale_Expected_Wholesale_Date';
import wholesaleOrderType from '@salesforce/label/c.Wholesale_Order_Type';
import WholesaleFWA from '@salesforce/label/c.Wholesale_FWA_WHS_by_FS_partner';
import WholesaleWE from '@salesforce/label/c.Wholesale_WE_WHS_by_Cash';
import WholesaleRemarks from '@salesforce/label/c.Wholesale_Remarks';
import WholesaleVIN from '@salesforce/label/c.VIN';
import WholesaleModel from '@salesforce/label/c.Model';
import wholesaleAccountName from '@salesforce/label/c.Wholesale_Account_Name';
import wholesaleCustomStatus from '@salesforce/label/c.Wholesale_Customs_Status'; 
import wholesaleStatus from '@salesforce/label/c.Wholesale_status'; 
import wholesaleHomologationStatus from '@salesforce/label/c.Wholesale_Homologation_Status';
import ArrivalDate from '@salesforce/label/c.Arrival_date';


import wholesaleOrderNumber from '@salesforce/label/c.Wholesale_Order_Number';
import wholesaleActivationDate from '@salesforce/label/c.Wholesale_Activation_Date';

const customsStatusOptions = [
    { label: wholesaleCustomNotrequested, value: 'Not Requested'}, //wholesaleCustomNotrequested
    { label: wholesaleCustomClearanceReceipt, value: 'Clearance Receipt'},
    { label: wholesaleCustomReadyForClearance, value: 'Ready for Clearance' },
    { label: wholesaleCustomClearanceCompleted, value: 'Clearance Completed'},
    

];

const customsFilterTypes = [
    'Not Requested',
    'Clearance Receipt',
    'Ready for Clearance',
    'Clearance Completed'
];


// Datatable Column Configurations
const vehiclesNotReadyColumns = [
    {
        label: 	WholesaleVIN,
        fieldName: 'vin',
        sortable: true,
        cellAttributes: { alignment: 'left' },
    },
    { label: WholesaleModel, fieldName: 'Model' },
    { label: wholesaleAccountName, fieldName: 'accountName' }, 
    { label: ArrivalDate, fieldName: 'Arrival_Date__c' },
    { label: wholesaleHomologationStatus, fieldName: 'Homologation_Completion_Status__c' },
    { label: wholesaleStatus, fieldName: 'Wholesale_Activation_Status__c' },
    { label: wholesaleCustomStatus, fieldName: 'Customs_Clearance_Status__c' },
];

const clearanceReceiptColumns = [
    {
        label: WholesaleVIN,
        fieldName: 'vin',
        sortable: true,
        cellAttributes: { alignment: 'left' },
    },
    { label: WholesaleModel, fieldName: 'Model' },
    { label: wholesaleAccountName, fieldName: 'accountName' },
    { label: ArrivalDate, fieldName: 'Arrival_Date__c' },
    { label: wholesaleHomologationStatus, fieldName: 'Homologation_Completion_Status__c' },
    { label: wholesaleStatus, fieldName: 'Wholesale_Activation_Status__c' },
    { label: wholesaleCustomStatus, fieldName: 'Customs_Clearance_Status__c' },
    
];



const submitForCustomsAndWholesalePreviewColumns = [
    {
        label: 	WholesaleVIN,
        fieldName: 'vin',
        sortable: true,
        cellAttributes: { alignment: 'left' },
    },
    { label: WholesaleModel, fieldName: 'Model' },
    { label: wholesaleAccountName, fieldName: 'accountName' },
    { label: ArrivalDate , fieldName: 'Arrival_Date__c' },
    { label: wholesaleHomologationStatus, fieldName: 'Homologation_Completion_Status__c' },
    { label: wholesaleStatus, fieldName: 'Wholesale_Activation_Status__c' },
    { label: wholesaleCustomStatus, fieldName: 'Customs_Clearance_Status__c' },
];

const clearanceCompletedColumns = [
    {
        label: 	WholesaleVIN,
        fieldName: 'vin',
        sortable: true,
        cellAttributes: { alignment: 'left' },
    },
    { label: WholesaleModel, fieldName: 'Model' },
    { label: wholesaleAccountName, fieldName: 'accountName' },
    { label: wholesaleHomologationStatus, fieldName: 'Homologation_Completion_Status__c' },
    { label: wholesaleStatus, fieldName: 'Wholesale_Activation_Status__c' },
    { label: wholesaleCustomStatus, fieldName: 'Customs_Clearance_Status__c' },
    { label: 'Completion Date', fieldName: 'Custom_Clearance_Completion_Date__c' },
];




export default class CustomsSubmission extends LightningElement {
    
    
    // Interaction Data 
    customsStatusOptions = customsStatusOptions;
    customsFilterTypes = customsFilterTypes;
    
    filteredCustomsStatus = 'Not Requested';

    typingIntervalMilliseconds = 300;
    typingTimer;

    currentDate = (new Date()).toISOString().split('T')[0];

    customsClearanceDate = this.currentDate;

    //Filtered View ContextVars
    viewNotRequested = true;
    viewClearanceReceipt = false;
    viewReadyForClearance = false;
    viewClearanceCompleted = false;
    viewWholesaleRequested = false;
    viewWholesaleCompleted = false;

    // Action button controllers
    submitForCustomsActionButton = false;
    acceptRejectActionButton = false;
    customsCompletedActionButton = false; 
    cancleCustomRequestActionButton = false;
    

    //modalViewContextVars
    isModalOpen = false;
    showModalSpinner = false;
    disableModalSubmit = true;
    showCustomsAndWholesaleContent = false;
    showCustomsAcceptRejectContent = false;
    showCustomsCompletedContent = false;
    showVehiclesNotReadyContent = false;
    showCustomCancelContent = false;

    homologationNotCompleted = false;
    homologationNotCompletedVehicles = [];
    arrivalDateNotSet = false;
    arrivalDateNotSetVehicles = [];

    //Table Dispay Headers
    columns = vehiclesNotReadyColumns;
    vehiclesNotReadyColumns = vehiclesNotReadyColumns;
    clearanceReceiptColumns = clearanceReceiptColumns;
    clearanceCompletedColumns = clearanceCompletedColumns;
    

    submitForCustomsAndWholesalePreviewColumns = submitForCustomsAndWholesalePreviewColumns;
    

    // Table Data
    assetData = []; // All retrieved assets
    displayedAssetData = []; // Main table view
    selectedRows = []; // Main table selected assets
    selectedRowsIsEmpty = true;

    label = {
        save,cancel,searchByVIN,searchByOptionCode,
        wholesaleAndCustomsManagementTitle,
        wholesaleSelectAView,
        wholesaleGuidanceNotRequested,
        wholesaleGuidanceClearanceReceipt,
        wholesaleGuidanceReadyForClearance,
        wholesaleGuidanceWholesaleRequested,
        wholesaleGuidanceWholesaleCompleted,
        wholesaleSubmitForCustom,
        wholesaleAcceptRejectCustom,
        wholesaleCustomCompleted,
        wholesaleCompleteWholesaleRequest,
        CancelCustomRequests,
        wholesaleAndCustomRequest,wholesaleAndCustomRequestGuidelines,wholesaleAndCustomRequestGuidelines2,
        SelectVheicle,
        WholesaleAcceptReject,WholesaleAcceptRejectGuidelines,acceptButton,RejectButton,
        WholesaleConfirmCustomCompleted,
        wholesaleCompleteRequest,wholesaleCompleteRequestMsg,wholesalecancelrequest,CustomRequestMsg,
    };


    @wire(getAssets)
    loadAssetData({error, data}){
        if(error) {
            console.log('error loading asset data');
        }
        if(data) {
            var allAssetData = [];
            data.map(assetItem => {
                
                const assetData = {
                    ...assetItem
                };
                assetData.Id = assetItem.Id;
                assetData.assetName = assetItem.Name;
                assetData.vin = assetItem.VIN__c;
                assetData.Model=assetItem.Model_Text__c;
                assetData.accountName=assetItem.Account_Local__c;
                assetData.Customs_Clearance_Status__c = (assetItem.Customs_Clearance_Status__c === undefined || !assetItem.Customs_Clearance_Status__c ) ? 'Not Requested' : assetItem.Customs_Clearance_Status__c;
                assetData.Homologation_Completion_Status__c = (assetItem.Homologation_Completion_Status__c === undefined || !assetItem.Homologation_Completion_Status__c ) ? 'Incomplete' : assetItem.Homologation_Completion_Status__c;

                if(assetItem.ChildAssets) {
                    assetData.OptionProductCodes = assetItem.ChildAssets.map(child => child.ProductCode);

                    assetData._children = assetItem.ChildAssets.map(child => {
                        const productOption = {
                            vin: child.Name,
                            Model: child.ProductCode
                        };
                        
                        return productOption;
                    });
                }
                
                allAssetData.push(assetData);

            });
            // Default to initial view logic
            this.displayedAssetData = allAssetData.filter(x => {
                return ['Not Requested','Rejected','Cancelled'].includes(x.Customs_Clearance_Status__c);
            });
            this.assetData = allAssetData;
            console.log(this.displayedAssetData);

        }
    }

    @wire(getUserPermissions) 
    loadUserPermissions({error, data}) {
        if(error) {
            console.log('error loading user permissions');
            console.log(error);
        }
        if(data) {
            console.log('got user permissions');
            console.log(data);
            this.userPermissions = JSON.parse(data).permissions;

            this.handleActionButtonVisibility();
        }
    }

    handleCustomsStatusFilterChange(event) {
        if(event) {
            this.filteredCustomsStatus = event.detail.value;
            
            if(this.filteredCustomsStatus === 'Not Requested') {
                this.columns = this.vehiclesNotReadyColumns;
            } else if (this.filteredCustomsStatus === 'Clearance Receipt') {
                this.columns = this.clearanceReceiptColumns;
                
            } else if (this.filteredCustomsStatus === 'Ready for Clearance') {
                this.columns = this.clearanceReceiptColumns;
            } else if (this.filteredCustomsStatus === 'Clearance Completed') {
                this.columns = this.clearanceCompletedColumns;
            }

            this.viewNotRequested = this.filteredCustomsStatus === 'Not Requested';
            this.viewClearanceReceipt = this.filteredCustomsStatus === 'Clearance Receipt';
            this.viewReadyForClearance = this.filteredCustomsStatus === 'Ready for Clearance';
            this.viewClearanceCompleted = this.filteredCustomsStatus === 'Clearance Completed';
            
            this.handleActionButtonVisibility();
 
        }
        
        this.displayedAssetData = this.assetData.filter( x => {
            if(this.filteredCustomsStatus === 'Not Requested') {
                return ['Not Requested','Rejected','Cancelled'].includes(x.Customs_Clearance_Status__c);
            } else {
                return x.Customs_Clearance_Status__c === this.filteredCustomsStatus;
            }

        });
        
        this.resetModalContentViews();

    }

    handleVinSearch(event){
        clearTimeout(this.typingTimer);
        
        let currentSearchTerm = event.target.value;
        this.typingTimer = setTimeout(() => {

            if(currentSearchTerm === '') {
                this.handleCustomsStatusFilterChange();
            } else if (currentSearchTerm) {
                let selectedVins = this.selectedRows.map(asset => asset.vin);
                this.displayedAssetData = this.displayedAssetData.filter( x => {
                    return (

                        (x.vin ? (x.vin).includes(currentSearchTerm) : false)
                        || selectedVins.includes(x.vin)
                    );
                });
            }

        }, this.typingIntervalMilliseconds);
        
    }
    

    handleVehicleSelection(event) {
        this.selectedRows = event.detail.selectedRows;
        this.selectedRowsIsEmpty = this.selectedRows.length === 0;
        this.verifyHomologationStatuses();
        this.verifyArrivalDatesCompletion();
    }

    handleOptionSearch(event){
        clearTimeout(this.typingTimer);
        
        let currentSearchTerm = event.target.value;
        this.typingTimer = setTimeout(() => {
            
            if(this.displayedAssetData.length === 0) {
                this.displayedAssetData = this.assetData.filter(x => {
                    if(this.filteredStatus === 'Not Requested') {
                        return ['Not Requested','Cancelled', 'Rejected', undefined].includes(x.Wholesale_Activation_Status__c) ;
        
                    } else {
                        return x.Wholesale_Activation_Status__c === this.filteredStatus;
                    }
                });
            } 

            if(currentSearchTerm === '') {
                this.handleStatusFilterChange();
            } else if (currentSearchTerm) {
                let selectedVins = this.selectedRows.map(asset => asset.vin);
                let searchItems = currentSearchTerm.split(',').map(x => x.trim()).filter(x => x != '');
                this.displayedAssetData = this.displayedAssetData.filter( x => {
                    if(!x.OptionProductCodes){
                        return false;
                    }
                    return (
                        (searchItems.every(v => x.OptionProductCodes.includes(v)))
                        || (x.OptionProductCodes.includes(currentSearchTerm))
                        || selectedVins.includes(x.vin)
                    );
                });
            }

        }, this.typingIntervalMilliseconds);
        
    }
    
    
    updateAssets(newStatus) {
        this.showModalSpinner = true;

        // Handle Data to submit in Apex Request
        var assetDataToUpdate = [];
        const proceesedAssetIds = [];
        console.log('mapping selected rows');
        this.selectedRows.map(selectedAsset => {
            let assetRecord = {
                Id: selectedAsset.Id,
            };
            assetRecord = this.applyAssetChanges(assetRecord, newStatus); 

            console.log('adding assetRecord');
            console.log(assetRecord);
            assetDataToUpdate.push(assetRecord);
            proceesedAssetIds.push(assetRecord.Id);
        });
        console.log('calling apex');
        console.log(assetDataToUpdate);
        submitCustoms({jsonData: JSON.stringify(assetDataToUpdate)})
            .then( response => {
                console.log(response);
                // Update View for User / In-Memory Data on success
                this.displayedAssetData = this.displayedAssetData.filter(x => !proceesedAssetIds.includes(x.Id) );
                this.assetData = this.assetData.map(asset => {
                    if(proceesedAssetIds.includes(asset.Id)) {
                        asset = this.applyAssetChanges(asset, newStatus); 
                    }
                    return asset;
                });
            
                this.selectedRows = [];
                this.isModalOpen = false;
                this.showModalSpinner = false;

                console.log('completed processing');
            })
        .catch(error => {
            console.log('Customs update failed');
            console.log(error);
            self.isModalOpen = false;
            self.showModalSpinner = false;
        });

        
    }

    applyAssetChanges(asset, newStatus) {
 
        //customs status
        asset.Customs_Clearance_Status__c = newStatus;
        
        if(newStatus === 'Ready for Clearance') {
            asset.Custom_Clearance_Receipt_Date__c = this.currentDate;

        }
        
        
         else if(newStatus === 'Clearance Completed') {
            asset.Custom_Clearance_Completion_Date__c = this.customsClearanceDate;
        }

        
        else if(newStatus === 'Cancelled') {
            asset.Customs_Clearance_Status__c = 'Cancelled';
            
        }
        console.log('updated asset');
        console.log(asset);
        return asset;
    }
    

    handleModalSubmission() {
        console.log('clicked submit');
        console.log(this.showCustomCancelContent);
        if( this.showCustomsAndWholesaleContent) {
            this.updateAssets('Clearance Receipt');
        }

        if(this.showCustomsCompletedContent) {
            this.updateAssets('Clearance Completed');
        }

         if(this.showCustomCancelContent) {
            this.updateAssets('Cancelled');
        }
        

    }

    handleAcceptCustomsRequests() {
        this.updateAssets('Ready for Clearance');
    }

    handleRejectCustomsRequests() {
        this.updateAssets('Rejected');
    }



    // Modal Buttons
    handleCustomsAndWholesaleButtonClick() {
        this.showCustomsAndWholesaleContent = !this.selectedRowsIsEmpty && !this.homologationNotCompleted && !this.arrivalDateNotSet;
        this.showVehiclesNotReadyContent = !this.selectedRowsIsEmpty && (this.homologationNotCompleted || this.arrivalDateNotSet);
        this.disableModalSubmit = this.selectedRowsIsEmpty || this.homologationNotCompleted || this.arrivalDateNotSet;
        this.isModalOpen = true;
    }

    handleCustomsAcceptRejectButtonClick(event) {
        this.isModalOpen = true;
        this.showCustomsAcceptRejectContent = !this.selectedRowsIsEmpty;
    }

    handleCustomsCompletedButtonClick(event) {
        this.isModalOpen = true;
        this.disableModalSubmit = false;
        this.showCustomsCompletedContent = !this.selectedRowsIsEmpty;
    }

    handleModalClose() {
        this.resetModalContentViews();
        this.isModalOpen = false;
        
    }

     handleCancelCustomRequestButtonClick(event) {
        this.isModalOpen = true;
        this.disableModalSubmit = false;
       // this.showWholesaleCompletedContent = !this.selectedRowsIsEmpty;
        this.showCustomCancelContent = !this.selectedRowsIsEmpty;
        console.log("Show");
        console.log(this.showCustomCancelContent);
    }

    

    handleActionButtonVisibility () {

        this.submitForCustomsActionButton = (
            this.viewNotRequested && 
            this.userPermissions.hasCustomsClearanceRetailerActionsUser === true
        );

        this.cancleCustomRequestActionButton = (
            
            (this.viewClearanceReceipt || this.viewReadyForClearance) && (
                (this.userPermissions.hasCustomsClearanceAgencyActionsUser === true) || 
                (this.userPermissions.hasCustomsClearanceRetailerActionsUser === true)
            )
        );

        this.acceptRejectActionButton = (
            this.viewClearanceReceipt && 
            this.userPermissions.hasCustomsClearanceAgencyActionsUser === true
        );

        this.customsCompletedActionButton = (
            this.viewReadyForClearance && 
            this.userPermissions.hasCustomsClearanceAgencyActionsUser === true
        );

        
    }

    resetModalContentViews() {
        this.showCustomsAndWholesaleContent = false;
        this.showCustomsAcceptRejectContent = false;
        this.showCustomsCompletedContent = false;
        this.disableModalSubmit = true;
        this.homologationNotCompleted = false;
        this.homologationNotCompletedVehicles = [];
        this.arrivalDateNotSet = false;
        this.arrivalDateNotSetVehicles = [];
        this.selectedRows = [];
        this.selectedRowsIsEmpty = true;
        this.showCustomCancelContent = false;
        
    }

    handleCustomsClearanceDateChange(event) {
        this.customsClearanceDate = event.detail.value; //YYYY-MM-DD
        this.disableModalSubmit = (this.customsClearanceDate == null || this.customsClearanceDate == '');
    }

    verifyHomologationStatuses() {
        this.homologationNotCompletedVehicles = this.selectedRows.filter(x => x.Homologation_Completion_Status__c === 'Incomplete');
        this.homologationNotCompleted = this.homologationNotCompletedVehicles.length > 0;
    }

    verifyArrivalDatesCompletion() {
        this.arrivalDateNotSetVehicles = this.selectedRows.filter(x => [null, undefined].includes(x.Arrival_Date__c));
        this.arrivalDateNotSet = this.arrivalDateNotSetVehicles.length > 0;
    }
    
    

}