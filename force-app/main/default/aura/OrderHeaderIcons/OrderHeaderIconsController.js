({
	navigateToRecord : function(component, event, helper) {
        var navRecord = component.get("v.simpleOrder");
        if(navRecord != null && navRecord.AccountId != null){
			var navEvt = $A.get("e.force:navigateToSObject");
    		navEvt.setParams({
      			"recordId": navRecord.AccountId
    		});
    		navEvt.fire();
        }
	}
})