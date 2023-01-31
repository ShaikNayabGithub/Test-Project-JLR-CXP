({
    invokeVechicleOrderApi : function(component, event, helper) {
        helper.invokeVechicleOrderApi(component, event, helper);
    },
    handleClick : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();
    }
})