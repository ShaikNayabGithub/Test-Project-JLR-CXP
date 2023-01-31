import {wire, track, LightningElement, api} from 'lwc';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import LightningAlert from 'lightning/alert';
import korAddrFindModal from 'c/korAddressFinderModal';
import BILLING_STREET_FIELD from '@salesforce/schema/Account.BillingStreet';
import BILLING_CITY_FIELD from '@salesforce/schema/Account.BillingCity';
import BILLING_STATE_FIELD from '@salesforce/schema/Account.BillingState';
import BILLING_COUNTRY_FIELD from '@salesforce/schema/Account.BillingCountry';
import BILLING_POSTALCODE_FIELD from '@salesforce/schema/Account.BillingPostalCode';
import MAILING_STREET_FIELD from '@salesforce/schema/Account.PersonMailingStreet';
import MAILING_CITY_FIELD from '@salesforce/schema/Account.PersonMailingCity';
import MAILING_STATE_FIELD from '@salesforce/schema/Account.PersonMailingState';
import MAILING_COUNTRY_FIELD from '@salesforce/schema/Account.PersonMailingCountry';
import MAILING_POSTALCODE_FIELD from '@salesforce/schema/Account.PersonMailingPostalCode';
import ID_FIELD from '@salesforce/schema/Account.Id';

const fields = [BILLING_STREET_FIELD, BILLING_CITY_FIELD, BILLING_STATE_FIELD, BILLING_COUNTRY_FIELD, BILLING_POSTALCODE_FIELD, MAILING_STREET_FIELD, MAILING_CITY_FIELD, MAILING_STATE_FIELD, MAILING_COUNTRY_FIELD, MAILING_POSTALCODE_FIELD];
export default class KorAddressFinder extends LightningElement {
    
    @api recordId;  // no recordId = guestbook
    @api isLoaded = false;  // control spinner

    @track error;
    @track displayAddr = {};
    originalAddr = {};
    
    detailAddr = ''; // detail address input field
    showFooter = false; // footer : cancel & save button, detail input field
    isCommunity;

    addressTypeValue = ['billing', 'mailing'];

    get options() {
        return [
            { label: '청구지 주소', value: 'billing' },
            { label: '우편함 주소', value: 'mailing' },
        ];
    }

    connectedCallback(){
        // console.log('window.location.origin', window.location.origin);
        const url = new URL(window.location.origin);
        // console.log('url.hostname', url.hostname);
        this.isCommunity = (url.hostname === 'retailers.force.com');
    }

    @wire(getRecord, { recordId: '$recordId', fields })
    wiredAccount(wireResult) {
        const { error, data } = wireResult;
        if (data) {
            this.originalAddr.streetBillingAddr = data.fields.BillingStreet.value;
            this.originalAddr.cityBillingAddr = data.fields.BillingCity.value;
            this.originalAddr.stateBillingAddr = data.fields.BillingState.value;
            this.originalAddr.postalBillingAddr = data.fields.BillingPostalCode.value;
            this.originalAddr.countryBillingAddr = data.fields.BillingCountry.value;
            this.originalAddr.streetMailingAddr = data.fields.PersonMailingStreet.value;
            this.originalAddr.cityMailingAddr = data.fields.PersonMailingCity.value;
            this.originalAddr.stateMailingAddr = data.fields.PersonMailingState.value;
            this.originalAddr.postalMailingAddr = data.fields.PersonMailingPostalCode.value;
            this.originalAddr.countryMailingAddr = data.fields.PersonMailingCountry.value;
            this.displayAddr = {...this.originalAddr};
            this.error = undefined;
        } else if (error) {
            this.error = error;
            console.log('error', error);
        }
    }

    handleChange(e) {
        this.addressTypeValue = e.detail.value;
    }

    async handleClick() {
        this.showFooter = true;
        await korAddrFindModal.open({
            size: 'small',
            isCommunity : this.isCommunity
        })
        .then((selectedAddr) => {
            if (selectedAddr) {
                this.displayAddr.streetAddr = selectedAddr.streetAddress;
                this.displayAddr.cityAddr = selectedAddr.cityAddress;
                this.displayAddr.stateAddr = selectedAddr.stateAddress;
                this.displayAddr.postalAddr = selectedAddr.postalCodeAddress;
            } else {
            }
        });
    }

    handleBlur(event){
        this.detailAddr = event.target.value;
    }

    handleCancel() {
        this.showFooter = false;
        this.displayAddr = {...this.originalAddr};
        this.detailAddr = '';
    }

    handleSave() {
        if (!this.displayAddr.stateAddr) {
            // throw new Error("Whoops!");
            this.openAlert('주소를 선택해 주세요.', 'warning', 'Error!');
            return
        }
        if (this.addressTypeValue.length == 0) {
            this.openAlert('주소 유형을 선택해 주세요.', 'warning', 'Error!');
            return
        }
        
        this.displayAddr.streetAddr = this.displayAddr.streetAddr + ' ' +  this.detailAddr;
        if(this.recordId) {
            var updatefields = {};
            updatefields[ID_FIELD.fieldApiName] = this.recordId;
            
            if(Object.values(this.addressTypeValue).includes("billing")){
                updatefields[BILLING_STREET_FIELD.fieldApiName] = this.displayAddr.streetAddr;
                updatefields[BILLING_CITY_FIELD.fieldApiName] = this.displayAddr.cityAddr;
                updatefields[BILLING_STATE_FIELD.fieldApiName] = this.displayAddr.stateAddr;
                updatefields[BILLING_COUNTRY_FIELD.fieldApiName] = '대한민국';
                updatefields[BILLING_POSTALCODE_FIELD.fieldApiName] = this.displayAddr.postalAddr;
            }
            if(Object.values(this.addressTypeValue).includes("mailing")) {
                updatefields[MAILING_STREET_FIELD.fieldApiName] = this.displayAddr.streetAddr;
                updatefields[MAILING_CITY_FIELD.fieldApiName] = this.displayAddr.cityAddr;
                updatefields[MAILING_STATE_FIELD.fieldApiName] = this.displayAddr.stateAddr;
                updatefields[MAILING_COUNTRY_FIELD.fieldApiName] = '대한민국';
                updatefields[MAILING_POSTALCODE_FIELD.fieldApiName] = this.displayAddr.postalAddr;
            }
            const recordInput = { fields :  updatefields };

            this.isLoaded = true; // run spinner
            updateRecord(recordInput)
            .then(() => {
            })
            .catch( error  => {
                console.log(error);
            })
            .finally(() => {
                this.isLoaded = false;  // close spinner
            });

        } else {
            const addressEvent = new CustomEvent('saveaddress', {
                detail: this.displayAddr
            });
            this.dispatchEvent(addressEvent);
        }
        this.detailAddr = '';
        this.addressTypeValue = ['billing', 'mailing'];
        this.showFooter = false;
    }

    async openAlert(message, theme, label) {
        await LightningAlert.open({
            message: message,
            theme: theme, // a red theme intended for error states
            label: label // this is the header text
        });
    }
    

}