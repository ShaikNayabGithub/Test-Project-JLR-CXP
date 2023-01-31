({
handleSuccess : function() {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "type": "success",
            "message": "Opportunity has been updated"
        });
        toastEvent.fire();
    },
    handleError : function() {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Error",
            "type": "error",
            "message": "Opportunity could not be updated"
        });
        toastEvent.fire();
    }
})