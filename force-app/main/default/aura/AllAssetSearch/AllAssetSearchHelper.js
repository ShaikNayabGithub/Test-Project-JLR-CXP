({
    getAsset : function(component, event, helper) {
        var spinner = component.find('Id_spinner');
        $A.util.removeClass(spinner, "slds-hide"); 
        var searchText = component.find("inputSearch").get("v.value");
        var action = component.get('c.searchForIds');
        action.setParams({searchText: searchText});
        action.setCallback(this, function(response) {
            debugger;
            var state = response.getState();
            if (state === 'SUCCESS') {
                console.log('getAsset --> '+JSON.stringify(response.getReturnValue()));
                if(response.getReturnValue() != null ){
                       component.set("v.Complimentary", $A.get("$Label.c.Complimentary"));
                      component.set("v.Extended", $A.get("$Label.c.Extended"));
                    component.set('v.assetId', response.getReturnValue().asset.Id);   
                    component.set('v.assetFound', response.getReturnValue().asset); 
                    component.set('v.servicePlanContracts', response.getReturnValue().spcs); 
                    component.set('v.currentUser', response.getReturnValue().currentUser);
                    component.set('v.missingDateInfo', response.getReturnValue().missingDateInfo);
                    component.set('v.showCancelBtn', response.getReturnValue().showCancelButton);
                    component.set('v.doNotShowNewServicePlanButton', response.getReturnValue().hasActiveServicePlan); 
                    component.set('v.showResults',true);  
                    component.set('v.foundResult',true);
                    component.set("v.showExtendedBtn", response.getReturnValue().showExtendedButton);
                    component.set("v.showExtendedButtonForExpired", response.getReturnValue().showExtendedButtonForExpired);
                    component.set("v.showTransferBtn", !response.getReturnValue().isAutoAdded);
                    component.set("v.isCancel", !response.getReturnValue().isAutoAdded);
                    component.set('v.showNewSP',response.getReturnValue().showNewSP);
                    debugger;
                    console.log(response.getReturnValue());                     
                }else{
                    component.set('v.showResults',true);      
                    component.set('v.foundResult',false); 
                    
                }
            }else{
                component.set('v.showResults',false); 
                
            }
            $A.util.addClass(spinner, "slds-hide"); 
        });
        $A.enqueueAction(action);
    },
    
})