({
    doInit : function(component, event, helper) {
		helper.getFieldNames(component, event, helper);
        helper.getIfOppClosed(component, event, helper);
	},

    handleLoad: function(cmp, event, helper) {
        cmp.set('v.showSpinner', false);
    },

    handleSubmit: function(cmp, event, helper) {
        cmp.set('v.disabled', true);
        cmp.set('v.showSpinner', true);
    },

    handleError: function(cmp, event, helper) {
        // errors are handled by lightning:inputField and lightning:nessages
        // so this just hides the spinnet
        cmp.set('v.disabled', false);
        cmp.set('v.showSpinner', false);
        cmp.find('notifLib').showToast({
            "title": "Something has gone wrong!",
            "message": event.getParam("detail"),
            "variant": "error"
        });
    },

    handleSuccess: function(cmp, event, helper) {
        cmp.set('v.disabled', false);
        cmp.set('v.showSpinner', false);
       var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "type":"success",
                        "message": $A.get("$Label.c.LC_COOP_The_Record_Has_Been_Updated_Successfully")
                    });
                    toastEvent.fire();
    }

});