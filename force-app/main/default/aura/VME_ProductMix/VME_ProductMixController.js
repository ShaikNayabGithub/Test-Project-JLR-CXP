({
	doInit : function(component, event, helper) {
	var	parentVME =component.get("v.currentVME");
		var modelData ={'label' : parentVME.VME_Model__r.Name, 'value' :parentVME.VME_Model__c};
		  component.set("v.modelString",modelData );
		    component.set("v.modelValue",modelData.value );
		
		helper.showSpinner(component,event,helper);
		helper.doInit(component, event, helper);
		
	},
    
    
    searchProductsJS : function(component, event, helper) {
    	helper.showSpinner(component,event,helper);
		helper.searchProductsJS(component, event, helper);
	},

	resetProductsJS : function(component, event, helper) {
		helper.resetProductsJS(component, event, helper);
	},
    
    
    saveProductMix : function(component, event, helper) {
		helper.saveProductMix(component, event, helper);
	},
    
    
    nextPage : function(component, event, helper) {
		helper.nextPage(component, event, helper);
	},
    
    
    previousPage : function(component, event, helper) {
		helper.previousPage(component, event, helper);
	},

	handleDealerMixCmpEvt :function(component, event, helper) {
		helper.hideSpinner(component,event,helper);
	         component.set("v.isOpen",false);    
    
	},

	 errorConfirmModel :function(component, event, helper){
	 	helper.errorConfirmModel(component,event,helper);
	},
	
	changeAllSearchList :function(component, event, helper){
		helper.changeAllSearchList(component,event,helper);
   },

   
   changeAllExistingList :function(component, event, helper){
		helper.changeAllExistingList(component,event,helper);
   },

   nextExistPage : function(component, event, helper) {
	helper.nextExistPage(component, event, helper);
},


previousExistPage : function(component, event, helper) {
	helper.previousExistPage(component, event, helper);
},
})