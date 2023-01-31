({
        doInit: function(component, event, helper) {
                var recordId = component.get("v.recordId");
                helper.getUserDetails(component, event, helper);
                helper.loadVMECampaignSchemes(component, event, helper, recordId);
        },
        isRefreshing: function(component, event, helper) {
                var recordId = component.get("v.recordId");
                helper.getUserDetails(component, event, helper);
                helper.loadVMECampaignSchemes(component, event, helper, recordId);
        },
        showSpinner: function(component, event, helper) {
                // make Spinner attribute true for displaying loading spinner 
                component.set("v.spinner", true);
        },
        // function automatic called by aura:doneWaiting event 
        hideSpinner: function(component, event, helper) {
                // make Spinner attribute to false for hiding loading spinner    
                component.set("v.spinner", false);
        },
        onCheck: function(component, event, helper) {
                var totalB = component.get("v.totalBenefit");
                var actionSaverListArr = component.get("v.actionSaverList");
                var checkedValue = event.getSource().get("v.value");
                var allSchemes = component.get("v.schemesWrapperList");
                var indexvar = event.getSource().get("v.name");
                var countTrue = 0,
                        countFalse = 0;
                for (var j = 0; j < allSchemes.length; j++) {
                        if (indexvar == j && checkedValue) {
                                allSchemes[j].isChecked = true;
                                totalB = totalB + allSchemes[j].perUnitVariantPostGST;
                        }
                        if (allSchemes[j].isChecked) {
                                countTrue++;
                        }
                        if (indexvar == j && !checkedValue) {
                                allSchemes[j].isChecked = false;
                                totalB = totalB - allSchemes[j].perUnitVariantPostGST;
                        }
                        if (!allSchemes[j].isChecked) {
                                countFalse++;
                                component.find("selectAll").set("v.value", false);
                        }
                        if (allSchemes.length == countFalse) {
                                component.find("selectAll").set("v.value", false);
                        }
                        if (allSchemes.length == countTrue) {
                                component.find("selectAll").set("v.value", true);
                        }
                        actionSaverListArr[j] = allSchemes[j].isChecked;
                        component.set("v.actionSaverList", actionSaverListArr);
                        component.set("v.totalBenefit", totalB);
                        helper.buttonPermission(component, event, helper);
                }
        },
        checkAllSchemes: function(component, event, helper) {
                var totalB = component.get("v.totalBenefit");
                var totalCkB = 0;
                var actionSaverListArr = component.get("v.actionSaverList");
                var allSchemes = component.get("v.schemesWrapperList");
                var checkvalue = component.find("selectAll").get("v.value");
                var checkScheme = component.find("checkScheme");
                for (var i = 0; i < allSchemes.length; i++) {
                        allSchemes[i].isChecked = checkvalue;
                        actionSaverListArr[i] = checkvalue;
                        if(checkvalue){
                                totalCkB = totalCkB + allSchemes[i].perUnitVariantPostGST;
                        }else{
                                totalCkB = 0;
                        }
                        component.set("v.actionSaverList", actionSaverListArr);
                }
                component.set("v.schemesWrapperList", allSchemes);
                component.set("v.totalBenefit", totalCkB);
                helper.buttonPermission(component, event, helper);
        },
        saveSelectedScheme: function(component, event, helper) {
                component.set("v.spinningTextClass", 'saves');
                var selectedSchemes = [];
                var selectedCount = 0;
                var totalSchemeCount = 0;
                var totalCustomerBenfit = 0;
                var currencyCode  = component.get("v.userInfo").DefaultCurrencyIsoCode;
                var allSchemes = component.get("v.schemesWrapperList");
                for (var i = 0; i < allSchemes.length; i++) {
                        if (allSchemes[i].isChecked == true) {
                                selectedSchemes.push(allSchemes[i]);
                                selectedCount++;
                                totalCustomerBenfit += allSchemes[i].perUnitVariantPostGST;
                        }
                        totalSchemeCount++;
                }
                Swal.fire({
                        title: "Are you sure ?",
                        text: "You have selected "+selectedCount+" out of "+totalSchemeCount+ " available L3 VME Campaigns with a total customer benefit of "+ currencyCode+" "+totalCustomerBenfit+".00 .",
                        showCancelButton: true,
                        cancelButtonColor: '#d33'
                }).then((result) => {
                        if (result.value) {
                                console.log('You clicks on OK, that you are checking.');
                                helper.saveSelectedSchemes(component, event, helper, selectedSchemes);
                        } else {
                                console.log('User clicks on cancel, that you are checking.');
                                return;
                        }
                });
        }
})