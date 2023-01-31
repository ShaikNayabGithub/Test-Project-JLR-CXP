({
    invokeVechicleOrderApi : function(component, event, helper) {
        component.set("v.ShowSpinner",true);
        var recId = component.get("v.recordId");
        var action = component.get("c.handleVehicleOrderApi");
        action.setParams({ "recordId" : recId });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("From server: " + JSON.stringify(response.getReturnValue()));
                var reutrnValue = response.getReturnValue();
                if(reutrnValue != null){
                    if(reutrnValue.message != null){
                        component.set("v.message",reutrnValue.message);                        
                    }
                    if(reutrnValue.hasError != null){
                        component.set("v.hasError",reutrnValue.hasError);
                    }
                }
            }else{
                component.set("v.message",'Error Occured..');
            }
            component.set("v.ShowSpinner",false);
        });
        $A.enqueueAction(action);
    }
})