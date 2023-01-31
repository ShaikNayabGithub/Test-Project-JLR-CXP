({
        doInit: function(component, event, helper) {
                helper.doInit(component, event, helper);
                helper.getFormatofDate(component, event, helper);
                component.set("v.condition", false);
        },
        regenerateClaims: function(component, event, helper) {
                helper.regenerateClaims(component, event, helper);
        },
        showSpinner: function(component, event, helper) {
                // make Spinner attribute true for displaying loading spinner 
                component.set("v.spinner", true);
        },
        // function automatic called by aura:doneWaiting event 
        hideSpinner: function(component, event, helper) {
                // make Spinner attribute to false for hiding loading spinner    
                component.set("v.spinner", false);
        },
        cancel: function(component, event, helper) {
                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
        },
})