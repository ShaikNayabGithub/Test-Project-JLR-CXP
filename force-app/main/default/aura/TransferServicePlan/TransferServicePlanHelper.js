({
    getAsset : function(component, assetId) {
        var spinner = component.find('Id_spinner');
        $A.util.removeClass(spinner, "slds-hide"); 
        
        var servicePlan =component.get("v.ServicePlan");
        console.log('servicePlan --> '+JSON.stringify(servicePlan));
        var prodId;
        if(servicePlan 
           && servicePlan.Service_Plan_Product__r
           && servicePlan.Service_Plan_Product__r.Id){
            prodId = servicePlan.Service_Plan_Product__r.Id;
        }
        console.log('prodId --> '+prodId);
        var action = component.get('c.getAssetDetails');
        action.setParams({
            assetId: assetId,
            prodId:prodId
        });
        action.setCallback(this, function(response) {
            debugger;
            var state = response.getState();
            if (state === 'SUCCESS') {
                console.log('--> '+JSON.stringify(response.getReturnValue()));
                if(response.getReturnValue() != null ){
                    component.set('v.assetFound', response.getReturnValue().asset); 
                    component.set('v.servicePlanContracts', response.getReturnValue().spcs); 
                    component.set('v.showTransferMsg', response.getReturnValue().hasActiveServicePlan);
                    component.set('v.showTransferSP', !response.getReturnValue().hasActiveServicePlan); 
                    component.set('v.startDate', response.getReturnValue().startDate);
                    component.set('v.newServicePlanId', response.getReturnValue().newServicePlanId);
                    component.set('v.refund', response.getReturnValue().refund);
                    component.set('v.existingServicePlanId', response.getReturnValue().existingServicePlanId);
                    component.set('v.showResults',true); 
                    var showTransferMsg =  component.get('v.showTransferMsg');
                    var response = response.getReturnValue();
                    if(response 
                       && response.existingServicePlanPrice
                       && response.newServicePlanPrice
                       && response.upliftChargeAmount
                       && response.currencyIsoCode
                       && response.showConfirmScreen
                       && showTransferMsg == false){
                        component.set("v.isTransferConfirmModelOpen",response.showConfirmScreen);
                        component.set("v.existingServicePlanPrice",response.existingServicePlanPrice);
                        component.set("v.newServicePlanPrice",response.newServicePlanPrice);
                        component.set("v.currencyIsoCode",response.currencyIsoCode);
                        component.set("v.upliftChargeAmount",response.upliftChargeAmount);
                    }
                    
                    const servicePlan =component.get("v.ServicePlan");
                    if(assetId===servicePlan.Vehicle_Id__c)
                    {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({"title":$A.get("$Label.c.LC_COOP_Error"), "type":"error", "message":$A.get("$Label.c.SPC_TO_AND_FROM_Message")});
                        toastEvent.fire(); 
                        component.set('v.showTransferSP', false);
                        component.set('v.showResults',false); 
                    }
                }
            }else{
                component.set('v.showResults',false); 
                
            }
            $A.util.addClass(spinner, "slds-hide"); 
        });
        $A.enqueueAction(action);
    },
    
    searchNewVehVin : function(component, searchString) {
        console.log(searchString);
        var action = component.get("c.getAssetVehicleDetails");
        action.setParams({
            "searchText" : searchString
        });
        action.setCallback(this,function(response) {
            var state = response.getState();
            debugger;
            if (state === "SUCCESS") {
                console.log('--> '+JSON.stringify(response.getReturnValue()));
                const serverResult = response.getReturnValue();
                component.set("v.vehicleResults", serverResult);
                if(serverResult && serverResult.length>0){
                    component.set("v.openNewVehDropDown", true);
                }else{
                    component.set("v.openNewVehDropDown", false);
                }
            } else{
                var erroMsg = response.getError();
                console.log('erroMsg --> '+JSON.stringify(erroMsg));
                var toastEvent = $A.get("e.force:showToast");
                if(toastEvent){
                    toastEvent.setParams({
                        "title": "ERROR",
                        "type": "error",
                        "message": $A.get("$Label.c.SPC_Something_went_wrong")
                    });
                    toastEvent.fire();
                }
            }
        });
        $A.enqueueAction(action);
    },
})