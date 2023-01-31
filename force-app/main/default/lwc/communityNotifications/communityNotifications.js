/**
 * Created by caleb on 23/12/2020.
 */

import GetNotifications from '@salesforce/apex/CommunityNotificationController.GetActiveNotifications'
import MarkAsViewed from '@salesforce/apex/CommunityNotificationController.MarkAsViewed'
import {LightningElement, track} from 'lwc';

export default class CommunityNotifications extends LightningElement
{
    @track showNotification;
    @track notifications;

    async connectedCallback()
    {
        this.notifications = await GetNotifications();
        console.log('GetNotifications() = ' + JSON.stringify(this.notifications));
        this.showNotification = this.notifications.length > 0
    }

    async handelOk()
    {
        let ids = this.notifications.map(x => x.Id);
        await MarkAsViewed({ notificationIds: ids });
        this.showNotification = false;
    }

}