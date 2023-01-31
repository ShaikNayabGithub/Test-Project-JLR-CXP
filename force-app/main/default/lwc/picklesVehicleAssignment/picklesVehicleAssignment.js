/**
 * Created by Ethan Sargent on 30/10/19.
 */

import {LightningElement, track, wire, api} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getAssetsAssignedToHeadOffice
    from '@salesforce/apex/PicklesVehicleAssignmentController.getAssetsAssignedToHeadOffice'
import reassignAssets from '@salesforce/apex/PicklesVehicleAssignmentController.reassignAssets'
import getDealersFromSearchKey from '@salesforce/apex/PicklesVehicleAssignmentController.getDealersFromSearchKey'
import {refreshApex} from '@salesforce/apex'

// Delay used for apex method to retrieve dealers from the database.
const DELAY = 300;

export default class PicklesVehicleAssignment extends LightningElement {


    fieldHeaderList = [
        'VIN',
        'Handover Date',
        'Make',
        'Model Detail',
        'Registration',
        'Common Type of Sale'
    ];

    assetIds = {};
    VinDict = {};
    VinList = [];

    _wiredResult = {};
    @track assetList = {};
    @track openModal;
    @track dealerSearchKey = '';
    @track dealerName;
    @track selectedDealer = null;
    @track dealerInformationList;
    @track confirmModal;
    @track vehicleDisplayText;
    @track numberSearchKey = '';
    @track MakeKey = '';

    @wire(getAssetsAssignedToHeadOffice, {SearchKey: '$numberSearchKey', MakeKey: '$MakeKey'})
    setAssetList(result) {
        this._wiredResult = result;
        if (result.data) {
            this.assetList.data = result.data;
            this.assetList.error = undefined;
            for (let i = 0; i < this.assetList.data.length; i++) {
                this.assetList[i].isChecked = Object.keys(this.VinDict).contains(this.assetList.data.VINString);
            }
        }
        if (result.error) {
            this.assetList.error = result.error;
            console.log(JSON.stringify(result.error));
            this.assetList.data = undefined;
        }
    };

    connectedCallback() {
        this.assetIds = {};
        this.VinDict = {};
        this.assetIds.length = 0;
        this.vehicleDisplayText = '1 vehicle';
    }

    renderedCallback() {
        console.log(this.assetIds);
    }


    handleCheckboxChange(e) {
        console.log('>> handleCheckboxChange');
        if (e.currentTarget.checked) {
            this.assetIds[e.currentTarget.value] = 1;
            this.VinDict[e.currentTarget.dataset.vin] = 1;
            this.assetIds.length++;
        } else {
            console.log('Attempt to pop value');
            try {
                delete this.assetIds[e.currentTarget.value];
                delete this.VinDict[e.currentTarget.dataset.vin];
            } catch (e) {
                console.log('Error deleting key: ' + e);
            }
            this.assetIds.length--;
        }
        this.VinList = [];
        this.VinList = Object.keys(this.VinDict);
        console.log('VINLIST: ' + this.VinList);
        console.log('VINDICT: ' + JSON.stringify(this.VinDict));
        this.vehicleDisplayText = this.assetIds.length + ((this.assetIds.length > 1 || this.assetIds.length === 0) ? ' vehicles' : ' vehicle');
    }

    handleAssignmentButton(e) {
        let assetIds = this.assetIds;
        if (assetIds.length === 0) {
            console.log('assetIds length = ' + assetIds.length);
            const showError = new ShowToastEvent({
                title: 'Error',
                message: 'You must select at least one asset before assigning to a dealer.',
                variant: 'error'
            });
            this.dispatchEvent(showError);
        } else {
            console.log('assetId length = ' + assetIds.length);
            console.log('openModal = true');
            this.openModal = true;
        }

    }

    handleModalCancel() {
        this.dealerSearchKey = '';
        this.openModal = false;
        this.confirmModal = false;
    }

    // This method is debounced to avoid a very large number of apex calls, given
    // a delay of DELAY milliseconds.
    handleDealerNameChange(e) {
        window.clearTimeout(this.delayTimeout);
        const dealerNameSearch = e.currentTarget.value;

        this.delayTimeout = setTimeout(() => {
            this.dealerSearchKey = dealerNameSearch;
            this.handleNameSearch();
        }, DELAY)
    }

    handleNameSearch() {
        let request = {};
        request.dealerSearchKey = this.dealerSearchKey;

        getDealersFromSearchKey({requestDto: request})
            .then(result => {
                this.dealerInformationList = result.dealers;
                console.log(result);
            }).catch(error => {
            console.log(error);

        })


    }


    handleDealerSelect(e) {
        this.selectedDealer = e.currentTarget.dataset.dealerid;
        console.log('dealerId:' + this.selectedDealer);
        this.dealerName = e.currentTarget.dataset.dealername;
        console.log('dealerName:' + this.dealerName);
        this.openModal = false;
        this.confirmModal = true;
        console.log('VINLIST: ' + this.VinList);
    }

    handleModalBack() {
        this.confirmModal = false;
        this.openModal = true;
    }

    handleReassignment() {
        let request = {};
        request.assetIds = Object.keys(this.assetIds);
        request.dealerId = this.selectedDealer;
        reassignAssets({request: request})
            .then(result => {
                if (result === true) {
                    this.handleModalCancel();
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Assets reallocated successfully',
                            variant: 'success'
                        })
                    );
                    return this.refreshAssets()
                } else {
                    console.log('DML Exception Occurred');
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'An error occurred reassigning these assets. Please try again.',
                            variant: 'error'
                        })
                    );
                }
            })
            .catch(error => {
                console.log(error);
                const showError = new ShowToastEvent({
                    title: 'Error',
                    message: 'An unexpected error occurred. Please try again.',
                    variant: 'error'
                });
                this.dispatchEvent(showError);
            })
    }

    refreshAssets() {
        this.assetIds = {};
        this.VinDict = {};
        this.VinList = [];
        this.assetIds.length = 0;
        this.vehicleDisplayText = '1 vehicle';
        this.dealerSearchKey = '';
        return refreshApex(this._wiredResult);
    }

    isInAssetList(e) {

        let id = e.currentTarget.value;

        console.log('id ' + id + ' in this.assetIds.keys == ' + id in this.assetIds.keys);
        if (id in this.assetIds.keys) {
            e.currentTarget.setAttribute('checked', true)
        }

        return true;

    }

    handleSearchKeyChange(e) {
        // This method is debounced to minimise a large number of apex calls through the wire service.
        window.clearTimeout(this.delayTimeout);
        const searchKey = e.currentTarget.value;
        this.delayTimeout = setTimeout(() => {
            this.numberSearchKey = searchKey;
        }, DELAY);
    }
}