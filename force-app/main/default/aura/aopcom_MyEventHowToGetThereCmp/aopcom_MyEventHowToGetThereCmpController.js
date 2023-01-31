({
	doInit : function(component, event, helper) {
			    
        var result="";
        var action = component.get("c.getInitial");
        action.setCallback(this, function(action) {
            if (action.getState() === "ERROR") {
                alert("Server Error: " + action.getError()[0].message);
            } else {
                result = action.getReturnValue();  
                component.set("v.googleMapsUrl", result);
            }         
        });
        $A.enqueueAction(action);  
	}
})