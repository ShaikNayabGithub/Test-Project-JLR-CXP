({
    handlefilterCmpEvent: function(component, event, helper) {
        var validated = event.getParam("validated");
        console.log(validated);
        if (validated) {                      
            component.set("v.chosenRegion",event.getParam("selectedRegion"));
            component.set("v.chosenCountry",event.getParam("selectedMarket"));
            component.set("v.chosenYear",event.getParam("selectedYear"));
            component.set("v.chosenQuarter",event.getParam("selectedQuarter"));
            component.set("v.chosenBrand",event.getParam("selectedBrand"));
            component.set("v.chosenModel",event.getParam("selectedModel"));
            helper.handleQMSPFilterCmp(component, event, helper);
        } else {
            component.set("v.isRecord", false);
            component.set("v.isEdit", false);
        }
        
    },
    editQMSPRecord: function(component, event, helper) {
        component.set("v.isEdit", true);
    },
    cancelQMSPEditRecord: function(component, event, helper) {
        helper.handleQMSPFilterCmp(component, event, helper);
        component.set("v.isEdit", false);
    },
    saveQMSPRecord: function(component, event, helper) {
        helper.save_QMSP(component, event, helper);
    },
    // this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
    },
    
    // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hide loading spinner    
        component.set("v.Spinner", false);
    }
})