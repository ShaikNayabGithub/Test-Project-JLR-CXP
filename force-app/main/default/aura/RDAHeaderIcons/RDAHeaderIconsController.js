({
	navigateToAccount : function(component, event, helper) {
        var navRecord = component.get("v.simpleRDA");
        if(navRecord != null && navRecord.AccountId != null){
			var navEvt = $A.get("e.force:navigateToSObject");
    		navEvt.setParams({
      			"recordId": navRecord.AccountId
    		});
    		navEvt.fire();
        }
	},
	navigateToAsset : function(component, event, helper) {
        var navRecord = component.get("v.simpleRDA");
        if(navRecord != null && navRecord.AssetId != null){
			var navEvt = $A.get("e.force:navigateToSObject");
    		navEvt.setParams({
      			"recordId": navRecord.AssetId
    		});
    		navEvt.fire();
        }
	}
})