({
	showToast : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        if(recordId != null){
            var action = component.get("c.getMismatchWarningMessage");
            action.setParams({assetId : recordId});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if(state === "SUCCESS") {
                    var showMessage = action.getReturnValue();
                    component.set("v.showWarningMessage", showMessage);
                }
            });
            $A.enqueueAction(action);
        }
	}
})