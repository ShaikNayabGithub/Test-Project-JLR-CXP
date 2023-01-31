({
    doInit : function(component, event, helper) {
		component.set("v.showSaveButton", false);
        component.set("v.showSpinnerOverlay", false);
    },
	hideSave : function(component, event, helper) {
		component.set("v.showSaveButton", false); 
        component.set("v.showSpinnerOverlay", false);
        var mileage = component.find("txtMileage").get("v.value");
        if(mileage != null && mileage != ""){
	        component.set("v.mileage", mileage);
        }
        var timing = component.find("txtTiming").get("v.value");
        if(timing != null && timing != ""){
        	component.set("v.timing", timing);
        }
	},
    showSave : function(component, event, helper) {
        component.set("v.showSaveButton", true);
    },
    doSave : function(component, event, helper) {
        component.set("v.showSpinnerOverlay", true);
        component.set("v.showSaveButton", false);
    },
    doSuccess : function(component, event, helper) {
        component.set("v.showSpinnerOverlay", false);
        component.set("v.showSaveButton", false);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({"title":"Success", "type":"success", "message":$A.get("$Label.c.LC_COOP_The_Record_Has_Been_Updated_Successfully")});
    	toastEvent.fire();
    },
    doCancel : function(component, event, helper) {
        event.preventDefault();
        component.set("v.showSpinnerOverlay", false);
        component.set("v.showSaveButton", false);
        document.location.reload();
    },
    handleMileage : function(component, event, helper) {
        var numMileage = component.get("v.mileage");
        if(numMileage != null && numMileage != ""){
            component.find("txtMileage").set("v.value", numMileage);
            component.set("v.showSaveButton", true);
        }
    },
    handleTiming : function(component, event, helper) {
        var numTiming = component.get("v.timing");
        if(numTiming != null && numTiming != ""){
            component.find("txtTiming").set("v.value", numTiming);
            component.set("v.showSaveButton", true);
        }
    }
})