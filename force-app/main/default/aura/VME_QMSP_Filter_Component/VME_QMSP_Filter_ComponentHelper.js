({
        getAllRegionMarketValues: function(component, event, helper) {
                component.set('v.MarketList', {
                        label: 'Select Country',
                        value: ' '
                });
                    this.showSpinner(component,event,helper);
                var action = component.get("c.get_VME_Region_Market_Map");
                action.setCallback(this, function(response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                                    this.hideSpinner(component,event,helper);
                            
                                var arrayOfMapKeys = [];
                                //alert("From server: " + response.getReturnValue());
                                component.set('v.marketRegionMap', response.getReturnValue());
                                arrayOfMapKeys.push({
                                        label: 'Select Region',
                                        value: ' '
                                });
                                for (var keyValues in response.getReturnValue()) {
                                        var ele = {
                                                'label': keyValues,
                                                'value': keyValues
                                        };
                                        arrayOfMapKeys.push(ele);
                                }
                                component.set('v.RegionList', arrayOfMapKeys);
                        } else if (state === "INCOMPLETE") {} else if (state === "ERROR") {
                                var errors = response.getError();
                                if (errors) {
                                        if (errors[0] && errors[0].message) {
                                             
                                        }
                                } else {
                                      
                                }
                        }
                });
                $A.enqueueAction(action);
        },
        getUserDetails : function(component, event, helper) {
                    this.showSpinner(component,event,helper);
                var action = component.get("c.get_User_Details");
                action.setCallback(this, function(response) {
                      this.hideSpinner(component,event,helper);
                        var state = response.getState();
                        if (state === "SUCCESS") {
                                var storeResponse = response.getReturnValue();
                              
                                component.set("v.userInfo", storeResponse);
                                component.set('v.selectedRegion', storeResponse.Market__c);
                                      this.selectedRegionDataHelper(component, event, helper);
                                 
                                if(storeResponse.Country_ISO_Code__c != "" && storeResponse.Country_ISO_Code__c != null && storeResponse.Country_ISO_Code__c != undefined){
                                     
                                                component.set("v.selectedMarket", storeResponse.Country_ISO_Code__c);
                                               component.set("v.makeCountryDisabled",true);
                              
                             
                             }
                               
                        } else if (state === "ERROR") {
                                var errors = response.getError();
                                if (errors) {
                                        if (errors[0] && errors[0].message) {
                                                console.log("Error message: " + errors[0].message);
                                        }
                                } else {
                                        console.log("Unknown error");
                                }
                        }
                });
                $A.enqueueAction(action);
        },
        getFinancialYearList: function(component, event, helper) {
                var tempYearArray = [];
                var currentYear = new Date().getFullYear();
                tempYearArray.push({ label: 'Select Fiscal Year', value: ' ' });
                tempYearArray.push({ label: (currentYear - 1).toString(), value: (currentYear - 1).toString() });
                tempYearArray.push({ label: (currentYear).toString(), value: (currentYear).toString() });
                tempYearArray.push({ label: (currentYear + 1).toString(), value: (currentYear + 1).toString() });
                tempYearArray.push({ label: (currentYear + 2).toString(), value: (currentYear + 2).toString() });
                tempYearArray.push({ label: (currentYear + 3).toString(), value: (currentYear + 3).toString() });
                tempYearArray.push({ label: (currentYear + 4).toString(), value: (currentYear + 4).toString() });
                component.set('v.YearList', tempYearArray);
        },
        getPicklistList: function(component, event, helper, getData) {
                var arrayOfQuarterMap = [];
                                
                if (getData == 'Quarter') {
                        arrayOfQuarterMap.push({
                                label: 'Select Quarter',
                                value: ' '
                        });
                            this.showSpinner(component,event,helper);
                        var action = component.get("c.getQuarterPicklistValues");
                
             
                action.setCallback(this, function(response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                                    this.hideSpinner(component,event,helper);
                                var resultData = response.getReturnValue();
                                console.log(resultData);
                                for (var keyValues in resultData) {
                                        arrayOfQuarterMap.push({
                                                label: keyValues,
                                                value: resultData[keyValues]
                                        });
                                }
                            
                                        component.set('v.QuarterList', arrayOfQuarterMap);
                                }else if (state === "ERROR") {
                                var errors = response.getError();
                                if (errors) {
                                        if (errors[0] && errors[0].message) {
                                                console.log("Error message: " + errors[0].message);
                                        }
                                } else {
                                        console.log("Unknown error");
                                }
                        }
                            });
                $A.enqueueAction(action);
            }
                                if (getData == 'Model') {
                                   //     component.set('v.ModelList', arrayOfQuarterMap);
                                            this.showSpinner(component,event,helper);
                                        var action = component.get("c.getModelPicklistValues");
                                        action.setCallback(this, function(response) {
                                                if (response.getState() == "SUCCESS") {
                                                            this.hideSpinner(component,event,helper);
                                                        var StoreResponse = response.getReturnValue();
                                                        component.set("v.dependentModelFieldMap", StoreResponse);
                                                        var listOfkeys = [];
                                                        var ControllerField = [];
                                                        for (var singlekey in StoreResponse) {
                                                                listOfkeys.push(singlekey);
                                                        }
                                                        if (listOfkeys != undefined && listOfkeys.length > 0) {
                                                                ControllerField.push({
                                                                        label: 'Select Brand',
                                                                        value: ' '
                                                                });
                                                        }
                                                        for (var i = 0; i < listOfkeys.length; i++) {
                                                                var ele = {
                                                                        'label': listOfkeys[i],
                                                                        'value': listOfkeys[i]
                                                                };
                                                                ControllerField.push(ele);
                                                        }
                                                        ControllerField.sort();
                                                        component.set("v.BrandList", ControllerField);
                                                } else if (state === "ERROR") {
                                                                var errors = response.getError();
                                                                if (errors) {
                                                                        if (errors[0] && errors[0].message) {
                                                                                console.log("Error message: " + errors[0].message);
                                                                        }
                                                                } else {
                                                                        console.log("Unknown error");
                                                                }
                                                  }
                                        });
                                        $A.enqueueAction(action);
                                
                        } 
            
        },
        brand_Model_Mapping: function(component, event, helper) {
                var controllerValueKey = event.getSource().get("v.value"); // get selected controller field value
                var dependentModelFieldMap = component.get("v.dependentModelFieldMap");
                  component.set("v.selectedModel"," ");
                //component.set("v.ModelList", " ");

                if (controllerValueKey != ' ') {
                        var ListOfDependentFields = dependentModelFieldMap[controllerValueKey];
                    
                        if (ListOfDependentFields.length > 0) {
                                component.set("v.brandDisabledDependentFld", false);
                                this.fetchModelDepValues(component, ListOfDependentFields);
                        } else {
                             component.set("v.brandDisabledDependentFld", true);
                                component.set("v.ModelList", [' ']);
                        }
                } else {
                     component.set("v.brandDisabledDependentFld", true);
                        component.set("v.ModelList", [' ']);
                }
        },
        selectedRegionDataHelper: function(component, event, helper) {
           
                component.set('v.selectedMarket', ' ');
                var selectedOptionValue = component.get("v.selectedRegion");
                var MapValues = component.get("v.marketRegionMap");
             
                var arrayOfMapKeys = [];
                var tempArray = [];
                arrayOfMapKeys.push({
                        label: 'Select Country',
                        value: ' '
                });
                arrayOfMapKeys.push({
                        label: 'All',
                        value: 'All'
                });
                for (var key in MapValues) {
                        if (key == selectedOptionValue) {
                                tempArray = MapValues[selectedOptionValue];
                        }
                }
                if (tempArray != undefined && tempArray.length > 0) {
                        for (var obj in tempArray) {
                                arrayOfMapKeys.push({
                                        label: tempArray[obj],
                                        value: tempArray[obj]
                                });
                        }
                }
             
                arrayOfMapKeys.sort();
                component.set('v.MarketList', arrayOfMapKeys);
        },
        showToast: function(component, event, helper, titleVal, msg, typeVal, icon) {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                        title: titleVal,
                        message: msg,
                        messageTemplate: msg,
                        duration: ' 5000',
                        key: icon,
                        type: typeVal,
                        mode: 'dismissible'
                });
                toastEvent.fire();
        },
        fetchModelDepValues: function(component, ListOfDependentFields) {
                var dependentFields = [];
                dependentFields.push({
                        label: 'Select Model',
                        value: ' '
                });
                for (var i = 0; i < ListOfDependentFields.length; i++) {
                        var ele = {
                                'label': ListOfDependentFields[i],
                                'value': ListOfDependentFields[i]
                        };
                        dependentFields.push(ele);
                }
                dependentFields.sort();
             
                component.set("v.ModelList", dependentFields);
        },
          showSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
     
    hideSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    }

})