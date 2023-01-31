({
	doInit : function(component, event, helper) {
		var recordaction = component.get("c.isLocked");
        recordaction.setParams({
            recordId: component.get("v.recordId")
        });
        recordaction.setCallback(this, function(response){
            var result = response.getReturnValue();
            component.set("v.locked", result);
        });
        $A.enqueueAction(recordaction);
        var useraction = component.get("c.UserCanUnlockRecord");
        useraction.setParams({
            sobjectName: component.get("v.recordTypeName")
        });
        useraction.setCallback(this, function(response){
            var result = response.getReturnValue();
            component.set("v.userCanUnlock", result);
        });
        $A.enqueueAction(useraction);
	},
    unlock : function(component, event, helper) {
        var action = component.get("c.UnlockRecord");
        action.setParams({
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var result = response.getReturnValue();
            if(result){
                component.set("v.locked", false);
            }
        });
        $A.enqueueAction(action);
    }
})