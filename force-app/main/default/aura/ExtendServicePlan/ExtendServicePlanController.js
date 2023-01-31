({
    init :function (component, event, helper) {
        helper.getServicePlanData(component);
        var action = component.get("c.getPolicyEndDate");
        debugger;
        action.setParams({
            "assetId" : component.get("v.assetInputId"),
        });
        action.setCallback(this,function(response) {
            debugger;
            var state = response.getState();
            if (state === "SUCCESS") {
                const serverResult = response.getReturnValue();
                component.set("v.minDate", serverResult);
                component.set("v.StartDate", serverResult);
                // component.set("v.StartDate",serverResult);
                var spinner = component.find('Id_spinner');
                $A.util.addClass(spinner, "slds-hide"); 
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({"title":$A.get("$Label.c.LC_COOP_Error"), "type":"error", "message":$A.get("$Label.c.SPC_Something_went_wrong")});
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    searchHandler : function (component, event, helper) {
        const searchString = event.target.value;
        if (searchString.length >= 3) {
            //Ensure that not many function execution happens if user keeps typing
            if (component.get("v.inputSearchFunction")) {
                clearTimeout(component.get("v.inputSearchFunction"));
            }
            
            var inputTimer = setTimeout($A.getCallback(function () {
                helper.searchRecords(component, searchString);
            }), 1000);
            component.set("v.inputSearchFunction", inputTimer);
        } else{
            component.set("v.results", []);
            component.set("v.openDropDown", false);
        }
    },
    
    optionClickHandler : function (component, event, helper) {
        
        const indexVar = event.target.closest('li').dataset.id;
        let results=component.get("v.results");
        const selectedValue = event.target.closest('li').dataset.value;
        debugger;
        component.set("v.inputValue", results[indexVar].Product2.Name);
        component.set("v.openDropDown", false);
        component.set("v.selectedOption", results[indexVar].Product2Id);
        component.set("v.selectedPlan", results[indexVar]);
        
    },
    
    clearOption : function (component, event, helper) {
        component.set("v.results", []);
        component.set("v.openDropDown", false);
        component.set("v.inputValue", "");
        component.set("v.selectedOption", "");
        component.set("v.selectedPlan", null);
    },
    
    checkboxSelect : function (component, event, helper) {
        console.log(event.getSource().get('v.checked'));
        console.log(event.getSource().get('v.value'));
        var checkedVal = event.getSource().get('v.checked');
        
        if(checkedVal){
            component.set("v.rentalCar",true);
        }else{
            component.set("v.rentalCar",false);
        }
        console.log('==> '+component.get("v.rentalCar"));
    },
    
    addSPC : function (component, event, helper) {
        let spinner = component.find('Id_spinner');
        var selectedServicePlan = component.get("v.selectedServicePlan");
        var selectedOption = component.get("v.selectedOption");
        var rentalCar = component.get("v.rentalCar");
        var selectedProduct;
        if(selectedServicePlan){
            selectedProduct = selectedServicePlan;          
        }else if(selectedOption){
            selectedProduct =  selectedOption;
        }
        
        console.log('selectedServicePlan --> '+selectedServicePlan);
        console.log('selectedProduct --> '+selectedProduct);
        console.log('selectedOption --> '+selectedOption);
        console.log('rentalCar --> '+rentalCar);
        
        const inputAssetId = component.get('v.assetInputId');
        const inputDate = component.get('v.StartDate');
        var validity = component.find("dateField").get("v.validity");
        if(selectedProduct==null || selectedProduct=='' ){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({"title":$A.get("$Label.c.LC_COOP_Error"), "type":"error", "message":$A.get("$label.c.SPC_Please_select_service_plan")});
            toastEvent.fire();
        }else if(validity.valid){
            $A.util.removeClass(spinner, "slds-hide");
            var actionfunction = component.get('c.addForServicePlanContract');
            actionfunction.setParams({
                assetId: inputAssetId,
                productId:selectedProduct,
                startDate:inputDate,
                rentalCar:rentalCar
            });
            actionfunction.setCallback(this, function(response) {
                debugger;
                var state = response.getState();
                if (state === 'SUCCESS') {
                    console.log('response --> '+JSON.stringify(response.getReturnValue()));
                    if(response.getReturnValue() != null ){
                        $A.util.addClass(spinner, "slds-hide");
                        var actionEvt =component.getEvent("Actionname");
                        actionEvt.setParams({
                            "actionname": 'Close'
                        });
                        actionEvt.fire();
                        var AutoAddExtended = component.get("v.showInput");
                        console.log('AutoAddExtended --> '+AutoAddExtended);
                        if(!AutoAddExtended){
                        var extactionEvt =component.getEvent("Actionname");
                        extactionEvt.setParams({
                            "actionname": 'ExtendedAdded'
                        });
                        extactionEvt.fire();
                        }
                        
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({"title":$A.get("$Label.c.LC_COOP_Success"), "type":"success", "message":$A.get("$Label.c.SPC_Service_Plan_Contract_Successfully_created")});
                        toastEvent.fire();
                    }else{
                        $A.util.addClass(spinner, "slds-hide");
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({"title":$A.get("$Label.c.LC_COOP_Error"), "type":"error", "message":$A.get("$Label.c.SPC_An_Error_Occured_Please_contact_your_Administrator")});
                        toastEvent.fire();
                    }
                    
                }else if(state === "ERROR"){
                    var errors = actionfunction.getError();
                     console.log('errors --> '+JSON.stringify(errors));
                    if (errors) {
                        $A.util.addClass(spinner, "slds-hide");
                        if (errors[0] && errors[0].message) {
                            $A.util.addClass(spinner, "slds-hide");
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({"title":$A.get("$Label.c.LC_COOP_Error"), "type":"error", "message":errors[0].message});
                            toastEvent.fire();
                        }
                    }
                }
            });
            $A.enqueueAction(actionfunction);
            
        }
    },
})