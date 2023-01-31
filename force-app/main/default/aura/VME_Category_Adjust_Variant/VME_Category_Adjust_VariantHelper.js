({
     getUserCurrency :function(component,event,helper){
       var action =component.get("c.getUserDefaultCurrency");
        this.showSpinner(component,event,helper);
        action.setCallback(this, function(response) {
        var state = response.getState();
          if (state === "SUCCESS") {
                    component.set("v.userCurrency",response.getReturnValue());
                    this.hideSpinner(component,event,helper);
                }
                    });
            $A.enqueueAction(action);        
    },


    getAllRecordTypesOfScheme  :function(component,event,helper){
     var action =component.get("c.getRecordTypeOfScheme");
        this.showSpinner(component,event,helper);
        action.setCallback(this, function(response) {
        var state = response.getState();
          if (state === "SUCCESS") {
            component.set("v.parentRecordType",response.getReturnValue());
              // this.hideSpinner(component,event,helper);
                }
                    });
            $A.enqueueAction(action);  
        
    },


	endEditedScheme : function(component, event, helper,schemeObj) {
			  var action =component.get("c.schemeRecordToEnd");
        this.showSpinner(component,event,helper);
        action.setParams({ 
          schemeToEnd : JSON.parse(JSON.stringify(schemeObj )),
          isRevised : false
        });
        action.setCallback(this, function(response) {
          var state = response.getState();
          if (state === "SUCCESS") {
            this.hideSpinner(component,event,helper);
            var result = response.getReturnValue();
            if(result==null){
              this.showToast(component, event, helper, $A.get("{!$Label.c.VME_Error}"),$A.get("{!$Label.c.VME_SomethingWentWrong}"),'error','info_alt');
            }else{
              component.set('v.vmeCampaignResult',result);
              var cmpEvent = component.getEvent("CancelSplitSchemeEvt"); 
                cmpEvent.setParams({
                  "VMECampUpdatedWrapper" : result
                });
              cmpEvent.fire(); 
              this.showToast(component, event, helper,$A.get("{!$Label.c.VME_savedSuccessfully}"),$A.get("{!$Label.c.VME_recordSaved}"),'success','info_alt');
             }
          }else if (state === $A.get("{!$Label.c.VME_ERRORInResult}")) {
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
	},showToast : function(component, event, helper,titleVal,msg,typeVal,icon) {
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
fireEvent :function(component,event,helper,resultedScheme){
     var parentVMECampaign = component.get("v.vmeCampaignResult");
     this.revisePopup(component, event, helper,'Continue to deactivate  Current Base L3 and create new  Base L3.Ensure Completion for new Base L3 else current and new L3 Campaign will be invalid. ', null,parentVMECampaign.vmeCampaignWrap, resultedScheme,null,true);
      this.hideSpinner(component,event,helper);
    
},
  showSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
     
    hideSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    },
      statusPopup : function(component,event,helper,title,bodyMessage,CurrentVME,CurrentScheme,showOkay,showBoth,CompName,recordId) {
     this.showSpinner(component,event,helper);
        $A.createComponent(
            "c:VME_ConfirmModal",
            {
                "title": title,
                "bodyMsg": bodyMessage,
               "CurrentVME" : CurrentVME,
                "showOkay":showOkay,
                 "showBoth":showBoth,
                 "CurrentScheme":CurrentScheme,
                 "CompName":CompName,
                 "recordId" :recordId
            },
            function(msgBox){                
                if (component.isValid()) {
                    var targetCmp = component.find('ModalDialogPlaceholder');
                    var body = targetCmp.get("v.body");
                    body.push(msgBox);
                    targetCmp.set("v.body", body); 
                }
            }
        );
     this.hideSpinner(component,event,helper);
    },
   

    configureScheme :function(component,event,helper,vmeParameter){
     var   currentSchemeId =event.getSource().get("v.value");
      var parentVMECampaign = component.get("v.vmeCampaignResult");
    var revisedScheme;
      for (var i in parentVMECampaign.schemeList) {
        if(parentVMECampaign.schemeList[i].Id==currentSchemeId){
            revisedScheme = parentVMECampaign.schemeList[i];
        }
      }
    var compEvent = component.getEvent("configureBtnEvt");
    compEvent.setParams({
        "CompId" : null,
      "newSchemeId" : currentSchemeId,
      "VMEParameter" : vmeParameter,
      "revisedScheme" : revisedScheme,
        "recordDetails" : parentVMECampaign.vmeCampaignWrap
        });
        compEvent.fire();
        this.closeModel(component, event, helper);
     
  },

   reviseScheme :function(component,event,helper){
   
     var   currentSchemeId =event.getSource().get("v.value");
   var parentVMECampaign = component.get("v.vmeCampaignResult");
   var revisedScheme;
      for (var i in parentVMECampaign.schemeList) {
        if(parentVMECampaign.schemeList[i].Id==currentSchemeId){
            revisedScheme = parentVMECampaign.schemeList[i];
               this.revisePopup(component, event, helper,'Continue to deactivate Current L3 and create new L3.Ensure Completion for new L3 else current and new L3 Campaign will be invalid. ',$A.get("{!$Label.c.Revise_VME_Parameter}"), parentVMECampaign.vmeCampaignWrap, revisedScheme,currentSchemeId,false);
          break;
        }
      }
    
  },

  closeModel: function(component, event, helper) {
      component.set("v.isOpen", false);
   },

     getAllRetailer: function(component, event, helper) {
    
      var  currentSchemeId =event.getSource().get("v.value");
       var action =component.get("c.getAllRetailerofScheme");
        this.showSpinner(component,event,helper);
        action.setParams({ 
          parentSchemeId : currentSchemeId 
        });
        action.setCallback(this, function(response) {
          var state = response.getState();
          if (state === "SUCCESS") {
            this.hideSpinner(component,event,helper);
            var result = response.getReturnValue();
            if(result.length>0){
            this.showRetailer(component,event,helper,result);
          }
            if(result==null){
              this.showToast(component, event, helper, $A.get("{!$Label.c.VME_Error}"),'Please contact Administrator!','error','info_alt');
            }else{
            
             }
          }else if (state === $A.get("{!$Label.c.VME_ERRORInResult}")) {
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

 showRetailer: function(component, event, helper,dealerList) {
        $A.createComponent(
            "c:VME_showRetailers", {
                "dealerList": dealerList ,
                "isOpenComp" : true
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


callDealerMix :function(component,event,helper,revisedScheme,VMEParam,schemeId,ParentCamp){
   var compEvent = component.getEvent("callDealerMixDiscType");
                          compEvent.setParams({
                           "revisedScheme" :  revisedScheme,
                           "VMEParameter" :VMEParam,
                           "newSchemeId" : schemeId,
                           "recordDetails" :ParentCamp
                           })
                          compEvent.fire();
                        this.closeModel(component, event, helper);
},

refreshCategoryPage :  function (component, event, helper) {
  var cmpEvent = component.getEvent("refreshCmpEvt");

          cmpEvent.fire(); 
          component.set("v.isOpen",false);         
},

revisePopup : function(component,event,helper,bodyMessage,vmeParameter,recordDetails,revisedScheme,currentSchemeId,baseSch) {
  this.showSpinner(component,event,helper);
     $A.createComponent(
         "c:VME_ReviseConfirmation",
         {
             "bodyMsg": bodyMessage,
              "CompId" : null,
              "VMEParameter" : vmeParameter,
              "recordDetails" : recordDetails,
              "revisedScheme" : revisedScheme,
              "newSchemeId" : currentSchemeId,
              "isOpen" : true,
              "baseScheme" : baseSch
         },
         function(msgBox){                
             if (component.isValid()) {
                 var targetCmp = component.find('ModalRevisePlaeholder');
                 var body = targetCmp.get("v.body");
                 body.push(msgBox);
                 targetCmp.set("v.body", body); 
             }
         }
     );
  this.hideSpinner(component,event,helper);
 },

})