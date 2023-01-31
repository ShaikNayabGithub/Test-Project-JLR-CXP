({
    doInit : function(component, event, helper) {
		helper.doInit(component, event, helper);	
	},
    
    
	searchDealers : function(component, event, helper) {
		helper.searchDealers(component, event, helper);
	},
    
    
    nextPage : function(component, event, helper) {
		helper.nextPage(component, event, helper);
	},
    
    
    previousPage : function(component, event, helper) {
		helper.previousPage(component, event, helper);
	},
    
    
    cancelDealerMix : function(component, event, helper) {
		helper.cancelDealerMix(component, event, helper);
	},
    
    
    saveDealerMix : function(component, event, helper) {
		 helper.showSpinner(component, event, helper);
		 var parentVMECamp = component.get("v.parentVMECampaign");
		 if(component.get("v.schemeApplicable")=='ModelWise' && $A.get("{!$Label.c.New_VME_Parameter}")!=component.get("v.parameterName")  && component.get("v.VMECampDiscreationary") != parentVMECamp.RecordTypeId){
			var action = component.get("c.relatedBundling");
			action.setParams({
			   "scheme":  component.get("v.schemeId"),
			 "model" : parentVMECamp.VME_Model__c,
			 "deleteBundel" : false
		   });
			action.setCallback(this, function(response) {
			   helper.hideSpinner(component, event, helper);
			   var result =response.getReturnValue();
				 if (response.getState() == $A.get("{!$Label.c.Success_Msg}")) {
					helper.saveDealerMix(component, event, helper);
				 }else{
					var toastEvent = $A.get("e.force:showToast");
					toastEvent.setParams({
					  "type": "error",
					  "title": "Something went wrong!",
					  "message": 'Please contact the administrator.'
				  });
				  toastEvent.fire();
			   }
		   });
		   $A.enqueueAction(action);
		 }else{
			helper.hideSpinner(component, event, helper);
		helper.saveDealerMix(component, event, helper);
		 }
	},

	closeConfirmModel : function(component, event, helper) {
			helper.closeConfirmModel(component, event, helper);
	},
})