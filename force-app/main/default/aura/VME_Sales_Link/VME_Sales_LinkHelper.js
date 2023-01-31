({
        getUserDetails: function(component, event, helper) {
                component.set("v.spinningTextClass", 'refresh');
                var action = component.get("c.fetchUser");
                action.setCallback(this, function(response) {
                        if (response.getState() === "SUCCESS") {
                                var storeResponse = response.getReturnValue();
                                component.set("v.userInfo", storeResponse);
                        }
                });
                $A.enqueueAction(action);
        },
        loadVMECampaignSchemes: function(component, event, helper, recordId) {
                var isOnline = window.navigator.onLine;
                if (isOnline) {
                        console.log('online');
                        var action = component.get("c.getSchemes");
                        action.setParams({
                                "opportunityId": recordId
                        });
                        action.setCallback(this, function(response) {
                                if (response.getState() === "SUCCESS") {
                                        //console.log(response.getReturnValue());
                                        console.log("You are not supposed to check here for data!!");
                                        if (response.getReturnValue().statusOfTransaction != 'WARNING' && response.getReturnValue().listofWrapperSchemes.length > 0) {
                                                var listOfSchemes = response.getReturnValue().listofWrapperSchemes;
                                                var disableBtnStatus = response.getReturnValue().disableBtnStatus;
                                                component.set("v.schemesWrapperList", listOfSchemes);
                                                component.set("v.disableAll", response.getReturnValue().disableBtnStatus);
                                                component.set("v.isSelectAll", response.getReturnValue().checkAll);
                                                component.set("v.saveBtnStatus", true);//response.getReturnValue().saveBtnStatus);
                                                component.set("v.showSaveButton",response.getReturnValue().showSaveButtons);
                                                component.set("v.showDetailBar",response.getReturnValue().showDetailBaar);
                                                component.set("v.noData", response.getReturnValue().MsgOfTransactionforUser);
                                                //this.showToast(component, event, helper, 'VME Sales Link has been refreshed.', 'L3 VMEs are available.', 'success', 'info_alt','3000');
                                                var actionSaverListArr = [];
                                                var totalB = 0;
                                                for (var j = 0; j < listOfSchemes.length; j++) {
                                                        if(listOfSchemes[j].isChecked)
                                                                totalB = totalB + listOfSchemes[j].perUnitVariantPostGST;
                                                        actionSaverListArr[j] = listOfSchemes[j].isChecked;
                                                        component.set("v.actionSaverListMaster", actionSaverListArr);
                                                }
                                                component.set("v.totalBenefit", totalB);
                                        } else {
                                                component.set("v.showSaveButton",response.getReturnValue().showSaveButtons);
                                                component.set("v.showDetailBar",response.getReturnValue().showDetailBaar);
                                                component.set("v.showSaveButton",response.getReturnValue().showSaveButtons);
                                                component.set("v.schemesWrapperList", []);
                                                component.set("v.noData", response.getReturnValue().MsgOfTransactionforUser);
                                                component.set("v.noDataIcon", response.getReturnValue().iconOfTransaction);
                                                //this.showToast(component, event, helper, 'VME Sales Link has been refreshed.', 'You have pending action to get L3 VMEs.', 'warning', 'info_alt','3000');
                                        }
                                }
                        });
                        $A.enqueueAction(action);
                } else {
                        console.log('offline');
                        this.showToast(component, event, helper, 'Looks like your internet is interrupted !!', 'Please try after sometimes.', 'warning', 'info_alt','5000');
                }
                
        },
        saveSelectedSchemes: function(component, event, helper, selectedSchemes) {
                
                var recordId = component.get("v.recordId");
                var action1 = component.get("c.updateSelectedChemes");
                action1.setParams({
                        "listOfSchemes": JSON.stringify(selectedSchemes),
                        "recordId": recordId,
                        "flag": true
                });
                action1.setCallback(this, function(response) {
                        if (response.getState() == "SUCCESS") {
                                $A.get('e.force:refreshView').fire();
                                this.showToast(component, event, helper, 'Your selection has been saved successfully.', 'VME Sales Link has been refreshed.', 'success', 'info_alt','3000');
                                component.set("v.actionSaverList", []);
                        } else {
                                this.showToast(component, event, helper, $A.get("{!$Label.c.VME_Error}"), response.getReturnValue(), 'error', 'info_alt','5000');
                        }
                })
                $A.enqueueAction(action1);
        },
        showToast: function(component, event, helper, titleVal, msg, typeVal, icon, timer) {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                        title: titleVal,
                        message: msg,
                        messageTemplate: msg,
                        duration: timer,
                        key: icon,
                        type: typeVal,
                        mode: 'dismissible'
                });
                toastEvent.fire();
        },
        buttonPermission: function(component, event, helper) {
                var actionSaveResult = component.get("v.actionSaverList");
                        var actionSaveResultString = actionSaveResult.toString();
                        var actionSaverListMasterResult = component.get("v.actionSaverListMaster");
                        var actionSaverListMasterResultString = actionSaverListMasterResult.toString();
                        if(actionSaveResultString != '' && actionSaverListMasterResultString != '' && actionSaveResultString != actionSaverListMasterResultString && (actionSaveResultString.includes("true") || actionSaveResultString.includes("false"))){
                                component.find("saveBtn").set('v.disabled', false);
                        }else{
                                component.find("saveBtn").set('v.disabled', true);
                        }
        }
})