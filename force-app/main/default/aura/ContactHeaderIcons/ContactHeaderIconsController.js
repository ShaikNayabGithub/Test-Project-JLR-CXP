({
	navigateToRecord : function(component, event, helper) {
        var navRecord = component.get("v.simpleContact");
        if(navRecord != null && navRecord.AccountId != null){
			var navEvt = $A.get("e.force:navigateToSObject");
    		navEvt.setParams({
      			"recordId": navRecord.AccountId
    		});
    		navEvt.fire();
        }
	},
	navigateToOwner : function(component, event, helper) {
        var navRecord = component.get("v.simpleContact");
        if(navRecord != null && navRecord.OwnerId != null){
			var navEvt = $A.get("e.force:navigateToSObject");
    		navEvt.setParams({
      			"recordId": navRecord.OwnerId
    		});
    		navEvt.fire();
        }
	}
})