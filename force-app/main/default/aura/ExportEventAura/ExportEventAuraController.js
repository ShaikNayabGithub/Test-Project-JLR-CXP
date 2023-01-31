({
    myAction : function(component, event, helper) {
        component.get(v.recordId);
        
        // Close the action panel
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    }
})