({
    loadComment: function (component, event, helper) {
      
        
        var action = component.get("c.getComment");
        var recordIdParam = component.get("v.recordId");    
       
        action.setParams({recordId: recordIdParam });
        action.setCallback(this, function(response){
           var state = response.getState();
            if(state === "SUCCESS"){
                component.set("v.comment", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    }
})