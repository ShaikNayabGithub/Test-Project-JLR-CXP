({
    initQuoteJshelper : function(component, event, helper) {
        const oppId=component.get("v.opportunityId");
        const quoId=component.get("v.QuoteId");
        let action= component.get("c.initQuote");
        action.setParams({"opportunityId": oppId,"quoteId":quoId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                const result=response.getReturnValue();
                component.set("v.quoteInitWrap", result);
                component.set("v.searchVin",result.quoteObj.VIN__c);
                if(oppId==null || oppId==undefined)
                {
                component.set("v.opportunityId", result.quoteObj.Opportunity__c);
                }
                var spinner = component.find('Id_spinner');
                $A.util.addClass(spinner, "slds-hide"); 
            }
        });
        $A.enqueueAction(action);
    },
    
    searchTradeInVin : function(component, searchString, brandId) {
        var action = component.get("c.getTradeInVinApex");
        action.setParams({
            "searchString" : searchString,
            "BrandId": brandId
        });
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                const serverResult = response.getReturnValue();
                component.set("v.trdeInVinResults", serverResult);
                if(serverResult.length>0){
                    component.set("v.openTradeInDropDown", true);
                }
            } else{
                var toastEvent = $A.get("e.force:showToast");
                if(toastEvent){
                    toastEvent.setParams({
                        "title": "ERROR",
                        "type": "error",
                        "message": "Something went wrong!! Check server logs!!"
                    });
                    toastEvent.fire();
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    searchNewVehVin : function(component, searchString, brandId) {
        var action = component.get("c.getTradeInVinApex");
        action.setParams({
            "searchString" : searchString,
            "BrandId": brandId
        });
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                const serverResult = response.getReturnValue();
                component.set("v.newVehVinResults", serverResult);
                if(serverResult.length>0){
                    component.set("v.openNewVehDropDown", true);
                }
            } else{
                var toastEvent = $A.get("e.force:showToast");
                if(toastEvent){
                    toastEvent.setParams({
                        "title": "ERROR",
                        "type": "error",
                        "message": "Something went wrong!! Check server logs!!"
                    });
                    toastEvent.fire();
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    refreshModels: function (component, event, helper) {
        let Alldetails=component.get("v.quoteInitWrap");
        
           var spinner = component.find('Id_spinner');
           $A.util.removeClass(spinner, "slds-hide"); 
            
        let action= component.get("c.getModels");
            action.setParams({"CountryIsoCode":Alldetails.userDetail.countryIsoCode,
                              "brandId":Alldetails.brandId});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                const result=response.getReturnValue();
                Alldetails.Models=result;
                Alldetails.Derivatives=[];
                component.set("v.quoteInitWrap",Alldetails);
                $A.util.addClass(spinner, "slds-hide"); 
            }
        });
        $A.enqueueAction(action); 
    },
    
    generateDoc: function (component, event, helper, qId,lang) {
        
        var spinner = component.find('Id_spinner');
        let action= component.get("c.congaPdfBackgroundMode");
        action.setParams({"quoteId":qId,"filename":"AutoGen","networkId":"","lang":lang});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
               
                const result=response.getReturnValue();
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": result,
                    "slideDevName": "related"
                });
                navEvt.fire();
                $A.get("e.force:closeQuickAction").fire();
                $A.util.addClass(spinner, "slds-hide"); 
            }else if(state === "ERROR"){
               
                var errors = action.getError();
                if (errors) {
                    $A.util.addClass(spinner, "slds-hide");
                    if (errors[0] && errors[0].message) {
                        $A.util.addClass(spinner, "slds-hide");
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({"title":"Error", "type":"error", "message":errors[0].message});
                        toastEvent.fire();
                    }
                }
            }
        });
        $A.enqueueAction(action); 
    },
})