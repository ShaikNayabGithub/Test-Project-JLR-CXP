({
    doInit : function(component, event, helper) {
      
        // Prepare the action to load account record
        var action = component.get("c.getAccount");
        action.setParams({"accountId": component.get("v.recordId")});
        
        // Configure response handler
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                component.set("v.account", response.getReturnValue());
            } else {
                console.log('Problem getting account, response state: ' + state);
            }
        });
        $A.enqueueAction(action);
    },
    
    handleSaveAcct: function(component, event, helper) {
         component.set('v.loaded', true);
        var ab = component.get("v.newAccount");
        // Prepare the action to create the new contact
        var saveaccountAction = component.get("c.cloneAccount");
        saveaccountAction.setParams({
            "owner": component.get("v.newAccount"),
            "accountId": component.get("v.recordId")
        });
        
        // Configure the response handler for the action
        saveaccountAction.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                
                // Prepare a toast UI message
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "Account Saved",
                     "type":"success",
                    "message": "The new secondary Account was created."
                   
                });
                
                // Update the UI: close panel, show toast, refresh account page
                $A.get("e.force:closeQuickAction").fire();
                resultsToast.fire();
                $A.get("e.force:refreshView").fire();
            }
            else if (state === "ERROR") {
                        component.set('v.loaded', false);
                let errors = response.getError();
                let message = 'Unknown error'; // Default error message
                // Retrieve the error message sent by the server
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                
                console.log('Problem saving Account, response state: ' + state);
                var resultsToast1 = $A.get("e.force:showToast");
                resultsToast1.setParams({
                    "title": "Account Error",
                    "type":"error",
                    "message": message
                });
                 resultsToast1.fire();
                
            }
                else {
                                    component.set('v.loaded', false);
                    console.log('Unknown problem, response state: ' + state);
                }
        });
        
        // Send the request to create the new contact
        $A.enqueueAction(saveaccountAction);
        
        
    },
    
    handleCancel: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})