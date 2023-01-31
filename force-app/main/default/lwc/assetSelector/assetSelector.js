/**
 * Created by GrantMillgate-EasyTe on 29/11/2019.
 */

import {LightningElement, api, track} from 'lwc';
import GetAssets from '@salesforce/apex/AssetsController.getAssetList';
import SetAssetWithMultiAssignCheck from '@salesforce/apex/AssetsController.SetAssetWithMultiAssignCheck'
import SetAssetForced from '@salesforce/apex/AssetsController.SetAssetForced'
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import {toastErrorOnFail} from 'c/common';

const DELAY = 300;
const SALE_TYPES_NEW = 'new';
const SALE_TYPES_DEMO = 'demo';
const SALE_TYPES_APO = 'apo';
const SALE_TYPES_PRE_OWNED = 'pre-owned';

export default class AssetSelector extends LightningElement {
    @track assets;
    @track doShowSearch = true;
    @track isTooManyResults;
    @track maxResultsSize;
    @track resultsSize;
    @track searchKey;
    @api opportunityId;
    @api inputDisabled = false;

    @api get variantId() {
        return this._variantId;
    }

    set variantId(value) {
        console.log('>> set VariantId(value : ' + value);
        this._variantId = value;
        this.assets = undefined;
        if (value !== undefined && this.isSaleTypeNewOrDemo()) {
            this.updateAssets();
        }
    }

    _variantId;

    @api get saleType() {
        return this._saleType;
    }

    set saleType(value) {
        console.log('>> setSaleType()');
        console.log('value: ' + value);
        if (value) {
            this._saleType = value.toLowerCase();
            if (this._variantId && this.isSaleTypeNewOrDemo()) {
                this.updateAssets();
            }
        }
    }

    _saleType;

    isSaleTypeNewOrDemo(){
        if (this.saleType &&
            (this.saleType === SALE_TYPES_NEW || this.saleType === SALE_TYPES_DEMO)
        ){
            return true;
        }
        return false;
    }

    updateAssets() {
        console.log('>> updateAssets()');
        let request = {};
        request.DerivativeProduct2Id = this.variantId;
        request.SaleType = this.saleType;
        request.SearchKey = this.searchKey;
        console.log('GetAssets - request: ' + JSON.stringify(request));
        toastErrorOnFail(GetAssets(
            {
                request: request
            }
        ))
            .then(result => {
                console.log('Result: ' + JSON.stringify(result));
                this.parseResult(result);
            })
            /*
            .catch(error => {
                console.log('Error: ' + JSON.stringify(error));
            })
            */

        console.log('<< updateAssets()');
    }

    parseResult(result) {
        this.isTooManyResults = false;
        this.resultsSize = result.NumberOfResults;
        if (this.resultsSize === 0){
            this.showInfoToastMsg('No matching assets', 'No assets match the current variant and/or search.');
        }
        this.maxResultsSize = result.MaxResults;
        if (result.IsMaxResultsExceeded){
            this.isTooManyResults = true;
            this.showErrorToastMsg('Too many matching assets');

        }
        let results = [];
        for (let i = 0; i < result.Data.length; i++) {
            let r = result.Data[i];
            let item = {};
            item.Id = r.Id;
            item.DerivativeProduct2Id = r.Attributes.VariantId;
            item.Make = r.Attributes.MakeName;
            item.Model = r.Attributes.ModelAlternative;
            item.ExteriorColour = r.Attributes.ExteriorColour;
            item.Vin = r.Attributes.Vin;
            item.RegistrationNumber = r.Attributes.RegistrationNumber;
            item.Trim = r.Attributes.TrimBadge;
            item.Name = r.Attributes.Name;
            results.push(item);
        }
        this.assets = results;

    }

    showErrorToastMsg(msg) {
        const toast = new ShowToastEvent({
            title: "Error",
            message: msg,
            variant: "error"
        });
        this.dispatchEvent(toast);
    }

    showInfoToastMsg(title,msg) {
        const toast = new ShowToastEvent({
            title: title,
            message: msg,
            variant: "info"
        });
        this.dispatchEvent(toast);
    }

    @track
    showAssetAlreadyAssignedModal = false;

    assetAlreadyAssignedModalTable;

    assetAlreadyAssignedModalProceed;

    assetModelCancel()
    {
        this.showAssetAlreadyAssignedModal = false;
    }



    async handleAssetItemSelected(evt) {
        console.log('>> handleAssetItemSelected()');
        // well do the actual manipulation here
        let result = await toastErrorOnFail(SetAssetWithMultiAssignCheck({
            opportunityId: this.opportunityId,
            assetId: evt.detail.Id
        }))
            .catch(error => {
                console.log('Error: ' + JSON.stringify(error));
                this.showErrorToastMsg('Pricebook Entry is not active, please contact CXP support.');
            });

        this.assetAlreadyAssignedModalTable = result.DuplicateOpportunities;
        this.assetDoesLosePriceProtection = result.DoesLosePriceProtection;
        console.log('this.assetDoesLosePriceProtection = ' + this.assetDoesLosePriceProtection);

        if (this.assetAlreadyAssignedModalTable.length > 0)
        {
            // show modal
            this.showAssetAlreadyAssignedModal = true;
            this.assetAlreadyAssignedModalProceed = async () => {
                await toastErrorOnFail(SetAssetForced({
                    opportunityId: this.opportunityId,
                    assetId: evt.detail.Id,
                    removePriceProtection: this.assetDoesLosePriceProtection
                })).catch(err => {
                    this.showErrorToastMsg('Pricebook Entry is not active, please contact CXP support.');
                });
                this.showAssetAlreadyAssignedModal = false;
                let event = new CustomEvent('update', {});
                this.dispatchEvent(event);
            }
            return;
        }

        let event = new CustomEvent('update', {});
        this.dispatchEvent(event);
        console.log('<< handleAssetItemSelected()');
    }


    createAssetSelectedEvent(detail) {
        let event = new CustomEvent('assetselected', {detail: detail});
        this.dispatchEvent(event);
    }

    handelSearchClick(evt)
    {
        console.log('>> handelSearchClick()');
        console.log('searchKey: ' + this.searchKey);
        this.isTooManyResults = false;
        this.updateAssets();
        console.log('allAssets: ' + JSON.stringify(this.assets));
        console.log('<< handelSearchClick()');
    }

    handleSearchChange(evt)
    {
        console.log('>> handleSearchChange()');
        this.searchKey = evt.currentTarget.value;
        console.log('<< handleSearchChange()');
    }


}