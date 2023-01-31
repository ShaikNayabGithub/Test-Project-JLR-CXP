({
	navigateToRecord : function(component, event, helper) {
        var navRecord = component.get("v.simpleAccount");
        if(navRecord != null && navRecord.OwnerId != null){
			var navEvt = $A.get("e.force:navigateToSObject");
    		navEvt.setParams({
      			"recordId": navRecord.OwnerId
    		});
    		navEvt.fire();
        }
	}
})