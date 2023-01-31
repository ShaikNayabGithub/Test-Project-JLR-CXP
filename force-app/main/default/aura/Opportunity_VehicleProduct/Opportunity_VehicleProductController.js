({
    handleSuccess : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "type": "success",
            "message": "Opportunity Product has been updated"
        });
        toastEvent.fire();
    },
    handleError : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Error",
            "type": "error",
            "message": "Opportunity Product could not be updated"
        });
        toastEvent.fire();
    }
})