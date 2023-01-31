({
	  showToast : function(component, event, helper,titleVal,msg,typeVal,icon) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : titleVal,
            message:msg,
            messageTemplate: msg,
            duration:' 5000',
            key: icon,
            type: typeVal,
            mode: 'dismissible'
        });
        toastEvent.fire();
    },
     statusPopup : function(component,event,helper,title,bodyMessage,CurrentVME,CurrentScheme,showOkay,showBoth,CompName,recordId,CompId,schemeId) {
        $A.createComponent(
            "c:VME_ConfirmModal",
            {
                "title": title,
                "bodyMsg": bodyMessage,
               "CurrentVME" : CurrentVME,
                "showOkay":showOkay,
                 "showBoth":showBoth,
                 "CurrentScheme" : CurrentScheme,
                   "CompName":CompName,
                   "recordId" :recordId,
                   "CompId" : CompId,
                   "schemeId" : schemeId
            },
            function(msgBox){                
                if (component.isValid()) {
                    var targetCmp = component.find('ModalDialogPlaceholder');
                    var body = targetCmp.get("v.body");
                    body.push(msgBox);
                    targetCmp.set("v.body", body); 
                }
            }
        );                 //component.set("v.isOpenComp", false);
    },
   
    refreshAdjustmentPage : function (component, event, helper) {
          var ParentCamp = JSON.parse(JSON.stringify(component.get("v.parentVMECampaign")));
         var action =component.get("c.getUpdatedWrapperofCurrentVME");
           action.setParams({ recordId : ParentCamp.Id});
          action.setCallback(this, function(response) {
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

    refreshCategoryPage :  function (component, event, helper) {
        var cmpEvent = component.getEvent("refreshCmpEvt");
       cmpEvent.fire();        
    },

    callNextScreenOnSave :function (component, event, helper,schemeId,filtersDetails,schemeType,segment,subDivision) {
        var compEvent;
        var ParentCamp = JSON.parse(JSON.stringify(component.get("v.parentVMECampaign")));
if((ParentCamp.RecordType.Name=='Tactical' || ParentCamp.RecordType.Name=='Regular') && component.get("v.schemeApplicable")=='ModelWise'  && (component.get("v.parameterName")==$A.get("{!$Label.c.New_VME_Parameter}") || component.get('v.TradeIn')==true ||  component.get('v.OFBCheck')==true)){
   var action = component.get("c.createBundling");
   action.setParams({
      "scheme": schemeId,
    "model" : ParentCamp.VME_Model__c
  });
   action.setCallback(this, function(response) {
      var result =response.getReturnValue();
        if (response.getState() == $A.get("{!$Label.c.Success_Msg}")) {
            if(schemeType!=null || segment!=null || subDivision!=null){
                if( component.get("v.compIdentityValue")==$A.get("{!$Label.c.VME_CategoryAdjustment}")){ 
                    helper.refreshCategoryPage(component, event, helper);
                      }
                     if( component.get("v.compIdentityValue")!=$A.get("{!$Label.c.VME_CategoryAdjustment}")){
                              helper.refreshAdjustmentPage(component, event, helper);
                   }
            }else{
                    compEvent = component.getEvent("sendSchemeIdToDealerEvt"); 
                            compEvent.setParams({
                                "revisedScheme" :  component.get("v.revisedScheme"),
                                "VMEParameter" :component.get("v.parameterName"),
                                "newSchemeId" : schemeId,
                                "recordDetails" :ParentCamp,
                                "CompId" :component.get("v.compIdentityValue"),
                                "schemeApplicable" : component.get("v.schemeApplicable"),
                                "filters":filtersDetails
                                })
                               compEvent.fire();
                               component.set("v.Spinner", false);
                               component.set("v.isOpenComp", false);
            }
        }else{
              helper.showToast(component, event, helper, 'Something went wrong!!!', 'Please  contact administrator.', 'error', 'info_alt');    
      }
  });
  $A.enqueueAction(action);

 }
 if((ParentCamp.RecordType.Name=='Tactical' || ParentCamp.RecordType.Name=='Regular') && component.get("v.schemeApplicable")=='ModelWise'  && component.get("v.parameterName")!=$A.get("{!$Label.c.New_VME_Parameter}")){
    if(schemeType!=null || segment!=null || subDivision!=null){
        if( component.get("v.compIdentityValue")==$A.get("{!$Label.c.VME_CategoryAdjustment}")){ 
            helper.refreshCategoryPage(component, event, helper);
              }
             if( component.get("v.compIdentityValue")!=$A.get("{!$Label.c.VME_CategoryAdjustment}")){
                      helper.refreshAdjustmentPage(component, event, helper);
           }
    }else{
            compEvent = component.getEvent("sendSchemeIdToDealerEvt"); 
                    compEvent.setParams({
                        "revisedScheme" :  component.get("v.revisedScheme"),
                        "VMEParameter" :component.get("v.parameterName"),
                        "newSchemeId" : schemeId,
                        "recordDetails" :ParentCamp,
                        "CompId" :component.get("v.compIdentityValue"),
                        "schemeApplicable" : component.get("v.schemeApplicable"),
                        "filters":filtersDetails
                        })
                       compEvent.fire();
                       component.set("v.Spinner", false);
                       component.set("v.isOpenComp", false);
    }
 }

    if((ParentCamp.RecordType.Name=='Tactical' || ParentCamp.RecordType.Name=='Regular') && component.get("v.schemeApplicable")=='DerivativeWise' ){
         compEvent = component.getEvent("VME_SavedSchemeRecordDetailsEvent");
         compEvent.setParams({
          "revisedScheme" :  component.get("v.revisedScheme"),
          "VMEParameter" :component.get("v.parameterName"),
          "newSchemeId" : schemeId,
          "recordDetails" :ParentCamp,
          "CompId" :component.get("v.compIdentityValue"),
          "schemeApplicable" : component.get("v.schemeApplicable"),
          "filters":filtersDetails
          })
         compEvent.fire();
         component.set("v.Spinner", false);
         component.set("v.isOpenComp", false);
                  }
                  if(ParentCamp.RecordType.Name!='Tactical' && ParentCamp.RecordType.Name!='Regular'){
                      compEvent = component.getEvent("sendSchemeIdToDealerEvt");
                      compEvent.setParams({
                          "revisedScheme" :  component.get("v.revisedScheme"),
                          "VMEParameter" :component.get("v.parameterName"),
                          "newSchemeId" : schemeId,
                          "recordDetails" :ParentCamp,
                          "CompId" :component.get("v.compIdentityValue"),
                          "schemeApplicable" : component.get("v.schemeApplicable"),
                          "filters":filtersDetails
                          })
                         compEvent.fire();
                         component.set("v.Spinner", false);
                         component.set("v.isOpenComp", false);
                  }
          
    },


    endScheme :function(component, event, helper){
   
       var action = component.get("c.schemeRecordToEnd");
        action.setParams({
                  schemeToEnd: component.get("v.revisedScheme"),
                  isRevised : true
                });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                 helper.saveNewScheme(component, event, helper);
            } else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                           console.log("Error message: " + errors[0].message);
                        }
                           helper.showToast(component, event, helper, 'Something went wrong!!!', 'Please  contact administrator.', 'error', 'info_alt');
      
                    } else {
                        console.log("Unknown error");
                       helper.showToast(component, event, helper, 'Something went wrong!!!', 'Please  contact administrator.', 'error', 'info_alt');
      
                    }
                }
        });
        $A.enqueueAction(action);
    },

    saveNewScheme : function(component, event, helper){
        var fields = event.getParam("fields");
        component.find("form").submit(fields);
    },

    convertAmountValue :function(component, event, helper,convertioncode){
          var action =component.get("c.getAmountConvertedValue");
           action.setParams({ 
           convertioncode : convertioncode
           });
          action.setCallback(this, function(response) {
                var result = response.getReturnValue();
         var state = response.getState();
                    if (state === "SUCCESS") {
                    component.set("v.conversionRate",result);
                    }
                });
        $A.enqueueAction(action);      
    },

     getRecordTypeIdParSch :function(component, event, helper){
       var action =component.get("c.getRecordTypeOfScheme");
          action.setCallback(this, function(response) {
                var result = response.getReturnValue();
         var state = response.getState();
                    if (state === "SUCCESS") {
                    component.set("v.recordTypeId",result);
                    }
                });
        $A.enqueueAction(action);      
    },

})