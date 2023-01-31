({
	getRetailerDemoTarget : function(component, event) {
		  var action = component.get("c.getRetailerQuotaTarget");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
               component.set("v.jaguartargetWrapper" , response.getReturnValue()['jaguar']);
                component.set("v.landrovertargetWrapper" , response.getReturnValue()['land rover']);
            }
        });
        $A.enqueueAction(action);
	}
})