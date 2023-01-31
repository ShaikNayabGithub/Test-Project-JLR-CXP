({
    subscribe: function (component, event, helper) {
        const empApi = component.find('empApi');
        const channel = component.get('v.channel');
        const replayId = -1;
        const callback = function (message) {
            console.log('Event Received : ' + JSON.stringify(message));
            helper.onReceiveNotification(component, message);
        };
        empApi.subscribe(channel, replayId, $A.getCallback(callback)).then($A.getCallback(function (newSubscription) {
            console.log('Subscribed to channel ' + channel);
            component.set('v.subscription', newSubscription);
        }));
    },

    unsubscribe: function (component) {
        const empApi = component.find('empApi');
        const channel = component.get('v.subscription').channel;
        const callback = function (message) {
            console.log('Unsubscribed from channel ' + message.channel);
        };
        empApi.unsubscribe(component.get('v.subscription'), $A.getCallback(callback));
    },

    onReceiveNotification: function (component, message) {
        const newNotification = {
            time: $A.localizationService.formatDateTime(
                message.data.payload.CreatedDate, 'HH:mm'),
            message: message.data.payload.Message__c,
            status: message.data.payload.Status__c
        };
        this.displayToast(component, newNotification.status, newNotification.message);
    },

    displayToast: function (component, type, message) {
        const toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            title: type,
            type: type,
            message: message
        });
        toastEvent.fire();
    },

    publishEvent: function (component) {
        var action = component.get("c.publishEvent");
        action.setParams(
            {
                "recordId": component.get("v.recordId")
            }
        );
        action.setCallback(this, function (response) {
            let state = response.getState();
            $A.get('e.force:closeQuickAction').fire()
        });
        $A.enqueueAction(action);
    }
});