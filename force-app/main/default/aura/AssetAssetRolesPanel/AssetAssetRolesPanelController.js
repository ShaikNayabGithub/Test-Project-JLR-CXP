({
	doInit : function(component, event, helper) {
        if(component.get("v.recordId") != null){
            var action = component.get("c.getAssetRoles");
            action.setParams({assetId : component.get("v.recordId")});
            action.setCallback(this, function(response) {
               var state = response.getState();
                if(state === "SUCCESS") {
                    component.set("v.assetRoles", action.getReturnValue());
                }
            });
            $A.enqueueAction(action);
        }
    },
    navigateToRole : function(component, event, helper) {
        var roleId = event.currentTarget.name;
        if(roleId != null){
            var navEvt = $A.get("e.force:navigateToSObject");
    		navEvt.setParams({
      			"recordId": roleId
    		});
    		navEvt.fire();
        }
    }
})