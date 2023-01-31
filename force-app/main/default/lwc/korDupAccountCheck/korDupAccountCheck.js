import { LightningElement, api, wire } from 'lwc';
import getDupAccount from '@salesforce/apex/KORDupAccountController.getDupAccountByNamePhone'
import getUser from '@salesforce/apex/KORDupAccountController.getCurrentUserRole'
export default class KorDupAccountCheck extends LightningElement {

    @api lastName;
    @api phone;
    @api email;
    ownerLastName;
    opptyCnt;
    isDupAccnt;
    viewMessage;
    showButton;

    renderedCallback() {
        getUser()
        .then(result => {
            // console.log(result);
            if( result.indexOf('Partner User') >= 0 ||
                result.indexOf('Partner Manager') >= 0){
                    this.showButton = true;
                }
        })
        .catch(error => {
            console.log(error);
        });


    }

    clickHandler(event){
        getDupAccount({
            lastName : this.lastName,
            phone : this.phone
        })
        .then( result => {
            this.isDupAccnt = result.length === 0 ? false : true;
            if (this.isDupAccnt) {
                this.ownerLastName = result[0].Owner.LastName;
                this.opptyCnt = result[0].Opportunities.length;
            }
        })
        .catch()
        .finally( () => {
            this.viewMessage = true;
        })
    }

}