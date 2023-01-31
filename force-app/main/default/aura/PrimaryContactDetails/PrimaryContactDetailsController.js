({
	handleOnload: function(component, event, helper) {
        var action = component.get("c.getAccountDetail");
        action.setParams({ accountId: component.get("v.recordId") });
        
        action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				component.set("v.accountObj", response.getReturnValue());
			} else if (state === "ERROR") {
				var errors = response.getError();
				console.log(JSON.stringify(errors));
			}
		});
		$A.enqueueAction(action);
    }
})