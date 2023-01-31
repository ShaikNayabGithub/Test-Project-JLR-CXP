/**
 * Created by GrantMillgate-EasyTe on 16/10/2019.
 */

import {LightningElement, api, track} from 'lwc';
import GetActivities from '@salesforce/apex/ActivitiesController.getActivities';

export default class ActivityTimeLine extends LightningElement {

    @api opportunityId;
    @track tasks;
    @track events;

    connectedCallback() {
        this.doGetActivities();
    }

    doGetActivities(){
        let request = {};
        request.opportunityId = this.opportunityId;
        GetActivities({
            request : request
        })

            .then(result => {
                console.log('Result: ' + JSON.stringify(result));
                this.tasks = result.Tasks;
                this.events = result.Events;
                console.log('Tasks: ' + JSON.stringify(this.tasks));
            })

            .catch(error => {
                console.log('Error: ' + JSON.stringify(error));
            });
    }

}