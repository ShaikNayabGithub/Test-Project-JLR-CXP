({    
    
    
    handleSuccess : function(component, event, helper) {
        
        
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({"title":"Success", "type":"success", "message":"Vehicle Now Available"});
        toastEvent.fire();
        
        
    },
    handleError : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        var message = event.getParam('detail');
        toastEvent.setParams({"title":"Error", "type":"error", "message":message});
        toastEvent.fire();
    },
    
    transfer : function(component, event, helper) {
            component.set('v.showSpinner',true);  
        var spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-show");
        var assId = component.get('v.assetFound').Id;
        var action1 = component.get('c.transferAsset');
        action1.setParams({ assId: assId});
        action1.setCallback(this, function(response1) {
            var state1 = response1.getState();
            if (state1 === 'SUCCESS') {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({"title":"Success", "type":"success", "message":"Vehicle Ready To Be Added To Opportunity"});
                toastEvent.fire();                
                component.set('v.showResults',false);    
                var spinner = component.find("mySpinner");
                $A.util.toggleClass(spinner, "slds-hide");
                  component.set('v.showSpinner',false);  
                
            }else{                
                var toastEvent = $A.get("e.force:showToast");                
                toastEvent.setParams({"title":"Error", "type":"error", "message":response1.getError()[0].message});
                toastEvent.fire();
                component.set('v.showResults',true);  
               var spinner = component.find("mySpinner");
                $A.util.toggleClass(spinner, "slds-hide");
                   component.set('v.showSpinner',false);  
            }
        });
        $A.enqueueAction(action1);
    },
    
    
    handleClick : function(component, event, helper) {
        var searchText = component.get('v.searchText');
        var action = component.get('c.searchForIds');
        action.setParams({searchText: searchText});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                if(response.getReturnValue() != null ){
                    component.set('v.assetFound', response.getReturnValue());   
                    component.set('v.showResults',true);  
                    component.set('v.foundResult',true);
                }else{
                    component.set('v.showResults',true);      
                    component.set('v.foundResult',false);  
                }
                
                console.log(ids);
            }else{
                component.set('v.showResults',false);    
            }
        });
        $A.enqueueAction(action);
    }
})