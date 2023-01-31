({
	getUserData : function(component, event, helper) {
		helper.getUserDataHelper(component, event, helper);
	},

	navigateToModelRecord : function(component, event, helper) {
		var navRecord = component.get("v.simpleL1QMSP");
	        if(navRecord != null && navRecord.QMSP_Model__c != null){
			var navEvt = $A.get("e.force:navigateToSObject");
	    		navEvt.setParams({
	      			"recordId": navRecord.QMSP_Model__c
	    		});
	    		navEvt.fire();
	        }
	}
})