({
	doInit: function(component, event, helper) {
        // $A.get('e.force:refreshView').fire();
        helper.getcurrentLead(component, event, helper);
        helper.getcurrentLeadAccess(component, event, helper);
        helper.getLeadLabels(component, event, helper); 
        //component.find("recordHandler").reloadRecord();
    }, 
    showSpinner : function (component, event, helper) {      
         component.set("v.showSpinner",true);   
    },
    hideSpinner : function (component, event, helper) {      
         component.set("v.showSpinner",false);   
    },handleSaveRecord : function(component, event, helper) {
        let button = event.getSource();
        button.set('v.disabled',true);
        helper.saveCurrentLead(component, event, helper);
    },
    allCommOptOut: function(component, event, helper) { 
        helper.allCommOptOut(component, event, helper, component.get("v.currentLead"));   
    }
    
})