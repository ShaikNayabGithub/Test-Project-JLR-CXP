({
    getServicePlansHelper : function(component, event, helper) {
        var action = component.get("c.getServicePlans");
        var assetInputId = component.get("v.assetInputId");
        action.setParams({'assetId': assetInputId});
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS') {
                var resp = response.getReturnValue();
                console.log('resp --> '+JSON.stringify(resp));
                component.set("v.product",resp);
            }
        });
        $A.enqueueAction(action);
    }
})