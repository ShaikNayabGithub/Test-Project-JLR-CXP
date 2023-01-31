({
    handleQMSPFilterCmp: function(component, event, helper) {
        var action = component.get('c.get_QMSP_Record');
        action.setParams({
            searchRegion: component.get("v.chosenRegion"),
            searchMarket: component.get("v.chosenCountry"),
            searchYear:   component.get("v.chosenYear"),
            searchBrand:  component.get("v.chosenBrand"),
            searchQuarter:component.get("v.chosenQuarter"),
            searchModel:  component.get("v.chosenModel")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (response.getReturnValue() != null) {
                if (state === "SUCCESS") {
                    component.set("v.isRecord", true);
                    component.set('v.requestedQMSPRecord', response.getReturnValue());
                    component.set('v.requestedQMSPId', response.getReturnValue().Id);
                    component.set('v.BudgetAmountCon', response.getReturnValue().convertedBdgtAmount);
                    if (response.getReturnValue().VME_Under_Over_Run__c > 0) {
                        component.set("v.UO", true);
                        component.set("v.uorun", true);
                    } else if (response.getReturnValue().VME_Under_Over_Run__c == 0) {
                        component.set("v.UO", false);
                    } else {
                        component.set("v.UO", true);
                        component.set("v.uorun", false);
                    }
                }
            } else {
                component.set("v.isRecord", false);
                component.set("v.isEdit", false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "ERROR",
                    "message": "No QMSP record found.Please refine your filters!",
                    "type": "error",
                    "duration": '10000',
                    "mode": "dismissible"
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
        var action = component.get('c.get_User_Currency');
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.UserCurrency", response.getReturnValue());
            } else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "ERROR",
                    "message": "Something went wrong!",
                    "type": "error",
                    "duration": '10000',
                    "mode": "dismissible"
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
        
    },
    save_QMSP: function(component, event, helper) {
        var adjustPUAmount = component.find("adjustedPU").get("v.value");
        var adjustedVol = component.find("AdjustedVolume").get("v.value");
        /*Commneted by Sumit Kumar on 16/08/2019
        Reason : Component failure due to Reason field commented*/
        //var reason = component.find("reason").get("v.value");
        var retailVolume = component.find("retailVol").get("v.value");
        var regexp = /^\d+(\.\d{1,2})?$/;
        //console.log("regex returns " + regexp.test(adjustPUAmount));

        if(adjustedVol % 1 != 0){
this.raiseToast(component, event, helper,"Invalid Volume","Decimals are not allowed on volume","error");
        }else{
            if(regexp.test(adjustPUAmount)){
        if( adjustPUAmount!=undefined && adjustedVol!=undefined && retailVolume!=undefined){// && (reason!=undefined && reason!="")){//by sumit
        if( adjustPUAmount>0 && adjustedVol>0 && retailVolume>0){
            var action = component.get('c.updt_QMSP_Record');
            action.setParams({
                recId: component.get("v.requestedQMSPRecord.Id"),
                adjPUAmt: adjustPUAmount,
                adjVol : adjustedVol,
                campaignrec: component.get("v.requestedQMSPRecord"),
                retailVolm : retailVolume
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    if (response.getReturnValue().Status == "SUCCESS") {
                        //console.log(response.getReturnValue());
                        component.set("v.isEdit", false);
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "message": "The record has been updated successfully.",
                            "type": "success",
                            "duration": '10000',
                            "mode": "dismissible"
                        });
                        toastEvent.fire();
                        this.handleQMSPFilterCmp(component, event, helper);
                    } else {
                        //console.log(response.getReturnValue());
                        component.set("v.isEdit", true);
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": 'An error occured during updating record !!',
                            "message": response.getReturnValue().ErrorMessage,
                            "messageTemplate": response.getReturnValue().ErrorMessage,
                            "duration": '10000',
                            "key": 'info_alt',
                            "type": 'error',
                            "mode": 'dismissible'
                        });
                        toastEvent.fire();
                    }
                    
                    
                } else {
                    component.set("v.isEdit", true);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Something went wrong!!",
                        "message": "An error occured during updating record. Please try again.",
                        "type": "error",
                        "key": 'info_alt',
                        "duration": '10000',
                        "mode": "dismissible"
                    });
                    toastEvent.fire();
                }
                component.set("v.isRecord", false);
                component.set("v.isEdit", false);
            });
            $A.enqueueAction(action);
        }else if(retailVolume==0){
            this.raiseToast(component, event, helper,"ERROR","Invalid retailer volume","error");
        }else if(adjustPUAmount.length>16 && !(adjustPUAmount<0)){
this.raiseToast(component, event, helper,"An error occured during updating record.","Adjusted P/U Amount too long!!!","error");

        }else{
            this.raiseToast(component, event, helper,"An error occured during updating record.","Invalid!! Please enter valid data","error");
        }
        }
    }else{
        this.raiseToast(component, event, helper,"Invalid PU amount","Decimals allowed upto two decimals only","error");
    }
    }
    },
    raiseToast: function(component, event, helper,title,message,type){
        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": title,
                            "message": message,
                            "type": type,
                            "duration": '10000',
                            "mode": "dismissible"
                        });
                        toastEvent.fire();
    }
})