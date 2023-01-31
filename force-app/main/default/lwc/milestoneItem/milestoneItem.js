/**
 * Created by GrantMillgate-EasyTe on 14/11/2019.
 */

import {LightningElement,api,track} from 'lwc';

export default class MilestoneItem extends LightningElement {
    @api isChecked = false;
    @api isInProgress = false;
    @api milestoneDisplayName;
    @api milestoneApiName;
    @api relatedMilestone;
    @api recordId;

    handleClick(evt){
        console.log('Click');

        let milestone = this.buildMilestone();
        // Creates the event with the account ID data.
        const selectedEvent = new CustomEvent('milestoneclicked', {
            detail: milestone
        });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }

    buildMilestone() {
        let milestone = {};
        milestone.recordId = this.recordId;
        milestone.relatedMilestone = this.relatedMilestone;
        milestone.milestoneApiName = this.milestoneApiName;
        milestone.milestoneDisplayName = this.milestoneDisplayName;
        milestone.isChecked = this.isChecked;
        return milestone;
    }

    handelCheckboxClicked(evt)
    {
        console.log('Click');
        let lightningInput = this.template.querySelector('.jlr-milestones-checkbox');
        console.log('lightningInput found');
        if (!this.isChecked)
        {
            this.isChecked = true;
            lightningInput.checked = this.isChecked;

            console.log('this.isChecked = ' + this.isChecked);

            let milestone = this.buildMilestone();
            // Creates the event with the account ID data.
            const selectedEvent = new CustomEvent('milestonecheckboxclicked', {
                detail: milestone
            });
            // Dispatches the event.
            this.dispatchEvent(selectedEvent);
        }
        else
        {
            this.isChecked = false;
            lightningInput.checked = this.isChecked;

            console.log('this.isChecked = ' + this.isChecked);

            let milestone = this.buildMilestone();
            // Creates the event with the account ID data.
            const selectedEvent = new CustomEvent('milestonecheckboxclicked', {
                detail: milestone
            });
            // Dispatches the event.
            this.dispatchEvent(selectedEvent);
        }
    }
}