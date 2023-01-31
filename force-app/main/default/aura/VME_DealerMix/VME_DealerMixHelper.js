({
    doInit: function(component, event, helper) {
        this.showSpinner(component, event, helper);
        var action = component.get("c.getExistingDealersForScheme");
        var revisedSchemeValue = component.get("v.revisedSchemeValue");
        var revisedSchemeId = '';
        if (!($A.util.isEmpty(revisedSchemeValue)) && component.get("v.parameterName") == $A.get("{!$Label.c.Revise_VME_Parameter}")) {
            revisedSchemeId = revisedSchemeValue.Id;
        }
        action.setParams({
            "schemeId": component.get("v.schemeId"),
            "parameterName": component.get("v.parameterName"),
            "revisedSchemeId": revisedSchemeId
        });
        action.setCallback(this, function(response) {
            this.hideSpinner(component, event, helper);
            if (response.getState() == 'SUCCESS') {

                component.set("v.existingDealerList", response.getReturnValue());
                this.getRecordTypeIdDiscreationary(component, event, helper);
            }
        });
        $A.enqueueAction(action);
    },


    searchDealers: function(component, event, helper) {
        this.showSpinner(component, event, helper);
         var tempListToDisplay =[];
        var dealerNameSearchValue = component.get("v.dealerNameSearchValue");
        if (dealerNameSearchValue === '' || dealerNameSearchValue === undefined || !dealerNameSearchValue.replace(/\s/g, '').length) {
            helper.onLoadGetAllDealers(component, event, helper);
        } else {
                 this.hideSpinner(component, event, helper);
        var dealerSearchList =    component.get("v.dealerSearchList");
            if(!($A.util.isEmpty(dealerSearchList)) && dealerSearchList.length>0){
            for (var i = 0; i < dealerSearchList.length; i++) {
            if(((dealerSearchList[i].accountObj.Name).toLowerCase()).includes(dealerNameSearchValue.toLowerCase())){
                tempListToDisplay.push(dealerSearchList[i]);
            }
        }
    }
          // component.set("v.dealerSearchList", tempListToDisplay);
          if(!($A.util.isEmpty(tempListToDisplay)) && tempListToDisplay.length>0){
            this.hideSpinner(component, event, helper);
              component.set("v.searchedData",true);
            var productListLength = tempListToDisplay.length;
                                var pageSize = component.get("v.pageSize");
                                var totalPages = Math.ceil(productListLength / pageSize);
                                if (productListLength < pageSize) pageSize = productListLength;
                                component.set("v.totalPages", totalPages);
                                component.set("v.pageNumber", 1);
                                var paginationDealersList = [];
                                for (var i = 0; i < pageSize; i++) {
                                    paginationDealersList.push(tempListToDisplay[i]);
                                }
                                component.set("v.paginationDealersList", paginationDealersList);
                            }else{
                                this.hideSpinner(component, event, helper);
                                 component.set("v.searchedData",false);
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
        var paginationDealersList = component.get("v.paginationDealersList");
        var dealerSearchList = component.get("v.dealerSearchList");

        for (var i = 0; i < paginationDealersList.length; i++) {
            dealerSearchList[(pageNumber - 1) * pageSize + i] = paginationDealersList[i];
        }
        component.set("v.dealerSearchList", dealerSearchList);

        paginationDealersList = [];
        var startingIndex = (pageSize * pageNumber);
        var lastIndex = startingIndex + pageSize;
        if (dealerSearchList.length < lastIndex)
            lastIndex = dealerSearchList.length;
        for (var i = startingIndex; i < lastIndex; i++) {
            paginationDealersList.push(dealerSearchList[i]);
        }
        component.set("v.paginationDealersList", paginationDealersList);
        component.set("v.pageNumber", pageNumber + 1);
    },


    previousPage: function(component, event, helper) {
        var pageSize = component.get("v.pageSize");
        var pageNumber = component.get("v.pageNumber");
        var paginationDealersList = component.get("v.paginationDealersList");
        var dealerSearchList = component.get("v.dealerSearchList");

        for (var i = 0; i < paginationDealersList.length; i++) {
            dealerSearchList[(pageNumber - 1) * pageSize + i] = paginationDealersList[i];
        }
        component.set("v.dealerSearchList", dealerSearchList);

        paginationDealersList = [];
        var lastIndex = (pageSize * (pageNumber - 1));
        var startingIndex = lastIndex - pageSize;
        for (var i = startingIndex; i < lastIndex; i++) {
            paginationDealersList.push(dealerSearchList[i]);
        }
        component.set("v.paginationDealersList", paginationDealersList);
        component.set("v.pageNumber", pageNumber - 1);

    },


    cancelDealerMix: function(component, event, helper) {
        this.hideSpinner(component, event, helper);
        component.set("v.isOpenComp", false);
    },


    saveDealerMix: function(component, event, helper) {
        this.showSpinner(component, event, helper);
        var dealerSearchList = [];
        var pageSize = component.get("v.pageSize");
        var pageNumber = component.get("v.pageNumber");
        var paginationDealersList = component.get("v.paginationDealersList");
        var dealerTempList = component.get("v.dealerSearchList");
        if (!($A.util.isEmpty(dealerTempList))) {
            for (var i = 0; i < dealerTempList.length; i++) {
                dealerSearchList.push(dealerTempList[i]);
            }
        }
        var existingDealerList = component.get("v.existingDealerList");

    
          if (!($A.util.isEmpty(existingDealerList))) {
            for (var i = 0; i < existingDealerList.length; i++) {
                dealerSearchList.push(existingDealerList[i]);
            }
        }

        var isSelectedFound = false;
        var tempArray = [];
        if(!($A.util.isEmpty(dealerSearchList))){
        for (var i = 0; i < dealerSearchList.length; i++) {
            if (dealerSearchList[i].isSelected)
                tempArray.push(dealerSearchList[i]);
            //   isSelectedFound = true;
        }
    }

        var parentVMECamp = component.get("v.parentVMECampaign");
         var toastEvent = $A.get("e.force:showToast");
        if (component.get("v.VMECampDiscreationary") == parentVMECamp.RecordTypeId) {
            if (!($A.util.isEmpty(tempArray)) && tempArray.length != 1) { 
                this.hideSpinner(component, event, helper);
                toastEvent.setParams({
                    "type": "error",
                    "title": "ERROR!",
                    "message": 'Please select only one Dealer for the Discreationary L2 VME Category'
                });
                toastEvent.fire();
                isSelectedFound = false;
            } else if(!($A.util.isEmpty(tempArray)) && tempArray.length == 1) {
                isSelectedFound = true;
            }else{
                this.hideSpinner(component, event, helper);
                 isSelectedFound = false;
                   toastEvent.setParams({
                    "type": "error",
                    "title": "ERROR!",
                    "message": 'Please select only one Dealer for the Discreationary L2 VME Category'
                });
                toastEvent.fire();
            }
        } else {
                this.hideSpinner(component, event, helper);
                 if ($A.util.isEmpty(tempArray)  && component.get("v.schemeApplicable")!='ModelWise') { 
                    if( component.get("v.compIdentityValue")==$A.get("{!$Label.c.VME_CategoryAdjustment}")){ 
                        helper.refreshCategoryPage(component, event, helper);
                        }
                        if( component.get("v.compIdentityValue")!=$A.get("{!$Label.c.VME_CategoryAdjustment}")){
                        helper.refreshAdjustmentPage(component, event, helper);
                      }
                 }
                 if ($A.util.isEmpty(tempArray) && component.get("v.schemeApplicable")=='ModelWise' &&  component.get("v.filtersValue")==false) { 
                    this.hideSpinner(component, event, helper);
                    isSelectedFound = false;
                 toastEvent.setParams({
                  "type": "error",
                  "title": "ERROR!",
                  "message": 'Please select atleast one Dealer'
              });
              toastEvent.fire();
               }
            for (var i = 0; i < dealerSearchList.length; i++) {
                if (dealerSearchList[i].isSelected)
                    isSelectedFound = true;
            }
            this.hideSpinner(component, event, helper);
            if ($A.util.isEmpty(tempArray) && component.get("v.schemeApplicable")=='ModelWise' &&  component.get("v.filtersValue")==true) { 
                this.showSpinner(component, event, helper);
                var action = component.get("c.relatedBundling");
                action.setParams({
                   "scheme":  component.get("v.schemeId"),
                 "model" : parentVMECamp.VME_Model__c,
                 "deleteBundel" : false
               });
                action.setCallback(this, function(response) {
                   this.hideSpinner(component, event, helper);
                   var result =response.getReturnValue();
                     if (response.getState() == $A.get("{!$Label.c.Success_Msg}")) {
                       helper.refreshAdjustmentPage(component, event, helper);
                     }else{
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                          "type": "error",
                          "title": "Something went wrong!",
                          "message": 'Please contact the administrator,.'
                      });
                      toastEvent.fire();
                   }
               });
               $A.enqueueAction(action);
                  
            }
        }
        
        if (isSelectedFound && event.getSource().get("v.title")=='dealers') {
            this.showSpinner(component, event, helper);
            var action = component.get("c.saveDealerMixRecords");
            action.setParams({
                "wrapperList": dealerSearchList,
                "schemeId": component.get("v.schemeId"),
                "parameterName": component.get("v.parameterName")
                
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
                    toastEvent.fire();
                    if (parentVMECamp.RecordTypeId == component.get("v.VMECampDiscreationary")) {
                        var savedretailerId;
                          if(!($A.util.isEmpty(dealerSearchList))){
                            for (var i = 0; i < dealerSearchList.length; i++) {
                                if (dealerSearchList[i].isSelected)
                                   savedretailerId = dealerSearchList[i].accountObj.Id;
                                //   isSelectedFound = true;
                            }
                     }
                  
                    this.callVinPage(component, event, helper, savedretailerId);
                       
                    } else {
                        if( component.get("v.compIdentityValue")==$A.get("{!$Label.c.VME_CategoryAdjustment}")){ 
                            helper.refreshCategoryPage(component, event, helper);
                            }
                            if( component.get("v.compIdentityValue")!=$A.get("{!$Label.c.VME_CategoryAdjustment}")){
                            helper.refreshAdjustmentPage(component, event, helper);
                          }
                          
                    }
                } else {

                    toastEvent.setParams({
                        "type": "error",
                        "title": "ERROR!",
                        "message": result
                    });
                    toastEvent.fire();

                }

            });
            $A.enqueueAction(action);
        } 
          
    },

    closeConfirmModel: function(component, event, helper) {
         var existingDealerList = component.get("v.existingDealerList");
         var parentVMECamp = component.get("v.parentVMECampaign");
        if(component.get("v.schemeApplicable")=='ModelWise' && $A.get("{!$Label.c.New_VME_Parameter}")==component.get("v.parameterName") && component.get("v.filtersValue")==false && component.get("v.VMECampDiscreationary") != parentVMECamp.RecordTypeId){
            Swal.fire({
                 title: "Invalid L3 VME Campaign",
                  text: "Don\'t cancel this process.You didn't have any filter.Please select atleast one Retailer or continue to remove it.",
                   type: "warning",
                   showCancelButton: true,
                   confirmButtonColor: '#3085d6',
                   cancelButtonColor:   '#d33',
                   confirmButtonText: 'Continue',
                   cancelButtonText: 'Cancel',
                })
                .then((result) => {
                  if (result.value) {
                  
                        helper.deleteInvalidL3(component, event, helper);
                  } else{
                        
                  }
                  });
        }
        if(component.get("v.schemeApplicable")=='ModelWise' && $A.get("{!$Label.c.New_VME_Parameter}")==component.get("v.parameterName") && component.get("v.filtersValue")==true && component.get("v.VMECampDiscreationary") != parentVMECamp.RecordTypeId){
            if( component.get("v.compIdentityValue")==$A.get("{!$Label.c.VME_CategoryAdjustment}")){ 
                helper.refreshCategoryPage(component, event, helper);
                }
                if( component.get("v.compIdentityValue")!=$A.get("{!$Label.c.VME_CategoryAdjustment}")){
                helper.refreshAdjustmentPage(component, event, helper);
              }
        }
          if(component.get("v.schemeApplicable")=='ModelWise' && $A.get("{!$Label.c.New_VME_Parameter}")!=component.get("v.parameterName") && component.get("v.filtersValue")==false && component.get("v.VMECampDiscreationary") != parentVMECamp.RecordTypeId){
            if ($A.util.isEmpty(existingDealerList)) {
                Swal.fire({
                    title: "Invalid L3 VME Campaign",
                     text: "You didn't have any filter.Please select atleast one Retailer or continue to remove it.",
                      type: "warning",
                      showCancelButton: true,
                      confirmButtonColor: '#3085d6',
                      cancelButtonColor:   '#d33',
                      confirmButtonText: 'Continue',
                      cancelButtonText: 'Cancel',
                   })
                   .then((result) => {
                     if (result.value) {
                        this.showSpinner(component, event, helper);
                     var action = component.get("c.relatedBundling");
                     action.setParams({
                        "scheme":  component.get("v.schemeId"),
                      "model" : parentVMECamp.VME_Model__c,
                      "deleteBundel" : true
                    });
                     action.setCallback(this, function(response) {
                        this.hideSpinner(component, event, helper);
                        var result =response.getReturnValue();
                          if (response.getState() == $A.get("{!$Label.c.Success_Msg}")) {
                            helper.refreshAdjustmentPage(component, event, helper);
                          }else{
                             var toastEvent = $A.get("e.force:showToast");
                             toastEvent.setParams({
                               "type": "error",
                               "title": "Something went wrong!",
                               "message": 'Please contact the administrator,.'
                           });
                           toastEvent.fire();
                        }
                    });
                    $A.enqueueAction(action);
                      
                     } else{
                           
                     }
                     });
                 }else{
                    if(component.get("v.parameterName")==$A.get("{!$Label.c.Revise_VME_Parameter}")){

                        Swal.fire({
                            title: "Revise L3 VME Campaign",
                             text: "Please click on save to ensure product selection, else this L3 configuration will be incomplete.",
                              showCancelButton: true,
                              type: "warning",
                              confirmButtonColor: '#3085d6',
                              cancelButtonColor: '#d33',
                              confirmButtonText: 'Continue',
                              cancelButtonText: 'Cancel'
                           })
                           .then((result) => {
                             if (result.value) {
                                helper.refreshAdjustmentPage(component, event, helper);
                             } 
                             });
                    }else{
                        if( component.get("v.compIdentityValue")==$A.get("{!$Label.c.VME_CategoryAdjustment}")){ 
                           this.refreshCategoryPage(component, event, helper);
                       }
                       if( component.get("v.compIdentityValue")!=$A.get("{!$Label.c.VME_CategoryAdjustment}")){
                           this.refreshAdjustmentPage(component, event, helper);
                       }
                    }   
                 }
             }
         if(component.get("v.schemeApplicable")=='ModelWise' && $A.get("{!$Label.c.New_VME_Parameter}")!=component.get("v.parameterName") && component.get("v.filtersValue")==true && component.get("v.VMECampDiscreationary") != parentVMECamp.RecordTypeId){
             //create bundeling firstly
             this.showSpinner(component, event, helper);
             var action = component.get("c.relatedBundling");
             action.setParams({
                "scheme":  component.get("v.schemeId"),
              "model" : parentVMECamp.VME_Model__c,
              "deleteBundel" : false
            });
             action.setCallback(this, function(response) {
                this.hideSpinner(component, event, helper);
                var result =response.getReturnValue();
                  if (response.getState() == $A.get("{!$Label.c.Success_Msg}")) {
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
                       "title": "Something went wrong!",
                       "message": 'Please contact the administrator,.'
                   });
                   toastEvent.fire();
                }
            });
            $A.enqueueAction(action);
            
            
          }

         if(component.get("v.schemeApplicable")=='DerivativeWise'  && component.get("v.VMECampDiscreationary") != parentVMECamp.RecordTypeId){
            if( component.get("v.compIdentityValue")==$A.get("{!$Label.c.VME_CategoryAdjustment}")){ 
                helper.refreshCategoryPage(component, event, helper);
                }
                if( component.get("v.compIdentityValue")!=$A.get("{!$Label.c.VME_CategoryAdjustment}")){
                helper.refreshAdjustmentPage(component, event, helper);
              }
              
          }

          if(component.get("v.VMECampDiscreationary") == parentVMECamp.RecordTypeId && $A.get("{!$Label.c.New_VME_Parameter}")==component.get("v.parameterName")){      
            Swal.fire({
                title: "Invalid L3 VME Campaign",
                 text: "Please select atleast one Retailer for Discreationary.",
                  type: "error",
                  showCancelButton: true,
                  confirmButtonColor: '#3085d6',
                  cancelButtonColor: '#d33',
                  confirmButtonText: 'Continue',
                  cancelButtonText: 'Cancel',
               })
               .then((result) => {
                 if (result.value) {
                    helper.refreshAdjustmentPage(component, event, helper);
                 } 
                });
            }
         if(component.get("v.VMECampDiscreationary") == parentVMECamp.RecordTypeId && $A.get("{!$Label.c.New_VME_Parameter}")!=component.get("v.parameterName")){      
             if ($A.util.isEmpty(existingDealerList)) {
                Swal.fire({
                    title: "Invalid L3 VME Campaign",
                    text: "Please select atleast one Retailer for Discreationary.",
                     type: "error",
                     showCancelButton: true,
                     confirmButtonColor: '#3085d6',
                     cancelButtonColor: '#d33',
                     confirmButtonText: 'Continue',
                     cancelButtonText: 'Cancel',
                  })
                   .then((result) => {
                     if (result.value) {
                        helper.refreshAdjustmentPage(component, event, helper);
                     } 
                    });
                 }else{
                    if( component.get("v.compIdentityValue")==$A.get("{!$Label.c.VME_CategoryAdjustment}")){ 
                        helper.refreshCategoryPage(component, event, helper);
                        }
                        if( component.get("v.compIdentityValue")!=$A.get("{!$Label.c.VME_CategoryAdjustment}")){
                        helper.refreshAdjustmentPage(component, event, helper);
                      }
                      
                 }
             }
    },

    refreshCategoryPage: function(component, event, helper) {
        this.hideSpinner(component, event, helper);
        var cmpEvent = component.getEvent("refreshCmpEvt");
        cmpEvent.fire();
        component.set("v.isOpenComp", false);
    },

    showSpinner: function(component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },

    hideSpinner: function(component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    },

    getRecordTypeIdDiscreationary: function(component, event, helper) {
        this.showSpinner(component, event, helper);
        var action = component.get("c.getRecordTypeOfVMEDiscreationary");
        action.setCallback(this, function(response) {
            this.hideSpinner(component, event, helper);
            if (response.getState() == 'SUCCESS') {
                component.set("v.VMECampDiscreationary", response.getReturnValue());
                this.getFormatofDate(component, event, helper);
            }
        });
        $A.enqueueAction(action);
    },

    callVinPage: function(component, event, helper, retailerId) {
        var compEvent = component.getEvent("VME_VinMixEvt");
        compEvent.setParams({
            "newSchemeId": component.get("v.schemeId"),
            "revisedScheme": component.get("v.revisedSchemeValue"),
            "VMEParameter": component.get("v.parameterName"),
            "CompId": component.get("v.compIdentityValue"),
            "RetailerId" :retailerId,
            "recordDetails" : component.get("v.parentVMECampaign"),
        });
        compEvent.fire();
        this.cancelDealerMix(component, event, helper);
    },


 onLoadGetAllDealers: function (component, event, helper) {
    var dealerArr = [];
        var parentVMECamp = component.get("v.parentVMECampaign");
        component.set("v.dealerSearchList", dealerArr);
        component.set("v.paginationDealersList", dealerArr);
        component.set("v.pageNumber", 0);
        component.set("v.totalPages", 0);
        component.set("v.pageSize", parseInt($A.get("{!$Label.c.Page_Size_Product_Mix}")));
        this.showSpinner(component, event, helper);
        var revisedSchemeId;
        var revisedSchemeValue = component.get("v.revisedSchemeValue");
        if (!($A.util.isEmpty(revisedSchemeValue)) && component.get("v.parameterName") == $A.get("{!$Label.c.Revise_VME_Parameter}")) {
            revisedSchemeId = revisedSchemeValue.Id;
        }else{
            revisedSchemeId =    component.get("v.schemeId");
        }

     var action = component.get("c.getDealersBasedOnName");
            action.setParams({
             //   "dealerNameSearchValue": dealerNameSearchValue,
                "parameterName": component.get("v.parameterName"),
                "countryIsoCode" :parentVMECamp.VME_Country_ISO_Code__c,
                            "schemeId": revisedSchemeId
            });
            action.setCallback(this, function(response) {
                this.hideSpinner(component, event, helper);
                if (response.getState() == 'SUCCESS') {
                    var result = response.getReturnValue();
                                 if(!($A.util.isEmpty(result)) && result.length>0){
                           
                                component.set("v.dealerSearchList", result);
                                component.set("v.searchedData",true);
                                var productListLength = result.length;
                                var pageSize = component.get("v.pageSize");
                                var totalPages = Math.ceil(productListLength / pageSize);
                                if (productListLength < pageSize) pageSize = productListLength;
                                component.set("v.totalPages", totalPages);
                                component.set("v.pageNumber", 1);
                                var paginationDealersList = [];
                                for (var i = 0; i < pageSize; i++) {
                                    paginationDealersList.push(result[i]);
                                }
                                component.set("v.paginationDealersList", paginationDealersList);
                } 
                if($A.util.isEmpty(component.get("v.paginationDealersList")) && $A.util.isEmpty(component.get("v.existingDealerList"))){
              
                       var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type":"error",
                    "mode":"dismissible",
                    "title": "Error!",
                    "message": 'No record Found!'
                });
                toastEvent.fire();
                } 
              } else {
             
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
   getFormatofDate: function(component, event, helper) {
        var action = component.get("c.loggedInFormat");
        action.setCallback(this, function(response) {
            this.hideSpinner(component, event, helper);
            if (response.getState() == 'SUCCESS') {
                component.set("v.formatDate", response.getReturnValue());
                this.onLoadGetAllDealers(component, event, helper);
            }
        });
        $A.enqueueAction(action);
    },
    deleteInvalidL3: function(component, event, helper) {
         this.showSpinner(component, event, helper);
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
                        "type": "warning",
                        "title": "L3 Campaign is invalid.",
                        "message": 'This ModelWise Campaign doesn\'t have any filters.Please create new L3 Campaign.'
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
   
})