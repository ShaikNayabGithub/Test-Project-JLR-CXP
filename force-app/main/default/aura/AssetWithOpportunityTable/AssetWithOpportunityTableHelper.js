({
    getAssetStatus : function(component) {
        var action = component.get("c.getPicklistValues");
        action.setParams({ "objectName": "User","fieldName":"Country_ISO_Code__c"})
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('Return Value --> '+JSON.stringify(response.getReturnValue()));
                component.set("v.countryIsoCodeList",response.getReturnValue());
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    },
    handleAssetSearchHelper: function (component, event, helper) {
        component.set('v.loading', true);
        var createdFromDate = component.get("v.createdFromDate");
        var createdToDate = component.get("v.createdToDate");
        var selectedVistaStatus = component.get("v.selectedVistaStatus");
        var selectedRetailerId = component.get("v.selectedRetailerId");
        var selectedRetailerName = component.get("v.selectedRetailerName");
        var selectedCommonSalesType = component.get("v.selectedCommonSalesType");
        var selectedCountryIsoCodeList = component.get("v.selectedCountryIsoCodeList");
        var selectedRegion = component.get("v.selectedRegion");
        
        console.log('selectedCountryIsoCodeList --> '+selectedCountryIsoCodeList);
        console.log('createdFromDate --> '+createdFromDate);
        console.log('createdToDate --> '+createdToDate);
        console.log('selectedVistaStatus --> '+JSON.stringify(selectedVistaStatus));
        console.log('selectedRetailerId --> '+selectedRetailerId);
        console.log('selectedRetailerName --> '+selectedRetailerName);
        console.log('selectedRegion --> '+selectedRegion);
        console.log('selectedCommonSalesType --> '+JSON.stringify(selectedCommonSalesType)); 
        
        if(selectedCountryIsoCodeList || selectedVistaStatus || (createdFromDate && createdToDate) || selectedRegion || selectedRetailerId || selectedCommonSalesType){
            console.log('Calling handleAssetSearchAction -->');
            var handleAssetSearchAction = component.get("c.handleAssetSearch");
            handleAssetSearchAction.setParams({
                "createdFromDate": createdFromDate,
                "createdToDate": createdToDate,
                "assetStatus": selectedVistaStatus,
                "salesType": selectedCommonSalesType,
                "isoCodeList":selectedCountryIsoCodeList,
                "region":selectedRegion,
                "retailerId": selectedRetailerId
            })
            handleAssetSearchAction.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    console.log('handle Asset Search Value --> '+JSON.stringify(response.getReturnValue()));
                    var returnVal = response.getReturnValue();
                    if(returnVal != null){
                        if(!returnVal.hasError){
                            if(returnVal.assetWithOppList != null && returnVal.assetWithOppList.length > 0){
                                component.set("v.assetWithOppList",returnVal.assetWithOppList);
                                this.renderPage(component,1,returnVal.assetWithOppList);
                            }else{
                                var emptyArr = [];
                                component.set("v.assetWithOppList",emptyArr);
                            }
                            if(returnVal.assetWithoutOppList != null && returnVal.assetWithoutOppList.length > 0){
                                component.set("v.assetWithOutOppList",returnVal.assetWithoutOppList);
                            }else{
                                var emptyArr = [];
                                component.set("v.assetWithOutOppList",emptyArr);
                            }
                            if(returnVal.assetWithOppCount != null){
                                component.set("v.assetWithOppCount",returnVal.assetWithOppCount);
                            }else{
                                component.set("v.assetWithOppCount",0);
                            }
                            if(returnVal.assetWithoutOppCount != null){
                                component.set("v.assetWithoutOppCount",returnVal.assetWithoutOppCount);
                            }else{
                                component.set("v.assetWithoutOppCount",0);
                            }
                        }else{
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Error Occured!",
                                "mode": "dismissible",
                                "type":"error",
                                "message": returnVal.message
                            });
                            toastEvent.fire();
                        }
                    }
                }
                else {
                    console.log("Failed with state: " + state);
                    console.log("Resp: " + response.getReturnValue());
                }
                component.set('v.loading', false);
            });
            $A.enqueueAction(handleAssetSearchAction);
        }
    },
    renderPage: function(component,pageNumber,assetList) {
        console.log('pageNumber --> '+pageNumber);
        if(!$A.util.isUndefinedOrNull(pageNumber) 
           && !$A.util.isUndefinedOrNull(assetList) 
           && !$A.util.isEmpty(assetList)){
            var pageRecords = assetList.slice((pageNumber-1)*10, pageNumber*10);
            component.set("v.maxPageNumber", Math.floor((assetList.length+9)/10));
            component.set("v.iterableList", pageRecords);
        }else{
            component.set("v.maxPageNumber",0);
            var emptyArr = [];
            component.set("v.iterableList", emptyArr);
        }
    }
})