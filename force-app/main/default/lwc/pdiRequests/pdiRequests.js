import { LightningElement, wire } from 'lwc';

import getPdiRequests from '@salesforce/apex/CustomsController.getPdiRequests';
import submitPdi from '@salesforce/apex/CustomsController.submitPdi';
import getUserPermissions from '@salesforce/apex/CustomsController.getUserPermissions';

//labels
import selectAView from '@salesforce/label/c.Wholesale_Select_A_View';
import searchByVIN from '@salesforce/label/c.Search_By_VIN';
import pdiRequestMsg from '@salesforce/label/c.PDI_Request_Msg';
import pdiRequestMsg2 from '@salesforce/label/c.PDI_Request_Msg_2';
import pdiRequestMsg3 from '@salesforce/label/c.PDI_Request_Msg3';
import approveButton from '@salesforce/label/c.PDI_Approve_Button';
import cancelButton from '@salesforce/label/c.PDI_Cancel';
import completeButton from '@salesforce/label/c.PDI_Complete_Button';
import selectVehicle from '@salesforce/label/c.PDI_Complete_Button';
import newRequest from '@salesforce/label/c.PDI_New_Request';
import approveRequest from '@salesforce/label/c.PDI_Approve_Request';
import declinedRequest from '@salesforce/label/c.PDI_Declined_Request';
import completedRequest from '@salesforce/label/c.PDI_Completed_Request';
import cancelledRequest from '@salesforce/label/c.PDI_Cancelled_Request';

export default class PdiRequests extends LightningElement {
    // Interaction Data 
    viewSelector = [
        { label: newRequest, value: 'Requested'},
        { label: approveRequest, value: 'Approved'},
        { label: declinedRequest, value: 'Declined'},
        { label: completedRequest, value: 'Completed'},
        { label: cancelledRequest, value: 'Cancelled'},
    ];
    viewSelection = 'Requested';

    coreColumns = [
        {
            label: 'VIN',
            fieldName: 'Vehicle__r.VIN__c',
            sortable: true,
            cellAttributes: { alignment: 'left' },
        },
        { label: 'PDI Status', fieldName: 'PDI_Status__c' },
        { label: 'Customs Status', fieldName: 'Customs_Status__c' },
        { label: 'Wholesale Status', fieldName: 'WHS_Status__c' },
        { label: 'Requested Delivery Date', fieldName: 'Requested_Delivery_Date__c' },
        { label: 'Requested Completion Date', fieldName: 'Requested_Completion_Date__c' },
        { label: 'Request Sent Date', fieldName: 'CreatedDate' },
        { label: 'Retailer', fieldName: 'Vehicle__r.Retailer_Account_Name__c' },
    ];

    completedColumns = [
        {
            label: 'VIN',
            fieldName: 'Vehicle__r.VIN__c',
            sortable: true,
            cellAttributes: { alignment: 'left' },
        },
        { label: 'PDI Status', fieldName: 'PDI_Status__c' },
        { label: 'PDI Completion Date', fieldName: 'PDI_Completion_Date__c' },
        { label: 'Customs Status', fieldName: 'Customs_Status__c' },
        { label: 'Wholesale Status', fieldName: 'WHS_Status__c' },
        { label: 'Requested Delivery Date', fieldName: 'Requested_Delivery_Date__c' },
        { label: 'Requested Completion Date', fieldName: 'Requested_Completion_Date__c' },
        { label: 'Request Sent Date', fieldName: 'CreatedDate' },
        { label: 'Retailer', fieldName: 'Vehicle__r.Retailer_Account_Name__c' },
    ];
    userPermissions;


    //labels 
    label = {
        selectAView,searchByVIN,pdiRequestMsg,pdiRequestMsg2,pdiRequestMsg3,approveButton,cancelButton,completeButton,selectVehicle,
    };
    

    // Utils
    currentDate = (new Date()).toISOString().split('T')[0];
    typingIntervalMilliseconds = 300;
    typingTimer;

    pdiCompletionDate = this.currentDate;
    disableCompletePdiButton = false;

    // Table Data
    pdiData = []; // All retrieved pdi
    displayedPdiData = []; // Main table view
    selectedRows = []; // Main table selected pdi
    selectedRowsIsEmpty = true;

    // Action button controllers
    approveDeclineActionButton = false;
    completeDeclineActionButton = false;
    cancelActionButton = false; //pp
    
    //Table Dispay Headers
    columns = this.coreColumns;

    //Filtered View ContextVars
    viewNewRequest = true; 
    viewApprovedRequests = false; 
    viewDeclinedRequests = false;
    viewCompletedRequests = false;
    viewCancelledRequests = false; //pp
   
    

    //modalViewContextVars
    isModalOpen = false;
    showModalSpinner = false;
    disableModalSubmit = true;
    showNewPdiRequestContent = false;
    showApprovedRequestContent = false;
    showCancelledRequestContent = false;
    showDeclinedRequests = false;
    showCompletedRequests = false;
    showCancelledRequests = false;

    @wire(getPdiRequests)
    loadAssetData({error, data}){
        if(error) {
            console.log('error loading asset data');
        }
        if(data) {
            console.log('got pdi data');
            var allPdiData = [];
            data.map(pdi => {
                // TODO: Change of direction, default to Salesforce data model for attribute values. Kept here pending refactor. 
                const newPdi = {
                    ...pdi,
                    'Vehicle__r.VIN__c': pdi.Vehicle__r.VIN__c,
                    'Vehicle__r.Order_Number__c': pdi.Vehicle__r.Order_Number__c,
                    'Vehicle__r.Retailer_Account_Name__c': pdi.Vehicle__r.Retailer_Account_Name__c
                };
                
                allPdiData.push(newPdi);

            });
            // Default to initial view logic
            this.displayedPdiData = allPdiData.filter(x => {
                return (x.PDI_Status__c === undefined || x.PDI_Status__c === 'Requested') ;
            });
            this.pdiData = allPdiData;
            console.log(this.pdiData);

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

    handleChangeView(event) {
        this.viewSelection = event.detail.value;

        this.viewNewRequest = this.viewSelection === 'Requested'; 
        this.viewApprovedRequests = this.viewSelection === 'Approved'; 
        this.viewDeclinedRequests = this.viewSelection === 'Declined'; 
        this.viewCompletedRequests = this.viewSelection === 'Completed'; 
        this.viewCancelledRequests = this.viewSelection === 'Cancelled'; //pp 

        
        if(this.viewSelection === 'Completed') {
            this.columns = this.completedColumns;
        } else {
            this.columns = this.coreColumns;
        }


        //[undefined, 'Requested'].includes(x.PDI_Status__c) 
        this.displayedPdiData = this.pdiData.filter( x => {
            if(this.filteredCustomsStatus === 'Requested') {
                return (x.PDI_Status__c === undefined || x.PDI_Status__c === 'Requested');
            } else {
                return x.PDI_Status__c === this.viewSelection;
            }
            
        });

        this.handleActionButtonVisibility();
        
        this.resetModalContentViews();
    }

    handleVehicleSelection(event) {
        this.selectedRows = event.detail.selectedRows;
        this.selectedRowsIsEmpty = this.selectedRows.length === 0;
    }

    handleVinSearch(event){
        clearTimeout(this.typingTimer);
        
        let currentSearchTerm = event.target.value;
        this.typingTimer = setTimeout(() => {

            if(currentSearchTerm === '') {
                this.handleChangeView();
            } else if (currentSearchTerm) {
                let selectedVins = this.selectedRows.map(asset => asset['Vehicle__r.VIN__c']);
                this.displayedPdiData = this.displayedPdiData.filter( x => {
                    return (

                        (x['Vehicle__r.VIN__c'] ? (x['Vehicle__r.VIN__c'] ).includes(currentSearchTerm) : false)
                        || selectedVins.includes(x['Vehicle__r.VIN__c'] )
                    );
                });
            }

        }, this.typingIntervalMilliseconds);
        
    }

    updatePdi(newStatus) {
        this.showModalSpinner = true;

        // Handle Data to submit in Apex Request
        var pdiDataToUpdate = [];
        const proceesedPdiIds = [];
        console.log('mapping selected rows');
        this.selectedRows.map(pdiRequest => {
            let pdiRecord = {
                Id: pdiRequest.Id,
            };
            pdiRecord = this.applyPdiChanges(pdiRecord, newStatus); 

            console.log('adding pdiRecord');
            console.log(pdiRecord);
            pdiDataToUpdate.push(pdiRecord);
            proceesedPdiIds.push(pdiRecord.Id);
        });
        console.log('calling apex');
        console.log(pdiDataToUpdate);
        console.log('displayedData');
        console.log(this.displayedPdiData);
        submitPdi({jsonData: JSON.stringify(pdiDataToUpdate)})
            .then( response => {
                console.log(response);
                // Update View for User / In-Memory Data on success
                this.displayedPdiData = this.displayedPdiData.filter(x => {
                 let output = !proceesedPdiIds.includes(x.Id) ;
                 console.log('output');
                 console.log(output);
                 return output;   
                });
                this.pdiData = this.pdiData.map(pdi => {
                    if(proceesedPdiIds.includes(pdi.Id)) {
                        pdi = this.applyPdiChanges(pdi, newStatus); 
                    }
                    return pdi;
                });
            
                this.selectedRows = [];
                this.isModalOpen = false;
                this.showModalSpinner = false;

                console.log('completed processing');
            })
        .catch(error => {
            console.log('PDI update failed');
            console.log(error);
            self.isModalOpen = false;
            self.showModalSpinner = false;
        });

        
    }

    applyPdiChanges(pdi, newStatus) {

        pdi.PDI_Status__c = newStatus;

        if(newStatus === 'Completed') {
            pdi.PDI_Completion_Date__c = this.pdiCompletionDate;
        }
        

        return pdi;
    }

    //submission handlers

    handleModalSubmission() {
        // Modal Save never called. Placeholder here if needed.
    }

    handleAcceptPdiRequests() {
        this.updatePdi('Approved');
    }

    handleRejectPdiRequests() {
        this.updatePdi('Declined');
    }

    handleCompletPdiRequests() {
        this.updatePdi('Completed');
    }
    //pp
    handleCancelPdiRequests(){
     this.updatePdi('Cancelled');   
    }

    // Modal Buttons
    handleApproveDeclinePdiButtonClick() {
        this.showNewPdiRequestContent = !this.selectedRowsIsEmpty;
        this.isModalOpen = true;
    }

    //pp
    handleCancelledPdiButtonClick() {
       // this.showCancelledRequests = !this.selectedRowsIsEmpty; showCancelledRequestContent
       this.showCancelledRequestContent = !this.selectedRowsIsEmpty;
        this.isModalOpen = true;
    }

    handleCompleteDeclinePdiButtonClick() {
        this.showApprovedRequestContent = !this.selectedRowsIsEmpty;
        this.isModalOpen = true;
    }

    handleModalClose() {
        this.resetModalContentViews();
        this.isModalOpen = false;
    }

    resetModalContentViews() {
        this.showNewPdiRequestContent = false;
        this.disableModalSubmit = true;
        this.showCancelledRequestContent = false;
        this.showApprovedRequestContent = false;
        this.showDeclinedRequests = false;
        this.showCompletedRequests = false;
        this.showCancelledRequests = false;
        //any input vars
        
    }

    handleActionButtonVisibility () {

        this.approveDeclineActionButton = (
            this.viewNewRequest && 
            this.userPermissions.hasPdiRequestAgencyActionsUser === true
        );

        this.completeDeclineActionButton = (
            this.viewApprovedRequests && 
            this.userPermissions.hasPdiRequestAgencyActionsUser === true
        );
        //pp
        this.cancelActionButton = (
            (this.viewNewRequest || this.viewApprovedRequests) && (this.userPermissions.hasPdiRequestRetailerActionsUser === true || 
            this.userPermissions.hasPdiRequestNscActionsUser === true)
           // this.viewCancelledRequests && 
           // this.userPermissions.hasPdiRequestAgencyActionsUser === true
        );


        
    }

    handlePdiCompletionDateChange(event) {
        this.pdiCompletionDate = event.detail.value; //YYYY-MM-DD
        this.disableCompletePdiButton = (this.pdiCompletionDate == null || this.pdiCompletionDate == '');
    }

}