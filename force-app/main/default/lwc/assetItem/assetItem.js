/**
 * Created by GrantMillgate-EasyTe on 29/11/2019.
 */

import {LightningElement, api, track} from 'lwc';

export default class AssetItem extends LightningElement {

    @api asset;

    handleClick(){
        const selectedEvent = new CustomEvent('assetitemselected', {
            detail: this.asset
        });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }
}