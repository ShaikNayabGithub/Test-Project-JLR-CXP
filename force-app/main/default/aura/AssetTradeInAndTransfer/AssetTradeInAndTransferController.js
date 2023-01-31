({
  
	tradeInTransfer : function(component, event, helper) {
        var action = component.get("c.tradeInAsset"); 
        action.setParams({"assetVin": component.get("v.tradeInVin"),
                          "transactionType": component.get("v.value")});
        action.setCallback(this, function(response) {
            var tradedVin = component.get("v.tradeInVin");
            var state = response.getState();
            if(state === 'SUCCESS'){
                if(response.getReturnValue() == 'Success'){
                    component.set("v.tradeInVin", "");
                    helper.fireToast("Success","success",component.get("v.value")+' ' + tradedVin);
                    component.set("v.value","Transfer");
                }
                else{
                    helper.fireToast("Error","error",response.getReturnValue());
                }
            }
        });
        component.set("v.isOpen", false);
        $A.enqueueAction(action);
    },

    tradeIn: function(component, event, helper) {
        component.set("v.isOpen", true);
    },
  
    closeModal: function(component, event, helper) {
        component.set("v.isOpen", false);
        component.set("v.value","Transfer");
    },
        
})