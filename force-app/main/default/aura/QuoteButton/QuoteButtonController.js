({
    doInit: function (component, event, helper) {
        component.set('v.subscription', null);
        const empApi = component.find('empApi');
        const errorHandler = function (message) {
            console.error('Received error ', JSON.stringify(message));
        };
        helper.publishEvent(component);
        helper.subscribe(component, event, helper);
    }
});