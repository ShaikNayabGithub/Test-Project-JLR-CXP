({
	doInit : function(component, event, helper) {
		var urlString = component.get("v.redirectURL");
        var navEvt = $A.get("e.force:navigateToURL");
        navEvt.setParams({
            "url": urlString
        });
        navEvt.fire();
	}
})