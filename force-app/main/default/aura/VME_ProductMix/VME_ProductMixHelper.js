({
    doInit : function(component, event, helper) {
        var action = component.get("c.getFilterValues"); 
        var revisedSchemeValue = component.get("v.revisedSchemeValue");
        var revisedSchemeId = '';
        if(!($A.util.isEmpty(revisedSchemeValue)) && component.get("v.parameterName")==$A.get("{!$Label.c.Revise_VME_Parameter}")){
            revisedSchemeId     = revisedSchemeValue.Id;
        }
        action.setParams({"schemeId": component.get("v.schemeId"), "revisedSchemeId" : revisedSchemeId});
        component.set("v.pageSize", parseInt($A.get("{!$Label.c.Page_Size_Product_Mix}")));
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
               this.hideSpinner(component,event,helper);
               console.log(JSON.parse(JSON.stringify(result)));
            component.set("v.modelYearValuesList", result.modelYearValuesList);
            component.set("v.fuelTypeValuesList", result.fuelTypeValuesList);
            component.set("v.trimValuesList", result.trimValuesList);
            var arrayOfMapKeys = [];
            for (var keyValues in result.engineValuesList) {
                var ele = {
                        'label': keyValues,
                        'value': result.engineValuesList[keyValues]
                };
                arrayOfMapKeys.push(ele);
        }
            component.set("v.engineValuesList", arrayOfMapKeys);
            var arrayOfMapKeys = [];
            for (var keyValues in result.doorsValuesList) {
                var ele = {
                        'label': keyValues,
                        'value': result.doorsValuesList[keyValues]
                };
                arrayOfMapKeys.push(ele);
        }
            component.set("v.doorsValuesList", arrayOfMapKeys);
            if(!($A.util.isEmpty(result.exitingProductsList))){
                component.set("v.existingAllCheck",true);
                var productListLength   = (result.exitingProductsList).length;
                var pageSize            = component.get("v.pageSize");
                var totalPages          = Math.ceil(productListLength / pageSize);
                component.set("v.totalPagesExist", totalPages);
                component.set("v.pageNumberExist", 1);
                if(productListLength < pageSize)
                    pageSize    = productListLength;
                var paginationProductsList = [];
                for(var i = 0 ; i < pageSize; i++){
                    paginationProductsList.push(result.exitingProductsList[i]);
                }   
                component.set("v.paginationExitingProList", paginationProductsList);
            }
            component.set("v.exitingProductsList",result.exitingProductsList);
            this.searchProductsJS(component, event, helper);
        });
        $A.enqueueAction(action);
    },
    
    
    searchProductsJS : function(component, event, helper) {
        component.set("v.searchAllCheck",false);
        var vmeCampaign =component.get("v.currentVME");
        var imodelValue ;
        var imodelYearValue ;
        var ifuelTypeValue ;
        var itrimValue ;
        var iengineValue ;
        var idoorsValue ;
        
        if(component.get("v.modelValue") == undefined) imodelValue = '';
        if(component.get("v.modelYearValue") == undefined) imodelYearValue = '';
        if(component.get("v.fuelTypeValue") == undefined) ifuelTypeValue = '';
        if(component.get("v.trimValue") == undefined) itrimValue = '';
        if(component.get("v.engineValue") == undefined) iengineValue = '';
        if(component.get("v.doorsValue") == undefined) idoorsValue = '';
        
        var productArr = [];
        component.set("v.searchedProductsList", productArr);
        component.set("v.paginationProductsList", productArr);
        component.set("v.pageNumber", 0);
        component.set("v.totalPages", productArr);
        
        var action = component.get("c.searchProducts");
        action.setParams({"modelValue": component.get("v.modelValue"),
                          "modelYearValue": component.get("v.modelYearValue"),
                          "fuelTypeValue": component.get("v.fuelTypeValue"),
                          "trimValue": component.get("v.trimValue"),
                          "engineValue": component.get("v.engineValue"),
                          "doorsValue": component.get("v.doorsValue"),
                          "CountryCode": vmeCampaign.VME_Country_ISO_Code__c ,
                          "parameterName": component.get("v.parameterName"),
                          "schemeId" : component.get("v.schemeId")});
        action.setCallback(this, function(response) {
              this.hideSpinner(component,event,helper);
            if(response.getState() == 'SUCCESS'){
                 var result = response.getReturnValue();
                if(!($A.util.isEmpty(result)) && result.length>0){
               
                component.set("v.searchedProductsList", result);
                var productListLength   = result.length;
                var pageSize            = component.get("v.pageSize");
                var totalPages          = Math.ceil(productListLength / pageSize);
                component.set("v.totalPages", totalPages);
                component.set("v.pageNumber", 1);
                if(productListLength < pageSize)
                    pageSize    = productListLength;
                var paginationProductsList = [];
                for(var i = 0 ; i < pageSize; i++){
                    paginationProductsList.push(result[i]);
                }   
                component.set("v.paginationProductsList", paginationProductsList);
            }if($A.util.isEmpty(component.get("v.paginationProductsList")) && $A.util.isEmpty(component.get("v.exitingProductsList"))){

                       var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type":"error",
                    "mode":"dismissible",
                    "title": "Error!",
                    "message": 'No record Found!'
                });
                toastEvent.fire();
                }
            }
            else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type":"error",
                    "mode":"dismissible",
                    "title": "Error!",
                    "message": response.getError()[0].message
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    
    
    saveProductMix : function(component, event, helper){
       // var searchedProductsList =[];
        var pageSize                = component.get("v.pageSize");
        var pageNumber              = component.get("v.pageNumber");
        var paginationProductsList  = component.get("v.paginationProductsList");
        var searchedProductsList    = component.get("v.searchedProductsList");
        var  exitingProductsList =component.get("v.exitingProductsList");
        
       /* for(var i = 0; i < paginationProductsList.length; i++){
            searchedProductsList[(pageNumber - 1) * pageSize + i] = paginationProductsList[i];
        }*/
        
        var isSelectedFound     = false;
   
          if(!($A.util.isEmpty(exitingProductsList))){
        for(var i=0;i < exitingProductsList.length; i++){
            searchedProductsList.push(exitingProductsList[i]);
          
        }
    }
        var tempSelectedList =[];
         if(!($A.util.isEmpty(searchedProductsList))){
       for(var i = 0; i < searchedProductsList.length; i++){
           if(searchedProductsList[i].isSelected){
            tempSelectedList.push(searchedProductsList[i]);
            isSelectedFound = true;
           }
        }
    }
        if(($A.util.isEmpty(tempSelectedList)) && tempSelectedList.length==0 ){
                isSelectedFound = false;
                    var toastEvent = $A.get("e.force:showToast");
               toastEvent.setParams({
                        "type":"error",
                        "title": "ERROR!",
                        "message": 'Please select atleast one product.'
                    });
            
                toastEvent.fire();
        }

        if(isSelectedFound){
            var action = component.get("c.saveProductMixRecords");
            action.setParams({"productWrapReqList": searchedProductsList, "schemeId" : component.get("v.schemeId"),
                             "parameterName": component.get("v.parameterName")});
            action.setCallback(this, function(response) {
                var result  = response.getReturnValue();
                this.hideSpinner(component,event,helper);
                var toastEvent = $A.get("e.force:showToast");
                if(result == $A.get("{!$Label.c.Success_Msg}")){
                    toastEvent.setParams({
                        "type":"success",
                        "mode":"dismissible",
                        "title": "SUCCESS!",
                        "message": "Saved successfully."
                    });
                   //alert(event.getSource().get("v.title"));
                    if(event.getSource().get("v.title")=='dealers'){
                    this.callDealerMix(component,event,helper);
                }else{
                    if( component.get("v.compIdentityValue")==$A.get("{!$Label.c.VME_CategoryAdjustment}")){ 
                        this.refreshCategoryPage(component, event, helper);
                        }
                        if( component.get("v.compIdentityValue")!=$A.get("{!$Label.c.VME_CategoryAdjustment}")){
                        this.refreshAdjustmentPage(component, event, helper);
                      }
                      
                }
                }else{
                    toastEvent.setParams({
                        "type":"error",
                        "title": "ERROR!",
                        "message": result
                    });
                }
                toastEvent.fire();
            });
            $A.enqueueAction(action);
        }
        
    },
    
    
    nextPage : function(component, event, helper) {
  
        var pageSize                = component.get("v.pageSize");
        var pageNumber              = component.get("v.pageNumber");
        var paginationProductsList  = component.get("v.paginationProductsList");
        var searchedProductsList    = component.get("v.searchedProductsList");
        
        for(var i = 0; i < paginationProductsList.length; i++){
            searchedProductsList[(pageNumber - 1) * pageSize + i] = paginationProductsList[i];
        }
        component.set("v.searchedProductsList", searchedProductsList);
        
        paginationProductsList = [];
        var startingIndex = (pageSize * pageNumber) ;
        var lastIndex     = startingIndex + pageSize;
        if(searchedProductsList.length < lastIndex)
            lastIndex = searchedProductsList.length;
        for(var i = startingIndex ; i < lastIndex; i++){
            paginationProductsList.push(searchedProductsList[i]);
        }
        component.set("v.paginationProductsList", paginationProductsList);
        component.set("v.pageNumber", pageNumber +  1);
    },
    
    
    previousPage : function(component, event, helper) {
        var pageSize                = component.get("v.pageSize");
        var pageNumber              = component.get("v.pageNumber");
        var paginationProductsList  = component.get("v.paginationProductsList");
        var searchedProductsList    = component.get("v.searchedProductsList");
        
        for(var i = 0; i < paginationProductsList.length; i++){
            searchedProductsList[(pageNumber - 1) * pageSize + i] = paginationProductsList[i];
        }
        component.set("v.searchedProductsList", searchedProductsList);
        
        paginationProductsList = [];
        var lastIndex         = (pageSize * (pageNumber - 1)) ;
        var startingIndex     = lastIndex - pageSize;
        for(var i = startingIndex ; i < lastIndex; i++){
            paginationProductsList.push(searchedProductsList[i]);
        }
        component.set("v.paginationProductsList", paginationProductsList);
        component.set("v.pageNumber", pageNumber -  1);
        
    },
    callDealerMix :function(component,event,helper){
      var  compEvent = component.getEvent("VME_callDealerMixEvent");
      this.showSpinner(component,event,helper);
        compEvent.setParams({
            "newSchemeId" : component.get("v.schemeId"),
            "VMEParameter" : component.get("v.parameterName"),
            "revisedScheme" : component.get("v.revisedSchemeValue"),
           "recordDetails": component.get("v.currentVME"),
           "CompId": component.get("v.compIdentityValue"),
           "schemeApplicable" : 'DerivativeWise'
          });
     compEvent.fire();
        component.set("v.isOpen",false);    
    },
    nextExistPage : function(component, event, helper) {
  
        var pageSize                = component.get("v.pageSize");
        var pageNumber              = component.get("v.pageNumberExist");
        var paginationProductsList  = component.get("v.paginationExitingProList");
        var searchedProductsList    = component.get("v.exitingProductsList");
        
        for(var i = 0; i < paginationProductsList.length; i++){
            searchedProductsList[(pageNumber - 1) * pageSize + i] = paginationProductsList[i];
        }
        component.set("v.exitingProductsList", searchedProductsList);
        
        paginationProductsList = [];
        var startingIndex = (pageSize * pageNumber) ;
        var lastIndex     = startingIndex + pageSize;
        if(searchedProductsList.length < lastIndex)
            lastIndex = searchedProductsList.length;
        for(var i = startingIndex ; i < lastIndex; i++){
            paginationProductsList.push(searchedProductsList[i]);
        }
        component.set("v.paginationExitingProList", paginationProductsList);
        component.set("v.pageNumberExist", pageNumber +  1);
    },
    
    
    previousExistPage : function(component, event, helper) {
        var pageSize                = component.get("v.pageSize");
        var pageNumber              = component.get("v.pageNumberExist");
        var paginationProductsList  = component.get("v.paginationProductsList");
        var searchedProductsList    = component.get("v.searchedProductsList");
        
        for(var i = 0; i < paginationProductsList.length; i++){
            searchedProductsList[(pageNumber - 1) * pageSize + i] = paginationProductsList[i];
        }
        component.set("v.searchedProductsList", searchedProductsList);
        
        paginationProductsList = [];
        var lastIndex         = (pageSize * (pageNumber - 1)) ;
        var startingIndex     = lastIndex - pageSize;
        for(var i = startingIndex ; i < lastIndex; i++){
            paginationProductsList.push(searchedProductsList[i]);
        }
        component.set("v.paginationProductsList", paginationProductsList);
        component.set("v.pageNumberExist", pageNumber -  1);
        
    },


      showSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
     

    hideSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    },

    

    refreshCategoryPage :  function (component, event, helper) {
        var cmpEvent = component.getEvent("refreshCmpEvt");
    
                cmpEvent.fire(); 
                component.set("v.isOpen",false);         
    },

    resetProductsJS :function(component, event, helper){
    component.set("v.modelYearValue", $A.get("{!$Label.c.Please_Select_Value_VME}"));
    component.set("v.fuelTypeValue", $A.get("{!$Label.c.Please_Select_Value_VME}"));
    component.set("v.trimValue", $A.get("{!$Label.c.Please_Select_Value_VME}"));
    component.set("v.engineValue", $A.get("{!$Label.c.Please_Select_Value_VME}"));
    component.set("v.doorsValue", $A.get("{!$Label.c.Please_Select_Value_VME}"));
    component.set("v.searchedProductsList",null);
    },

    errorConfirmModel :function(component, event, helper){
     var  exitingProductsList  = component.get("v.exitingProductsList");
        if($A.util.isEmpty(exitingProductsList)){
            Swal.fire({
                title: "Invalid L3 VME Campaign",
                 text: "It is an invalid L3.Please select product else continue  to configure it later.",
                  type: "warning",
                  showCancelButton: true,
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
},

changeAllSearchList :function(component, event, helper){
    var searchedProductsList    = component.get("v.searchedProductsList");
    var paginationProductsList    = component.get("v.paginationProductsList");
    var selectAll =component.get("v.searchAllCheck");
    if(!($A.util.isEmpty(searchedProductsList))){
        for(var i = 0; i < searchedProductsList.length; i++){
            searchedProductsList[i].isSelected =selectAll;
            }
                var productListLength   = searchedProductsList.length;
                var pageSize            = component.get("v.pageSize");
                var totalPages          = Math.ceil(productListLength / pageSize);
                component.set("v.totalPages", totalPages);
                component.set("v.pageNumber", 1);
                if(productListLength < pageSize)
                    pageSize    = productListLength;
                var paginationProductsList = [];
                for(var i = 0 ; i < pageSize; i++){
                    paginationProductsList.push(searchedProductsList[i]);
                }   
                component.set("v.paginationProductsList", paginationProductsList);
    }
},

changeAllExistingList :function(component, event, helper){
    var searchedProductsList    = component.get("v.exitingProductsList");
    var paginationProductsList    = component.get("v.paginationExitingProList");
    var selectAll =component.get("v.existingAllCheck");
    if(!($A.util.isEmpty(searchedProductsList))){
        for(var i = 0; i < searchedProductsList.length; i++){
            searchedProductsList[i].isSelected =selectAll;
            }
                var productListLength   = searchedProductsList.length;
                var pageSize            = component.get("v.pageSize");
                var totalPages          = Math.ceil(productListLength / pageSize);
                component.set("v.totalPagesExist", totalPages);
                component.set("v.pageNumberExist", 1);
                if(productListLength < pageSize)
                    pageSize    = productListLength;
                var paginationProductsList = [];
                for(var i = 0 ; i < pageSize; i++){
                    paginationProductsList.push(searchedProductsList[i]);
                }   
                component.set("v.paginationExitingProList", paginationProductsList);
    }
},

refreshAdjustmentPage : function (component, event, helper) {
    this.showSpinner(component, event, helper);
         var parentCamp = JSON.parse(JSON.stringify(component.get("v.currentVME")));
        var action =component.get("c.getUpdatedWrapperofCurrentVME");
          action.setParams({ recordId : parentCamp.Id});
         action.setCallback(this, function(response) {
            this.hideSpinner(component, event, helper);
        var state = response.getState();
                   if (state === "SUCCESS") {
                       var  compEvent = component.getEvent("adjustVariantEvt1");
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