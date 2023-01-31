/**
 * Created by GrantMillgate-EasyTe on 14/11/2019.
 */

import {LightningElement, api, track} from 'lwc';

export default class MilestoneModal extends LightningElement {

@api milestoneDisplayName;
@api milestoneApiName;

    handleCreateTaskClick(){

        let milestone = this.buildMilestone();
        const selectedEvent = new CustomEvent('milestonecreatetaskclicked', {
            detail: milestone

        });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);

    }

    handleCreateEventClick(){
        let milestone = this.buildMilestone();
        const selectedEvent = new CustomEvent('milestonecreateeventclicked', {
            detail: milestone

        });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }

    buildMilestone() {
        let milestone = {};
        milestone.milestoneApiName = this.milestoneApiName;
        milestone.milestoneDisplayName = this.milestoneDisplayName;
        return milestone;
    }
}