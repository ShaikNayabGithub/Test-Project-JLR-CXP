({
        getUserCurrency: function(component, event, helper) {
                this.showSpinner(component, event, helper);
                var action = component.get("c.getUserDefaultCurrency");
                action.setCallback(this, function(response) {
                        var state = response.getState();
                        if (state === $A.get("{!$Label.c.VME_SUCCESS}")) {
                                this.hideSpinner(component, event, helper);
                                component.set("v.userCurrency", response.getReturnValue());
                        }
                });
                $A.enqueueAction(action);
        },
        getAllQMSPData: function(component, event, helper, compValue) {
                this.showSpinner(component, event, helper);
                var validated = false;
                if (compValue == true) {
                        validated = event.getParam("validated");
                        component.set("v.selectedRegion", event.getParam("selectedRegion"));
                        component.set("v.selectedMarket", event.getParam("selectedMarket"));
                        component.set("v.selectedYear", event.getParam("selectedYear"));
                        component.set("v.selectedBrand", event.getParam("selectedBrand"));
                        component.set("v.selectedQuarter", event.getParam("selectedQuarter"));
                        component.set("v.selectedModel", event.getParam("selectedModel"));
                }
                if (compValue == false) {
                        validated = true;
                }
                if (validated) {
                        this.showSpinner(component, event, helper);
                        var action = component.get("c.getAllQMSPRecords");
                        action.setParams({
                                selectedRegion: component.get("v.selectedRegion"),
                                selectedMarket: component.get("v.selectedMarket"),
                                selectedYear: component.get("v.selectedYear"),
                                selectedBrand: component.get("v.selectedBrand"),
                                selectedQuarter: component.get("v.selectedQuarter"),
                                selectedModel: component.get("v.selectedModel")
                        });
                        action.setCallback(this, function(response) {
                                component.set("v.isSearch", false);
                                component.set("v.campWrapper", null);
                                component.set("v.tempCampWrapper", null);
                                this.hideSpinner(component, event, helper);
                                var state = response.getState();
                                if (state === $A.get("{!$Label.c.VME_SUCCESS}")) {
                                        var result = response.getReturnValue();
                                        if (result == null) {
                                                this.showToast(component, event, helper, $A.get("{!$Label.c.VME_Error}"), $A.get("{!$Label.c.VME_NoQMSPRecords}"), 'error', 'info_alt');
                                        } else {
                                                component.set("v.isSearch", true);
                                                component.set("v.campWrapper", JSON.parse(JSON.stringify(result)));
                                                component.set("v.tempCampWrapper", result);
                                                helper.checkQuarter(component, event, helper);
                                        }
                                } else if (state === $A.get("{!$Label.c.VME_ERRORInResult}")) {
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
                } else {
                        this.hideSpinner(component, event, helper);
                        component.set("v.isSearch", false);
                        component.set("v.campWrapper", null);
                }
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
        saveVMECampaign: function(component, event, helper, editedVMECampaign, Method) {
                this.showSpinner(component, event, helper);
                var action = component.get("c.saveVMERecord");
                action.setParams({
                        recordData: editedVMECampaign,
                        methodName: Method
                });
                action.setCallback(this, function(response) {
                        var state = response.getState();
                        if (state === $A.get("{!$Label.c.VME_SUCCESS}")) {
                                this.hideSpinner(component, event, helper);
                                var result = response.getReturnValue();
                                if (result == null) {
                                        this.showToast(component, event, helper, $A.get("{!$Label.c.VME_Error}"), $A.get("{!$Label.c.VME_SomethingWentWrong}"), 'error', 'info_alt');
                                        this.cancelVMECamp(component, event, helper, editedVMECampaign.Id);
                                } else {
                                        if (Method == $A.get("{!$Label.c.VME_Edit}")) {
                                                this.showToast(component, event, helper, $A.get("{!$Label.c.VME_savedSuccessfully}"), $A.get("{!$Label.c.VME_recordSaved}"), 'success', 'info_alt');
                                                this.getAllQMSPData(component, event, helper, false);
                                        } else {
                                                this.showToast(component, event, helper, $A.get("{!$Label.c.VME_recordSaved}"), $A.get("{!$Label.c.VME_schemeEndedSuccessfully}"), 'success', 'info_alt');
                                        }
                                        var tempResultList = component.get("v.tempCampWrapper");
                                        var resultList = component.get("v.campWrapper");
                                        JSON.parse(JSON.stringify(tempResultList));
                                        for (var i in tempResultList.vmeCampaignWrapList) {
                                                if (tempResultList.vmeCampaignWrapList[i].vmeCampaignWrap.Id == result.vmeCampaignWrap.Id) {
                                                        tempResultList.vmeCampaignWrapList[i].vmeCampaignWrap = result.vmeCampaignWrap;
                                                        tempResultList.vmeCampaignWrapList[i].schemeList = result.schemeList;
                                                }
                                                if (resultList.vmeCampaignWrapList[i].vmeCampaignWrap.Id == result.vmeCampaignWrap.Id) {
                                                        resultList.vmeCampaignWrapList[i].vmeCampaignWrap = result.vmeCampaignWrap;
                                                        resultList.vmeCampaignWrapList[i].schemeList = result.schemeList;
                                                }
                                        }
                                        component.set("v.tempCampWrapper", JSON.parse(JSON.stringify(tempResultList)));
                                        component.set("v.campWrapper", JSON.parse(JSON.stringify(resultList)));
                                }
                        } else if (state === $A.get("{!$Label.c.VME_ERRORInResult}")) {
                                this.cancelVMECamp(component, event, helper, editedVMECampaign.Id);
                                this.hideSpinner(component, event, helper);
                                var errors = response.getError();
                                if (errors) {
                                        if (errors[0] && errors[0].message) {
                                                this.showToast(component, event, helper, $A.get("{!$Label.c.VME_Error}"), errors[0].message, 'error', 'info_alt');
                                        }
                                } else {
                                        this.showToast(component, event, helper, $A.get("{!$Label.c.VME_Error}"), ' $A.get("{!$Label.c.VME_SomethingWentWrong}")', 'error', 'info_alt');
                                }
                        }
                });
                $A.enqueueAction(action);
        },
        editVMECampFields: function(component, event, helper) {
                var buttonLabel = event.getSource().get("v.label");
                var currentVMECampId = event.getSource().get("v.value");
                var resultList = component.get("v.campWrapper");
                debugger;
                for (var i in resultList.vmeCampaignWrapList) {
                        if (resultList.vmeCampaignWrapList[i].vmeCampaignWrap.Id == currentVMECampId) {
                                var tempVMECampId = resultList.vmeCampaignWrapList[i].vmeCampaignWrap.Id;
                                if (buttonLabel == $A.get("{!$Label.c.VME_Edit}")) {
                                        resultList.vmeCampaignWrapList[i].campEditable = false;
                                }
                                if (buttonLabel == 'Save') {
                                        debugger;
                                        var validateFields = ["Planned", "Volume"];
                                        if (this.validateAndCheck(component, event, helper, validateFields, tempVMECampId) == true) {
                                                Swal.fire({
                                                        text: "Reason for Adjustment",
                                                        input: 'text',
                                                        showCancelButton: true,
                                                        inputValidator: (value) => {
                                                                if (!value) {
                                                                  return 'Please fill the Reason for Adjustment'
                                                                }
                                                              }      
                                                    }).then((result) => {
                                                        if (result.value) {
                                                                
                                                                resultList.vmeCampaignWrapList[i].vmeCampaignWrap.VME_L2_Adjustment_Reason__c=result.value;
                                                                this.saveVMECampaign(component, event, helper, resultList.vmeCampaignWrapList[i].vmeCampaignWrap,$A.get("{!$Label.c.VME_Edit}"));
                                                                resultList.vmeCampaignWrapList[i].campEditable = true;
                                                              
                                                              
                                                        }
                                                    });
                                                    break;
                                                       
                                                       
                                                      
                                                     
                                                 
                                        } else {
                                                this.showToast(component, event, helper, $A.get("{!$Label.c.VME_Error}"), 'Please fill all the input field details correctly.', 'error', 'info_alt');
                                                resultList.vmeCampaignWrapList[i].campEditable = false;
                                        }
                                }
                        }
                }
                component.set("v.campWrapper", resultList);
        },
        editVMESchFields: function(component, event, helper) {
                var currentVMECampId = event.getSource().get("v.value");
                var resultList = component.get("v.campWrapper");
                for (var i in resultList.vmeCampaignWrapList) {
                        if (resultList.vmeCampaignWrapList[i].vmeCampaignWrap.Id == currentVMECampId) {
                                if (resultList.vmeCampaignWrapList[i].schemeList == undefined || resultList.vmeCampaignWrapList[i].schemeList.length == 0 || resultList.vmeCampaignWrapList[i].schemeList == null) {
                                        resultList.vmeCampaignWrapList[i].schemeList = null;
                                        component.set("v.openSchemeAdjustModel", true);
                                        component.set("v.vmeCampaignResultValue", resultList.vmeCampaignWrapList[i]);
                                        helper.hideSpinner(component, event, helper);
                                } else {
                                        component.set("v.openSchemeAdjustModel", true);
                                        component.set("v.vmeCampaignResultValue", resultList.vmeCampaignWrapList[i]);
                                        helper.hideSpinner(component, event, helper);
                                }
                        }
                }
        },
        cancelVMECamp: function(component, event, helper, IdValue) {
                if (IdValue == null) {
                        var currentVMECampId = event.getSource().get("v.value");
                } else {
                        currentVMECampId = IdValue;
                }
                var tempResultList = component.get("v.tempCampWrapper");
                JSON.parse(JSON.stringify(tempResultList));
                var resultList = component.get("v.campWrapper");
                for (var i in tempResultList.vmeCampaignWrapList) {
                        if (tempResultList.vmeCampaignWrapList[i].vmeCampaignWrap.Id == currentVMECampId) {
                                resultList.vmeCampaignWrapList[i].vmeCampaignWrap = tempResultList.vmeCampaignWrapList[i].vmeCampaignWrap;
                                resultList.vmeCampaignWrapList[i].campEditable = true;
                        }
                }
                component.set("v.campWrapper", JSON.parse(JSON.stringify(resultList)));
        },
        handleAdjustVariantEvt: function(component, event, helper) {
                this.hideSpinner(component, event, helper);
                var resultList = component.get("v.campWrapper");
                var updatedWrapperList = event.getParam("updateVMECampWrapperList")
                for (var i in resultList.vmeCampaignWrapList) {
                        if (resultList.vmeCampaignWrapList[i].vmeCampaignWrap.Id == updatedWrapperList.vmeCampaignWrap.Id) {
                                resultList.vmeCampaignWrapList[i] = updatedWrapperList;
                                component.set("v.vmeCampaignResultValue", updatedWrapperList);
                        }
                }
                component.set("v.campWrapper", resultList);
                component.set("v.openSchemeAdjustModel", event.getParam("openAdjustModel"));
        },
        handleCancelSplitSchemeEvt: function(component, event, helper) {
                this.hideSpinner(component, event, helper);
                var VMECampUpdatedWrapper = event.getParam("VMECampUpdatedWrapper");
                var resultList = component.get("v.campWrapper");
                for (var i in resultList.vmeCampaignWrapList) {
                        if (resultList.vmeCampaignWrapList[i].vmeCampaignWrap.Id == VMECampUpdatedWrapper.vmeCampaignWrap.Id) {
                                resultList.vmeCampaignWrapList[i].vmeCampaignWrap = VMECampUpdatedWrapper.vmeCampaignWrap;
                                var tempArray = [];
                                for (var j in resultList.vmeCampaignWrapList[i].schemeList) {
                                        if ((!VMECampUpdatedWrapper.schemeList[j].VME_InActive__c)) {
                                                tempArray.push(VMECampUpdatedWrapper.schemeList[j]);
                                        }
                                }
                                resultList.vmeCampaignWrapList[i].schemeList = tempArray;
                        }
                }
                component.set("v.campWrapper", resultList);
        },
        getQuarterDetails: function(component, event, helper) {
                var action = component.get("c.getQuarterInfos");
                action.setCallback(this, function(response) {
                        this.hideSpinner(component, event, helper);
                        var state = response.getState();
                        if (state === $A.get("{!$Label.c.VME_SUCCESS}")) {
                                var result = response.getReturnValue();
                                component.set("v.quarterInfoMap", result);
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
        checkQuarter: function(component, event, helper) {
                var quarterMap = component.get("v.quarterInfoMap");
                var resultList = component.get("v.campWrapper");
                var fisicalYear = resultList.campWrap.VME_Fiscal_Year__c;
                var today = new Date();
                var startDateQuarter;
                var endDateQuarter;
                var quarterSettingsValue = quarterMap[resultList.campWrap.QMSP_Quarter__c];
                if (quarterSettingsValue.Label == '1' || quarterSettingsValue.Label == '2' || quarterSettingsValue.Label == '3') {
                        startDateQuarter = new Date(fisicalYear - 1, quarterSettingsValue.Start_Month__c - 1, quarterSettingsValue.Start_Day__c);
                        endDateQuarter = new Date(fisicalYear - 1, quarterSettingsValue.End_Month__c - 1, quarterSettingsValue.End_Day__c);
                }
                if (quarterSettingsValue.Label == '4') {
                        startDateQuarter = new Date(fisicalYear, quarterSettingsValue.Start_Month__c - 1, quarterSettingsValue.Start_Day__c);
                        endDateQuarter = new Date(fisicalYear, quarterSettingsValue.End_Month__c - 1, quarterSettingsValue.End_Day__c);
                }
                if (startDateQuarter.getTime() < today.getTime() && endDateQuarter.getTime() < today.getTime() && $A.get("{!$Label.c.VME_Show_Configure_Btn}")==="false") {
                        component.set("v.hideNewCreationbtn", true);
                }
                if (startDateQuarter.getTime() < today.getTime() && endDateQuarter.getTime() > today.getTime()) {
                        var day = 60 * 60 * 24 * 1000;
                        var tommorrow = $A.localizationService.formatDate(new Date(today.getFullYear(), today.getMonth(), today.getDate()).getTime() + day, "YYYY-MM-DD");
                        component.set("v.hideNewCreationbtn", false);
                        component.set("v.startDateOfVME", tommorrow);
                        component.set("v.endDateOfVME", $A.localizationService.formatDate(new Date(endDateQuarter.getFullYear(), endDateQuarter.getMonth(), endDateQuarter.getDate()), "YYYY-MM-DD"));
                }
                if (startDateQuarter.getTime() > today.getTime() && endDateQuarter.getTime() > today.getTime() || ($A.get("{!$Label.c.VME_Show_Configure_Btn}")==="true")) {
                        component.set("v.hideNewCreationbtn", false);
                        component.set("v.startDateOfVME", $A.localizationService.formatDate(new Date(startDateQuarter.getFullYear(), startDateQuarter.getMonth(), startDateQuarter.getDate()), "YYYY-MM-DD"));
                        component.set("v.endDateOfVME", $A.localizationService.formatDate(new Date(endDateQuarter.getFullYear(), endDateQuarter.getMonth(), endDateQuarter.getDate()), "YYYY-MM-DD"));
                }
        },
        validateAndCheck: function(component, event, helper, controlAuraIds, IdValue) {
                var currentVMECampId = event.getSource().get("v.value");
                var toValidateCmps = [];
                for (var i = 0; i < controlAuraIds.length; i++) {
                        var valuetovalidate = controlAuraIds[i];
                        var allUIData = component.find(valuetovalidate);
                        for (var j = 0; j < allUIData.length; j++) {
                                if (!allUIData[j].get('v.disabled') && IdValue == allUIData[j].get('v.name')) {
                                        toValidateCmps.push(allUIData[j]);
                                }
                        }
                }
                var isAllValid = toValidateCmps.reduce(function(isValidSoFar, inputCmp) {
                        var valueData = inputCmp.get("v.value");
                        if (valueData.length > 16) {
                                inputCmp.setCustomValidity("The maximum length of input fields is 16");
                        } else {
                                inputCmp.setCustomValidity(""); // if there was a custom error before, reset it
                        }
                        inputCmp.reportValidity();
                        inputCmp.showHelpMessageIfInvalid();
                        return isValidSoFar && inputCmp.checkValidity();
                }, true);
                return isAllValid;
        },
        showSpinner: function(component, event, helper) {
                var spinner = component.find("mySpinner");
                $A.util.removeClass(spinner, "slds-hide");
        },
        hideSpinner: function(component, event, helper) {
                var spinner = component.find("mySpinner");
                $A.util.addClass(spinner, "slds-hide mySpinnerCss");
        },
        statusPopup: function(component, event, helper, title, bodyMessage, CurrentVME, CurrentScheme, showOkay, showBoth, CompName, CompId) {
                this.hideSpinner(component, event, helper);
                $A.createComponent("c:VME_ConfirmModal", {
                        "title": title,
                        "bodyMsg": bodyMessage,
                        "CurrentVME": CurrentVME,
                        "showOkay": showOkay,
                        "showBoth": showBoth,
                        "CurrentScheme": CurrentScheme,
                        "CompName": CompName,
                        "CompId": CompId
                }, function(msgBox) {
                        if (component.isValid()) {
                                var targetCmp = component.find('ModalDialogPlaceholder');
                                var body = targetCmp.get("v.body");
                                body.push(msgBox);
                                targetCmp.set("v.body", body);
                        }
                });
        },
})