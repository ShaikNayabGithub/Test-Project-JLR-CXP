({
	retrieveEvents : function(component, event, helper) {
		var setupEvents = component.get("c.getActivityList");
        setupEvents.setParams({accountId : component.get('v.recordId')});
        setupEvents.setCallback(this, function(eventsDetail) {
            if(eventsDetail.getState() === 'SUCCESS'){
                var allActivities = eventsDetail.getReturnValue();
                component.set('v.JLREvents', allActivities.myEvents);
                component.set('v.JLRTasks', allActivities.myTasks);
            }
        });
        $A.enqueueAction(setupEvents);
	}
})