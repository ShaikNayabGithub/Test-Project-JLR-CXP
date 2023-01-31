({
          getUserDetails : function(component, event, helper) {
                    this.showSpinner(component,event,helper);
                var action = component.get("c.getUserDetails");
                action.setCallback(this, function(response) {
                      this.hideSpinner(component,event,helper);
                        var state = response.getState();
                        if (state === "SUCCESS") {
                                var storeResponse = response.getReturnValue();
                                 if(component.get("v.countrycode") !='All'){
                                      component.set("v.selectedCountry", component.get("v.countrycode"));
                                      component.set("v.makeCountryDisabled",true);
                                }
                                if(storeResponse.Country_ISO_Code__c != "" && storeResponse.Country_ISO_Code__c != null && storeResponse.Country_ISO_Code__c != undefined){
                                                component.set("v.selectedCountry", storeResponse.Country_ISO_Code__c);
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


    getRecordTypesMethod: function(component, event, helper) {
        this.showSpinner(component, event, helper);
        var action = component.get("c.getAllRecordTypesOfVME");
        var arrayOfMapobjs = [];
        action.setCallback(this, function(response) {
            this.hideSpinner(component, event, helper);
            var state = response.getState();
            if (state ===  $A.get("{!$Label.c.VME_SUCCESS}")) {
                var result = response.getReturnValue();
                for (var obj in result) {
                  //  if (result[obj].defaultValue) {
                          if (result[obj].name=='Regular') {
                        component.set("v.selectedRecordType", result[obj].typeId);
                    }
                    arrayOfMapobjs.push({
                        label: result[obj].name,
                        value: result[obj].typeId
                    });
                }
                for (var i in arrayOfMapobjs) {
                    if (component.get("v.selectedRecordType") == arrayOfMapobjs[i].value) {
                        var temp = arrayOfMapobjs[0];
                        arrayOfMapobjs[0] = arrayOfMapobjs[i];
                        arrayOfMapobjs[i] = temp;
                    }
                }
                component.set("v.recordTypesList", arrayOfMapobjs);
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


    getCatSubCatMap: function(component, event, helper) {
        var action = component.get("c.getCat_SubCat");
        action.setCallback(this, function(response) {
            this.hideSpinner(component, event, helper);
            var state = response.getState();
            if (state ===  $A.get("{!$Label.c.VME_SUCCESS}")) {
                var result = response.getReturnValue();
                component.set("v.categorySubcategoryMap", result);
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

       getMarketCodesMap: function(component, event, helper) {
        var action = component.get("c.getMarketCode");
        action.setCallback(this, function(response) {
            this.hideSpinner(component, event, helper);
            var state = response.getState();
            if (state ===  $A.get("{!$Label.c.VME_SUCCESS}")) {
                var result = response.getReturnValue();
                component.set("v.categoryMarketMap", result);
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

        getBrandCodesMap: function(component, event, helper) {
        var action = component.get("c.getBrandCode");
        action.setCallback(this, function(response) {
            this.hideSpinner(component, event, helper);
            var state = response.getState();
            if (state ===  $A.get("{!$Label.c.VME_SUCCESS}")) {
                var result = response.getReturnValue();
                component.set("v.categoryBrandMap", result);
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


    Next: function(component, event, helper) {
        this.showSpinner(component, event, helper);
        var arrayOfMapobjs = component.get("v.recordTypesList");
        for (var i in arrayOfMapobjs) {
            if (component.get("v.selectedRecordType") == arrayOfMapobjs[i].value) {
                component.set("v.selectedRecordTypeName", arrayOfMapobjs[i].label);
            }
        }
        component.set("v.showtypes", false);
        this.hideSpinner(component, event, helper);
    },


    handleSubmit: function(component, event, helper) {
        var fields = event.getParam("fields");
        var error = false;
          this.hideSpinner(component, event, helper);
        if (fields["VME_Start_Date__c"] === "" || fields["VME_End_Date__c"] === "" || fields["VME_Category__c"] === "" || fields["VME_Sub_Category__c"] === "" || fields["VME_Adjusted_PU_Amount__c"] === "" || fields["VME_Adjusted_Volume__c"] === "" || fields["VME_Start_Date__c"] === null || fields["VME_End_Date__c"] === null || fields["VME_Category__c"] === null || fields["VME_Sub_Category__c"] === null || fields["VME_Adjusted_Volume__c"] === null || fields["VME_Adjusted_PU_Amount__c"] === null) {
            helper.showToast(component, event, helper,  $A.get("{!$Label.c.VME_Error}"), 'Please fill all the required fields', 'error', 'info_alt');
            error = true;
        }
        if (Number(fields["VME_Adjusted_PU_Amount__c"]) < 1 || Number(fields["VME_Adjusted_Volume__c"]) < 1) {
            helper.showToast(component, event, helper,  $A.get("{!$Label.c.VME_Error}"), 'Adjusted PU Amount/Adjusted Volume should not be less than 1.', 'error', 'info_alt');
            error = true;
        }
        var ParentCamp = JSON.parse(JSON.stringify(component.get("v.parentCamp")));
        if (ParentCamp.StartDate > fields["VME_Start_Date__c"] || ParentCamp.EndDate < fields["VME_End_Date__c"] || ParentCamp.EndDate < fields["VME_Start_Date__c"] || ParentCamp.StartDate > fields["VME_End_Date__c"]) {
            helper.showToast(component, event, helper,  $A.get("{!$Label.c.VME_Error}"), 'Start Date and End Date should be in between the ' + ParentCamp.StartDate + ' and ' + ParentCamp.EndDate + ' of QMSP.', 'error', 'info_alt');
            error = true;
        }
        if (fields["VME_Start_Date__c"] > fields["VME_End_Date__c"]) {
            helper.showToast(component, event, helper,  $A.get("{!$Label.c.VME_Error}"), 'Start Date should be less than the  End Date ', 'error', 'info_alt');
            error = true;
        }
             var day = 60 * 60 * 24 * 1000;
        var todayDate =new Date();
      var  tomorrow =  $A.localizationService.formatDate(new Date(todayDate.getFullYear(),todayDate.getMonth(),todayDate.getDate()).getTime() + day, "YYYY-MM-DD");
        
        if ((fields["VME_Start_Date__c"] < tomorrow || fields["VME_End_Date__c"] < tomorrow ) && $A.get("{!$Label.c.VME_Show_Configure_Btn}")==="false") {
            helper.showToast(component, event, helper,  $A.get("{!$Label.c.VME_Error}"), 'Start and End date will always be the future dates.', 'error', 'info_alt');
            error = true;
        }
         if (fields["VME_Country_ISO_Code__c"]==null && fields["VME_Country_ISO_Code__c"]=='') {
            helper.showToast(component, event, helper,  $A.get("{!$Label.c.VME_Error}"), 'Please fill the Country ISO Code', 'error', 'info_alt');
            error = true;
        }
        var catSubCatMap = component.get("v.categorySubcategoryMap");
        var recordTypeName = component.get("v.selectedRecordTypeName");
        var MarketCodesMap =component.get("v.categoryMarketMap");
        var brandCodesMap =component.get("v.categoryBrandMap");
        fields["VME_External_ID__c"] = 'V-' + ParentCamp.VME_Fiscal_Year__c.substr(-2) + '-' + MarketCodesMap[ParentCamp.Market__c]  + '-' + recordTypeName.slice(0, 1) + catSubCatMap[fields["VME_Category__c"]+'-C'] + '-' + catSubCatMap[fields["VME_Sub_Category__c"]+'-SC'] + '-' + (ParentCamp.QMSP_Quarter__c).slice(1, 2) + '-' +brandCodesMap[ParentCamp.VME_Brand__r.Name]+ '-' + ParentCamp.QMSP_Model__r.ProductCode+'-'+fields["VME_Country_ISO_Code__c"].toUpperCase();
        fields["Name"] = 'V-' + ParentCamp.VME_Fiscal_Year__c.substr(-2) + '-' + MarketCodesMap[ParentCamp.Market__c]  + '-' + recordTypeName.slice(0, 1) +  catSubCatMap[fields["VME_Category__c"]+'-C'] + '-' +  catSubCatMap[fields["VME_Sub_Category__c"]+'-SC'] + '-' + (ParentCamp.QMSP_Quarter__c).slice(1, 2) + '-' +brandCodesMap[ParentCamp.VME_Brand__r.Name]+ '-'+ ParentCamp.QMSP_Model__r.ProductCode;
            
       var vmeCampList = component.get("v.vmeCampList");
       if(!($A.util.isEmpty(vmeCampList))){
        for(var i in vmeCampList){
            if(vmeCampList[i].VME_External_ID__c ==fields["VME_External_ID__c"]){
                 helper.showToast(component, event, helper,  $A.get("{!$Label.c.VME_Error}"),vmeCampList[i].VME_External_ID__c+ ' already existed.', 'error', 'info_alt');
                 error = true;
                 break;
            }
        }
    }

        if (!error) {
           component.find("form").submit(fields);
                helper.showSpinner(component, event, helper);
          //  component.set("v.VMEcampObj", fields);
           // V-20-IN02-TASS-AGE-2-X-X7
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


    statusPopup: function(component, event, helper, title, bodyMessage, CurrentVME, CurrentScheme, showOkay, showBoth, CompName, recordId, CompId) {
        $A.createComponent(
            "c:VME_ConfirmModal", {
                "title": title,
                "bodyMsg": bodyMessage,
                "CurrentVME": CurrentVME,
                "showOkay": showOkay,
                "showBoth": showBoth,
                "CurrentScheme": CurrentScheme,
                "CompName": CompName,
                "recordId": recordId,
                "CompId": CompId
            },
            function(msgBox) {
                if (component.isValid()) {
                    var targetCmp = component.find('ModalDialogPlaceholder');
                    var body = targetCmp.get("v.body");
                    body.push(msgBox);
                    targetCmp.set("v.body", body);
                }

            }
        );
        this.hideSpinner(component, event, helper);
    },


    showSpinner: function(component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },


    hideSpinner: function(component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    },
  
})