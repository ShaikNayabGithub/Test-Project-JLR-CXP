({
	navigateToModelRecord : function(component, event, helper) {
        var navRecord = component.get("v.simpleAsset");
        if(navRecord != null && navRecord.Model__c != null){
			var navEvt = $A.get("e.force:navigateToSObject");
    		navEvt.setParams({
      			"recordId": navRecord.Model__c
    		});
    		navEvt.fire();
        }
	},
	navigateToDerivativeRecord : function(component, event, helper) {
        var navRecord = component.get("v.simpleAsset");
        if(navRecord != null && navRecord.Derivative__c != null){
			var navEvt = $A.get("e.force:navigateToSObject");
    		navEvt.setParams({
      			"recordId": navRecord.Derivative__c
    		});
    		navEvt.fire();
        }
	}
})