({
        doInit: function(component, event, helper) {
               helper.showSpinner(component,event,helper);
                helper.getAllRegionMarketValues(component, event, helper);
                helper.getFinancialYearList(component, event, helper);
                helper.getPicklistList(component, event, helper, 'Quarter');
                helper.getPicklistList(component, event, helper, 'Model');
                helper.getUserDetails(component, event, helper);
        },
       
     
        BrandChangeRequest: function(component, event, helper) {
       
            component.set("v.selectedModel"," ");
            helper.brand_Model_Mapping(component, event, helper);
        },
        reset: function(component, event, helper) {
                component.set("v.selectedYear", " ");
                component.set("v.selectedBrand", " ");
                component.set("v.selectedQuarter", " ")
                component.set("v.selectedModel", " ");
                var storeResponse = component.get("v.userInfo");
                // set current user information on userInfo attribute
                if(storeResponse.Country_ISO_Code__c != ' ' && storeResponse.Country_ISO_Code__c != null && storeResponse.Country_ISO_Code__c != undefined){
                                component.set("v.selectedMarket", storeResponse.Country_ISO_Code__c);
                                component.set("v.makeCountryDisabled",true);
                }else{
                        component.set("v.selectedMarket", " ");
                }
                component.set("v.brandDisabledDependentFld", true);
                var cmpEvent = component.getEvent("filterCmpEvent");
                cmpEvent.fire();
        },
        validateAndSerch: function(component, event, helper) {
                var cmpEvent = component.getEvent("filterCmpEvent");
                var allValid = component.find('requiredField').reduce(function(validSoFar, inputCmp) {
                        inputCmp.showHelpMessageIfInvalid();
                  
                        return validSoFar && !inputCmp.get('v.validity').valueMissing;
                }, true);
                if (allValid) {
                        cmpEvent.setParams({
                                "selectedRegion": component.get('v.selectedRegion'),
                                "selectedMarket": component.get('v.selectedMarket'),
                                "selectedYear": component.get('v.selectedYear'),
                                "selectedBrand": component.get('v.selectedBrand'),
                                "selectedQuarter": component.get('v.selectedQuarter'),
                                "selectedModel": component.get('v.selectedModel'),
                                "validated": 'true'
                        });
                } else {
                        helper.showToast(component, event, helper,  $A.get("{!$Label.c.VME_Error}"), 'Please fill all the required fields', 'error', 'info_alt');
                }
                cmpEvent.fire();
        }
})