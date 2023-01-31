({
    getAccountHelper : function(component, event, helper) {
        var action = component.get("c.getAccount");
        action.setParams({"accountId": component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                var currentAccount = response.getReturnValue();
                component.set('v.currentAccount', currentAccount);                
                console.log(component.get('v.currentAccount'));
                if(!currentAccount.Is_Primary__c && (currentAccount.Primary_Account__c != undefined || currentAccount.Primary_Account__c != null)){
                    var getPrimaryAccount = component.get("c.getAccount");
                    getPrimaryAccount.setParams({"accountId": currentAccount.Primary_Account__c});
                    getPrimaryAccount.setCallback(this, function(primaryAccountresponse) {
                        var state = response.getState();
                        if(state === 'SUCCESS'){
                            var currentPrimaryAccount = primaryAccountresponse.getReturnValue();
                            component.set('v.currentPrimaryAccount', currentPrimaryAccount);
                            console.log(component.get('v.currentPrimaryAccount'));
                        } 
                    });
                    $A.enqueueAction(getPrimaryAccount);
                }
                console.log(component.get('v.currentPrimaryAccount'));
            }
        });
        $A.enqueueAction(action);		
    },
    convertRecordTypeHelper : function(component, event, helper) {
         var button = event.getSource();
        button.set('v.disabled',true);
        var action = component.get("c.convertRecordType");
        action.setParams({"accountId": component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                var toastEvent = $A.get("e.force:showToast");
                if(response.getReturnValue() == 'Success'){
                   toastEvent.setParams({
                    "title": $A.get("$Label.c.LC_COOP_Success"),
                    "type":"success",
                    "message": $A.get("$Label.c.LC_COOP_Success")
                });  
                } else {
                   toastEvent.setParams({
                    "title": $A.get("$Label.c.Error"),
                    "type":"error",
                    "message": response.getReturnValue()
                });  
                }
                 
               
                toastEvent.fire();
                //component.set('v.currentAccount', response.getReturnValue());
               // console.log(component.get('v.currentAccount'));
            }
            button.set('v.disabled',false);
        });
        $A.enqueueAction(action);		
    },
})