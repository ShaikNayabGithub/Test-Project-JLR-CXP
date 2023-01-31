({
    getSpc : function(component, event, helper) {
        const assetId = component.get('v.assetInputId');
        debugger;
        let action= component.get('c.getAllServicePlan');
        action.setParams({"assetId": assetId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('getSpc state--> '+state);
            if (state === 'SUCCESS') {
                const result=response.getReturnValue();
                console.log('result --> '+JSON.stringify(result));
                if(result){   
                    component.set("v.servicePlans", result);
                }
                var spinner = component.find('Id_spinner');
                $A.util.addClass(spinner, "slds-hide"); 
            }
        });
        $A.enqueueAction(action);
    }
})