({
    doInit : function(component, event, helper) {
    helper.doInit(component, event, helper);
   
	},
    
    
    closeConfirmModel: function(component, event, helper) {
        helper.closeConfirmModel(component, event, helper);
    },
    
    
    searchVIN: function(component, event, helper) {
        helper.searchVIN(component, event, helper);
    },
    
    
    nextPage : function(component, event, helper) {
		helper.nextPage(component, event, helper);
	},
    
    
    previousPage : function(component, event, helper) {
		helper.previousPage(component, event, helper);
	},
    
    
    
    
    saveVINMix : function(component, event, helper) {
		helper.saveVINMix(component, event, helper);
    },

    closeSavedModel: function(component, event, helper) {

        component.set("v.isOpenComp", false);

    },
})