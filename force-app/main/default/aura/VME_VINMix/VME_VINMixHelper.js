({
    doInit: function(component, event, helper) {
        debugger;
        var revisedSchemeValue = component.get("v.revisedSchemeValue");
        var revisedSchemeId = '';
        if (!($A.util.isEmpty(revisedSchemeValue))) {
            revisedSchemeId = revisedSchemeValue.Id;
        }
        this.showSpinner(component, event, helper);

       
        var action = component.get("c.getExistingVINForScheme");
        action.setParams({
            "schemeId": component.get("v.schemeId"),
            "parameterName": component.get("v.parameterName"),
            "revisedSchemeId": revisedSchemeId,
            "selectedRetailerId":  component.get("v.retailer")
        });
        action.setCallback(this, function(response) {
            this.hideSpinner(component, event, helper);
            if (response.getState() == 'SUCCESS') {

                component.set("v.existingVINList", response.getReturnValue());
                this.onLoadfetchAllVIn(component, event, helper);
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
    },


    searchVIN: function(component, event, helper) {
        this.showSpinner(component, event, helper);
        var tempListToDisplay = [];

        var vinSearchValue = component.get("v.vinSearchValue");
        if (vinSearchValue === '' || vinSearchValue === undefined || !vinSearchValue.replace(/\s/g, '').length) {
            this.onLoadfetchAllVIn(component, event, helper);
        } else {
            var vinSearchList = component.get("v.vinSearchList");
            if (!($A.util.isEmpty(vinSearchList)) && vinSearchList.length > 0) {
                for (var i = 0; i < vinSearchList.length; i++) {
                    if (((vinSearchList[i].assetObj.VIN__c).toLowerCase()).includes(vinSearchValue.toLowerCase())) {
                        tempListToDisplay.push(vinSearchList[i]);
                    }
                }
            }
            if (!($A.util.isEmpty(tempListToDisplay)) && tempListToDisplay.length > 0) {
                this.hideSpinner(component, event, helper);
                component.set("v.searchedData", true);
                var productListLength = tempListToDisplay.length;
                var productListLength = tempListToDisplay.length;
                var pageSize = component.get("v.pageSize");
                var totalPages = Math.ceil(productListLength / pageSize);
                if (productListLength < pageSize) pageSize = productListLength;
                component.set("v.totalPages", totalPages);
                component.set("v.pageNumber", 1);
                if (productListLength < pageSize) pageSize = productListLength;
                var paginationVINList = [];
                for (var i = 0; i < pageSize; i++) {
                    paginationVINList.push(tempListToDisplay[i]);
                }
                component.set("v.paginationVINList", paginationVINList);
            } else {
                this.hideSpinner(component, event, helper);
                component.set("v.searchedData", false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "error",
                    "mode": "dismissible",
                    "title": "Error!",
                    "message": "No record found."
                });
                toastEvent.fire();
            }
        }

    },


    nextPage: function(component, event, helper) {

        var pageSize = component.get("v.pageSize");
        var pageNumber = component.get("v.pageNumber");
        var paginationVINList = component.get("v.paginationVINList");
        var vinSearchList = component.get("v.vinSearchList");

        for (var i = 0; i < paginationVINList.length; i++) {
            vinSearchList[(pageNumber - 1) * pageSize + i] = paginationVINList[i];
        }
        component.set("v.vinSearchList", vinSearchList);

        paginationVINList = [];
        var startingIndex = (pageSize * pageNumber);
        var lastIndex = startingIndex + pageSize;
        if (vinSearchList.length < lastIndex)
            lastIndex = vinSearchList.length;
        for (var i = startingIndex; i < lastIndex; i++) {
            paginationVINList.push(vinSearchList[i]);
        }
        component.set("v.paginationVINList", paginationVINList);
        component.set("v.pageNumber", pageNumber + 1);
    },


    previousPage: function(component, event, helper) {
        var pageSize = component.get("v.pageSize");
        var pageNumber = component.get("v.pageNumber");
        var paginationVINList = component.get("v.paginationVINList");
        var vinSearchList = component.get("v.vinSearchList");

        for (var i = 0; i < paginationVINList.length; i++) {
            vinSearchList[(pageNumber - 1) * pageSize + i] = paginationVINList[i];
        }
        component.set("v.vinSearchList", vinSearchList);

        paginationVINList = [];
        var lastIndex = (pageSize * (pageNumber - 1));
        var startingIndex = lastIndex - pageSize;
        for (var i = startingIndex; i < lastIndex; i++) {
            paginationVINList.push(vinSearchList[i]);
        }
        component.set("v.paginationVINList", paginationVINList);
        component.set("v.pageNumber", pageNumber - 1);
    },




    saveVINMix: function(component, event, helper) {
        var vinSearchList = [];
        var pageSize = component.get("v.pageSize");
        var pageNumber = component.get("v.pageNumber");
        var paginationVINList = component.get("v.paginationVINList");
        var vinTempList = component.get("v.vinSearchList");
        var existingVINList = component.get("v.existingVINList");
        var retailerId = component.get("v.retailer");

        if (!($A.util.isEmpty(vinTempList))) {
            for (var i = 0; i < vinTempList.length; i++) {
                vinSearchList.push(vinTempList[i]);
            }
        }

        if (!($A.util.isEmpty(existingVINList))) {
            for (var i = 0; i < existingVINList.length; i++) {
                vinSearchList.push(existingVINList[i]);
            }
        }

        var isSelectedFound = false;

        var tempSelectedList = [];
        var tempRetailerList = [];

        if (!($A.util.isEmpty(vinSearchList))) {
            for (var i = 0; i < vinSearchList.length; i++) {
                if (vinSearchList[i].isSelected) {
                    tempSelectedList.push(vinSearchList[i]);
                    isSelectedFound = true;
                }
                if (vinSearchList[i].isSelected && vinSearchList[i].assetObj.Retailer_Name__c != retailerId) {
                    tempRetailerList.push(vinSearchList[i]);
                    isSelectedFound = false;
                }
            }
        }
        if (($A.util.isEmpty(tempSelectedList)) && tempSelectedList.length == 0) {
            isSelectedFound = false;
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "error",
                "title": "ERROR!",
                "message": 'Please select atleast one VIN.'
            });

            toastEvent.fire();
        }
        if (!($A.util.isEmpty(tempRetailerList)) && tempRetailerList.length > 0) {

            isSelectedFound = false;
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "error",
                "title": "ERROR!",
                "message": 'You updated the Dealer.Please select VIN related to selected Dealer.'
            });

            toastEvent.fire();
        }


        if (isSelectedFound && event.getSource().get("v.title") == 'dealers') {
            this.showSpinner(component, event, helper);
            var action = component.get("c.saveVINMixRecords");

            action.setParams({
                "wrapperList": vinSearchList,
                "schemeId": component.get("v.schemeId")
            });
            action.setCallback(this, function(response) {
                this.hideSpinner(component, event, helper);
                var result = response.getReturnValue();
                var toastEvent = $A.get("e.force:showToast");
                if (result == $A.get("{!$Label.c.Success_Msg}")) {
                    toastEvent.setParams({
                        "type": "success",
                        "mode": "dismissible",
                        "title": "SUCCESS!",
                        "message": "Saved successfully."
                    });
                    if( component.get("v.compIdentityValue")==$A.get("{!$Label.c.VME_CategoryAdjustment}")){ 
                        helper.refreshCategoryPage(component, event, helper);
                        }
                        if( component.get("v.compIdentityValue")!=$A.get("{!$Label.c.VME_CategoryAdjustment}")){
                        helper.refreshAdjustmentPage(component, event, helper);
                      }
                } else {
                    toastEvent.setParams({
                        "type": "error",
                        "title": "ERROR!",
                        "message": result
                    });
                }
                toastEvent.fire();
            });
            $A.enqueueAction(action);
        }
    },


    closeConfirmModel: function(component, event, helper) {
        var selectedVinList = [];
        var existingVINList = component.get("v.existingVINList");
        var retailerId = component.get("v.retailer");
        var toastEvent = $A.get("e.force:showToast");
        var getAllVIN =component.get("v.getAllVIN");

        if (!($A.util.isEmpty(existingVINList))) {
            for (var i = 0; i < existingVINList.length; i++) {
                if (existingVINList[i].assetObj.Retailer_Name__c != retailerId && existingVINList[i].isSelected)
                    selectedVinList.push(existingVINList[i]);
            }
        }
        if (!($A.util.isEmpty(selectedVinList)) && selectedVinList.length > 0) {
            toastEvent.setParams({
                "type": "error",
                "title": "ERROR!",
                "message": 'You updated the Dealer.Please select VIN related to selected Dealer.'
            });

            toastEvent.fire();
        } else {
            if(!getAllVIN && $A.util.isEmpty(existingVINList)){
                
                Swal.fire({
                    title: "Invalid L3 VME Campaign",
                     text: "There is no VIN available for respective retailer.Delete it or change the retailer",
                      type: "error",
                      showCancelButton: true,
                      confirmButtonColor: '#3085d6',
                      cancelButtonColor:   '#d33',
                      confirmButtonText: 'Delete',
                      cancelButtonText: 'Change Retailer'
                   })
                   .then((result) => {
                     if (result.value) {
                         //cotinue
                           helper.deleteInvalidL3(component, event, helper);
                      
                     } else{
                        helper.refreshAdjustmentPage(component, event, helper);
                     }
                     });
                 
            }
           else if ($A.util.isEmpty(existingVINList))  {
               Swal.fire({
                title: "Invalid L3 VME Campaign",
                 text: "It is an invalid L3.Please select VIN or continue to configure it later.",
                  type: "warning",
                  showCancelButton: true,
                  confirmButtonColor: '#3085d6',
                  cancelButtonColor:   '#d33',
                  confirmButtonText: 'Continue',
                  cancelButtonText: 'Cancel'
               })
               .then((result) => {
                 if (result.value) {
                   if( $A.get("{!$Label.c.New_VME_Parameter}")==component.get("v.parameterName")){
                       helper.deleteInvalidL3(component, event, helper);
                    }else{
                        helper.refreshAdjustmentPage(component, event, helper);
                    }
                 } else{
                       
                 }
                 });
            }  else {
                component.set("v.isOpenComp", false);
            }
        }

    },

    refreshCategoryPage: function(component, event, helper) {
        var cmpEvent = component.getEvent("refreshCmpEvt");
        cmpEvent.fire();
        component.set("v.isOpenComp", false);

    },

    onLoadfetchAllVIn: function(component, event, helper) {
        debugger;
        this.showSpinner(component, event, helper);
        var dealerArr = [];
        component.set("v.vinSearchList", dealerArr);
        component.set("v.paginationVINList", dealerArr);
        component.set("v.pageNumber", 0);
        component.set("v.totalPages", 0);
        component.set("v.pageSize", parseInt($A.get("{!$Label.c.Page_Size_Product_Mix}")));

        var retailerValue = component.get("v.retailer");
        var parentVMECamp = component.get("v.parentVMECampaign");
        var retailerId = '';
        if (retailerValue != undefined && retailerValue != null) {
            retailerId = retailerValue;
        }

        var action = component.get("c.getVINBasedOnName");
        action.setParams({
            "schemeId": component.get("v.schemeId"),
            "parameterName": component.get("v.parameterName"),
            "retailerId": retailerId,
            "parentVME": component.get("v.parentVMECampaign")
        });
        action.setCallback(this, function(response) {
            this.hideSpinner(component, event, helper);
            if (response.getState() == 'SUCCESS') {
                var result = response.getReturnValue();
                if (!($A.util.isEmpty(result)) && result.length > 0) {
                    component.set("v.getAllVIN",true);
                    component.set("v.searchedData", true);
                    component.set("v.vinSearchList", result);
                    var productListLength = result.length;
                    var pageSize = component.get("v.pageSize");
                    var totalPages = Math.ceil(productListLength / pageSize);
                    if (productListLength < pageSize) pageSize = productListLength;
                    component.set("v.totalPages", totalPages);
                    component.set("v.pageNumber", 1);
                    if (productListLength < pageSize) pageSize = productListLength;
                    var paginationVINList = [];
                    for (var i = 0; i < pageSize; i++) {
                        paginationVINList.push(result[i]);
                    }
                    component.set("v.paginationVINList", paginationVINList);
                } else {
                    var existingVINList = component.get("v.existingVINList");
                    var vinSearchList = component.get("v.vinSearchList");
                    var toastEvent = $A.get("e.force:showToast");

                    if ($A.util.isEmpty(vinSearchList)) {
                        if ($A.util.isEmpty(existingVINList)) {
                            toastEvent.setParams({
                                "type": "error",
                                "mode": "dismissible",
                                "title": "Error!",
                                "message": 'No VIN Found!'
                            });
                            toastEvent.fire();
                            component.set("v.searchedData", false);
                        }
                    }
                }

            } else {
                this.hideSpinner(component, event, helper);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "error",
                    "mode": "dismissible",
                    "title": "Error!",
                    "message": response.getError()[0].message
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },

    showSpinner: function(component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },

    hideSpinner: function(component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide mySpinnerCss");
    },

    refreshAdjustmentPage : function (component, event, helper) {
        this.showSpinner(component, event, helper);
             var parentCamp = JSON.parse(JSON.stringify(component.get("v.parentVMECampaign")));
            var action =component.get("c.getUpdatedWrapperofCurrentVME");
              action.setParams({ recordId : parentCamp.Id});
             action.setCallback(this, function(response) {
                this.hideSpinner(component, event, helper);
            var state = response.getState();
                       if (state === "SUCCESS") {
                           var  compEvent = component.getEvent("adjustVariantEvt");
                             compEvent.setParams({
                              "updateVMECampWrapperList" :  response.getReturnValue(),
                              "openAdjustModel" :true
                          });
                              compEvent.fire();
                          
                       }
                   });
           $A.enqueueAction(action);      
       },

       deleteInvalidL3: function(component, event, helper) {
        this.showSpinner(component, event, helper);
        debugger;
         var action = component.get("c.deleteL3");
               action.setParams({
               "schemeId": component.get("v.schemeId")
           });
       action.setCallback(this, function(response) {
           this.hideSpinner(component, event, helper);
           if (response.getState() == $A.get("{!$Label.c.Success_Msg}")) {
           if( $A.get("{!$Label.c.Success_Msg}")==response.getReturnValue()){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "error",
                "title": "Invalid L3 VME Campaign!",
                "message": 'This L3 is not created as  no VIN  is attached.'
            });
            toastEvent.fire();
                  
                   if( component.get("v.compIdentityValue")==$A.get("{!$Label.c.VME_CategoryAdjustment}")){ 
                       helper.refreshCategoryPage(component, event, helper);
                       }
                       if( component.get("v.compIdentityValue")!=$A.get("{!$Label.c.VME_CategoryAdjustment}")){
                       helper.refreshAdjustmentPage(component, event, helper);
                     }
                     
                
           }else{
                 var toastEvent = $A.get("e.force:showToast");
                     toastEvent.setParams({
                       "type": "error",
                       "title": "ERROR!",
                       "message": 'Something went wrong.Please contact the administrator.'
                   });
                   toastEvent.fire();
           }
           }else{
                   var toastEvent = $A.get("e.force:showToast");
                     toastEvent.setParams({
                       "type": "error",
                       "title": "ERROR!",
                       "message": 'Something went wrong.Please contact the administrator.'
                   });
                   toastEvent.fire();
           }
       });
       $A.enqueueAction(action);
   },
})