({
    handleLost: function(cmp, event, helper) {
  		event.preventDefault(); // stop form submission
  		var eventFields = event.getParam("fields");
  		eventFields["StageName"] = "Lost";
  		cmp.find('mylostform').submit(eventFields);
    },
    handleLostSuccess: function(cmp, event, helper) {
        cmp.set('v.lostdisabled', true);
        cmp.set('v.showSpinner', false);
       var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "type":"success",
                        "message": "Record has been marked as Lost!"
                    });
                    toastEvent.fire();
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
})