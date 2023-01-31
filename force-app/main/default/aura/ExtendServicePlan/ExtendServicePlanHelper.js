({
    searchRecords : function(component, searchString) {
        var action = component.get("c.getRecords");
        action.setParams({
            "searchString" : searchString,
        });
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                const serverResult = response.getReturnValue();
                debugger;
                component.set("v.results", serverResult);
                if(serverResult.length>0){
                    component.set("v.openDropDown", true);
                }
            } else{
                var toastEvent = $A.get("e.force:showToast");
                if(toastEvent){
                    toastEvent.setParams({
                        "title": $A.get("$Label.c.LC_COOP_Error"),
                        "type": "error",
                        "message": $A.get("$Label.c.SPC_Something_went_wrong")
                    });
                    toastEvent.fire();
                }
            }
        });
        $A.enqueueAction(action);
    },
    getServicePlanData : function(component) {
        let spinner = component.find('Id_spinner');
        $A.util.removeClass(spinner, "slds-hide"); 
        var assetInputId = component.get("v.assetInputId");
        var action = component.get("c.getAssetData");
        action.setParams({
            "assetId" : assetInputId
        });
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                const serverResult = response.getReturnValue();
                console.log('==> '+JSON.stringify(serverResult));
                if(serverResult 
                   && serverResult.servPlanModel
                   && serverResult.servPlanModel.Extended_Service_Plan__c
                   && serverResult.servPlanModel.Extended_Service_Plan__r
                   && serverResult.servPlanModel.Extended_Service_Plan__r.Name){
                    component.set("v.extServicePlanName",serverResult.servPlanModel.Extended_Service_Plan__r.Name);
                    component.set("v.selectedServicePlan",serverResult.servPlanModel.Extended_Service_Plan__c);
                    component.set("v.showInput",!serverResult.ExtSerPlanAvailable);
                }
                 console.log('==> '+JSON.stringify(serverResult.assetIns));
                if(serverResult 
                   && serverResult.assetIns
                   && serverResult.assetIns.Has_been_a_Rental__c){
                    component.set("v.rentalCar",serverResult.assetIns.Has_been_a_Rental__c);
                    component.set("v.rentalCarDisabled",serverResult.assetIns.Has_been_a_Rental__c);
                }
            }
            let spinner = component.find('Id_spinner');
            $A.util.addClass(spinner, "slds-hide"); 
        });
        $A.enqueueAction(action);
    }
})