({
    getNewVehVinJs : function (component, event, helper) {
        const searchString=component.get("v.searchVin");
        if (searchString.length >= 3) {
            if (component.get("v.inputSearchNewVeh")) {
                clearTimeout(component.get("v.inputSearchNewVeh"));
            }
            
            var inputTimer = setTimeout($A.getCallback(function () {
                helper.searchNewVehVin(component, searchString);
            }), 1000);
            component.set("v.inputSearchNewVeh", inputTimer);
        } else{
            component.set("v.vehicleResults", []);
            component.set("v.openNewVehDropDown", false); 
        }
        
    },
    
    clearOption :function (component, event, helper) {
        component.set("v.searchVin",null);
        component.set("v.vehicleResults", []);
        component.set("v.openNewVehDropDown", false);
        component.set('v.showResults',false); 
        component.set('v.showTransferSP', false);
        component.set('v.isTransferConfirmModelOpen', false);        
    },
    
    onVehicleSelect : function (component, event, helper) {
        const selectedValue = event.target.closest('li').dataset.value;
        const selectedId = event.target.closest('li').dataset.id;
        helper.getAsset(component,selectedId);
        component.set("v.openNewVehDropDown", false);
        component.set("v.searchVin", selectedValue);
        
    },
    
    transferSP: function (component, event, helper) {
        const servicePlan =component.get("v.ServicePlan");
        var prodId;
        if(servicePlan 
           && servicePlan.Service_Plan_Product__r
           && servicePlan.Service_Plan_Product__r.Id){
            prodId = servicePlan.Service_Plan_Product__r.Id;
        }
        console.log('prodId --> '+prodId);
        const selectedAsset =component.get("v.assetFound");
        var upliftChargeAmount = component.get("v.upliftChargeAmount");
        console.log('upliftChargeAmount --> '+upliftChargeAmount);
        var spinner = component.find('Id_spinner');
        $A.util.removeClass(spinner, "slds-hide"); 
        var action = component.get('c.transferServicePlan');
        action.setParams({
            assetId: selectedAsset.Id,
            servicePlanId:prodId,
            servicePlanContId : servicePlan.Id,
            StartDate:component.get("v.startDate"),
            upliftChargeAmount:upliftChargeAmount,
            refund:component.get("v.refund")
        });
        action.setCallback(this, function(response) {
            debugger;
            var state = response.getState();
            if (state === 'SUCCESS') {
                component.set("v.isTransferConfirmModelOpen", false);
                var actionEvt =component.getEvent("Actionname");
                actionEvt.setParams({
                    "actionname": 'Close'
                });
                actionEvt.fire();
            }else if(state === 'ERROR'){
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        $A.util.addClass(spinner, "slds-hide");
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({"title":$A.get("$Label.c.LC_COOP_Error"), "type":"error", "message":errors[0].message});
                        toastEvent.fire();
                    }
                }
            }
            $A.util.addClass(spinner, "slds-hide"); 
        });
        $A.enqueueAction(action);
    }
})