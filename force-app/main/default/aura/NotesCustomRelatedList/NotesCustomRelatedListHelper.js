({
	fetchAllNotes : function(component, event, helper) {
		var action = component.get("c.fetchAllRelatedNotes"); 
        action.setParams({
            ParentId: component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.ListOfNotes", response.getReturnValue());                
            }
            else if(state === "ERROR"){
                console.log('A problem occurred: ' + JSON.stringify(response.error));
            }
        });
        var spinner = component.find('Id_spinner');
        $A.util.addClass(spinner, "slds-hide"); 
        $A.enqueueAction(action);
	}
})