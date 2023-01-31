({
 	cancelRDA : function(component, event, helper) {
        var action = component.get('c.CancelRDA');
        action.setParams({rdaId:component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var toastEvent = $A.get("e.force:showToast");
                if(response.getReturnValue() == 'Success'){
                    toastEvent.setParams({"title":"Success", "type":"info", "message":'RDA successfully cancelled'});
                }
                else{
                    toastEvent.setParams({"title":"Error", "type":"error", "message":response.getReturnValue()});
                }                    
                toastEvent.fire();
                helper.closeQuickAction();
            }                    
        }); 
        $A.enqueueAction(action);
	},
    closeModal : function(component, event, helper) {
        helper.closeQuickAction();
	}
    
})