({
	getUserDataHelper : function(component, event, helper) {
		//get the current logged in user Details
                var action = component.get("c.fetchUser");
                action.setCallback(this, function(response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                                console.log(response.getReturnValue());
                                var storeResponse = response.getReturnValue();
                                // set current user information on userInfo attribute
                                component.set("v.userInfo", storeResponse);
                        }
                });
                $A.enqueueAction(action);
		
	}
})