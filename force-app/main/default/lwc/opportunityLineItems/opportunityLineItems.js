/**
 * Created by GrantMillgate-EasyTe on 21/11/2019.
 */

import {LightningElement, track, api} from 'lwc';
import RemoveOpportunityProducts from '@salesforce/apex/OpportunityLineItemsController.remove';
import {toastErrorOnFail} from 'c/common';

export default class OpportunityLineItems extends LightningElement {

    @api opportunityId;
    @api products;

    isInit = false;

    connectedCallback() {
        if (!this.isInit){

        }
    }


    handleOpItemCleared(evt){
        console.log('>> handleOpItemCleared(evt: ' + JSON.stringify(evt) + ')');
        let removedProduct = evt.detail;
        let products = [];
        for (let i = 0; i < this.products.length; i++) {
            let product = this.products[i];
            if (product.Id !== removedProduct.Id){
                products.push(product);
            }
        }
        this.updateProducts(products);
        this.deleteOpportunityProducts(removedProduct);
    }

    deleteOpportunityProducts(removedProduct){
        console.log('>> deleteOpportunityProducts');

        //build request
        let resource = {};
        resource.Id = removedProduct.Id;
        let atts = {};
        atts.OpportunityId = this.opportunityId;
        resource.Attributes = atts;
        let data = [];
        data.push(resource);
        let request = {};
        request.Data = data;
        console.log('Request: ' + JSON.stringify(request));

        toastErrorOnFail(RemoveOpportunityProducts({
            request : request
        }))
            .then(result => {
                console.log('Result: ' + JSON.stringify(result));
            })
            .catch(error => {
                console.log('Errors: ' + JSON.stringify(error));
            });

        console.log('<< deleteOpportunityProducts');
    }

    updateProducts(products){
        // Creates the event with the account ID data.
        const selectedEvent = new CustomEvent('oplineitemremoved', {
            detail: products
        });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);

    }
}