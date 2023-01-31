({
	doInit : function(component, event, helper) {
		component.find('oppLoader').reloadRecord(true);
	},

	determineButtonVisibility : function(component, event, helper) {
		var action = component.get("c.showVehicleOptionsSearch");
		console.log('fired init');
		action.setCallback(this, function(response) {
			let state = response.getState();
			console.log('got response');
			if(state == 'SUCCESS') {
				console.log('success response');
				var hasPermission = response.getReturnValue();
				console.log('response');
				console.log(response);
				if(hasPermission) {
					console.log('success');
					component.set("v.showVehicleOptions", true);
				}
			}
		});
		$A.enqueueAction(action);
	}
})