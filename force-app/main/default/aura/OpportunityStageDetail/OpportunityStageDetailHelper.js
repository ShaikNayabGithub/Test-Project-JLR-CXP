({
	getFieldNames : function(component, event, helper) {
         console.log('test');
		 var action = component.get('c.getStageFieldNames');
        action.setParams({  opportunityId : component.get("v.recordId")  });
        action.setCallback(component, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS'){
                component.set("v.fieldsList",response.getReturnValue());
                console.log(response.getReturnValue());
            } 
        });
        $A.enqueueAction(action); 
	},
	getIfOppClosed : function(component, event, helper) {
		var action = component.get('c.isOpportunityClosed');
        action.setParams({opportunityId : component.get("v.recordId")});
        action.setCallback(component, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS'){
                var isclosed = response.getReturnValue();
                if(isclosed){
                	component.set("v.disabled", true);
                    component.set("v.lostdisabled", true);
                }
            } 
        });
        $A.enqueueAction(action); 
	}
})