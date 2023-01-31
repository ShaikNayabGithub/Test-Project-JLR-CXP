({
	showModal:function(component,event,helper){
        component.set("v.showModal",true);
    },
    closeModal:function(component,event,helper){    
        component.set("v.showModal",false);    
    },
    showSpinner : function (component, event, helper) {      
         component.set("v.showSpinner",true);   
    },
    hideSpinner : function (component, event, helper) {      
         component.set("v.showSpinner",false);   
    },
    RDA : function(component, event, helper) {
    	helper.gotoView(component.get("v.showHandoverRDA"));
    },
    checkStock : function(component, event, helper) {
    	helper.gotoView(component.get("v.showCheckStock"));
    },
    tradein : function(component, event, helper) {
    	helper.gotoView(component.get("v.showTradeIn"));
    },
    service : function(component, event, helper) {
    	helper.gotoView(component.get("v.showServiceVehicle"));
    },
    fleetBusiness : function(component, event, helper) {
    	helper.gotoView(component.get("v.showFleetAndBusiness"));
    }
})