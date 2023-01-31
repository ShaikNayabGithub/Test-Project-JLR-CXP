({
        doInit: function(component, event, helper) {
                var action = component.get("c.getAssetDetails");
                action.setParams({
                        "assetId": component.get("v.recordId")
                });
                action.setCallback(this, function(response) {
                        if (response.getState() == $A.get("{!$Label.c.Success_Msg}")) {
                                var result = response.getReturnValue();
                                if (!($A.util.isEmpty(result))) {
                                        component.set("v.icon", result.icon);
                                        component.set("v.variantType", result.variantDetails);
                                        component.set("v.msgDetails", result.message);
                                        component.set("v.confirmation", result.confirmation);
                                        if (result.confirmation) {
                                                component.set("v.assetDetails", result.selectedAsset);
                                        }
                                }
                        } else {
                                component.set("v.icon", 'utility:close');
                                component.set("v.variantType", 'error');
                                component.set("v.msgDetails", response.getError()[0].message);
                                component.set("v.confirmation", false);
                        }
                });
                $A.enqueueAction(action);
        },
        regenerateClaims: function(component, event, helper) {
                component.set("v.spinningTextClass", 'spins');
                console.log(JSON.stringify(component.get("v.assetDetails")));
                var action = component.get("c.regenerateAllClaims");
                action.setParams({
                        "assetObj": component.get("v.assetDetails")
                });
                action.setCallback(this, function(response) {
                        if (response.getState() == $A.get("{!$Label.c.Success_Msg}")) {
                                var result = response.getReturnValue();
                                if (!($A.util.isEmpty(result))) {
                                        component.set("v.icon", result.icon);
                                        component.set("v.variantType", result.variantDetails);
                                        component.set("v.msgDetails", result.message);
                                        component.set("v.confirmation", result.confirmation);
                                      //    window.setTimeout(function(){
                                          //      $A.get("e.force:closeQuickAction").fire(); 
                                               // $A.get('e.force:refreshView').fire();
                                     //     },3000);
                                }
                        } else {
                                console.log(JSON.stringify(response));
                                component.set("v.icon", 'utility:close');
                                component.set("v.variantType", 'error');
                                component.set("v.msgDetails", 'Something went wrong! Please contact Administrator.');
                                component.set("v.confirmation", false);
                        }
                });
                $A.enqueueAction(action);
        },
        getFormatofDate: function(component, event, helper) {
                var action = component.get("c.loggedInFormat");
                action.setCallback(this, function(response) {
                        if (response.getState() == 'SUCCESS') {
                                component.set("v.formatDate", response.getReturnValue());
                        }
                });
                $A.enqueueAction(action);
        },
})