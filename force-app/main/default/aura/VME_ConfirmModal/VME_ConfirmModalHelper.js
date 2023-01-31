({
	closeMe : function(component, event, helper) {
 
       if(component.get("v.CompName")==$A.get("{!$Label.c.VME_showRetailers}") || component.get("v.CompId")!=$A.get("{!$Label.c.VME_CategoryAdjustment}")){
       	 var action =component.get("c.getUpdatedWrapperofCurrentVME");
           action.setParams({ recordId : component.get("v.recordId")});
          action.setCallback(this, function(response) {
         var state = response.getState();
                    if (state ===  $A.get("{!$Label.c.VME_SUCCESS}")) {
                    	console.log( response.getReturnValue());
                        var  compEvent = component.getEvent("adjustVariantEvt");
                          compEvent.setParams({
                           "updateVMECampWrapperList" :  response.getReturnValue(),
                           "openAdjustModel" :true
                       });
                           compEvent.fire();
                            component.destroy(); 
                    }
                });
        $A.enqueueAction(action);      
     }
     if(component.get("v.CompName")==$A.get("{!$Label.c.VME_NewVMECampaign}") || component.get("v.CompId")==$A.get("{!$Label.c.VME_CategoryAdjustment}") || component.get("v.CompName")==$A.get("{!$Label.c.VME_Category_Adjustment}")){ 
        var cmpEvent = component.getEvent("refreshCmpEvt");
        cmpEvent.fire();          
      component.destroy();
       }
	},


	sendSavedRecordDetails :function(component, event, helper){
         var action =component.get("c.getCurrentVMECampaign");
           action.setParams({ recordId : component.get("v.recordId")});
          action.setCallback(this, function(response) {
         var state = response.getState();
                    if (state ===  $A.get("{!$Label.c.VME_SUCCESS}")) {
                        component.set("v.CurrentVME",response.getReturnValue());
                         var compEvent = component.getEvent("savedRecordDetailsEvt");
                          compEvent.setParams({
                           "recordDetails" : component.get("v.CurrentVME"),
                           "CompId" : component.get("v.CompId"),
                           "VMEParameter" :$A.get("{!$Label.c.New_VME_Parameter}")
                       });
                           compEvent.fire();
                           component.destroy();
                    }
                });
        $A.enqueueAction(action);        
},

confirmModal :function(component, event, helper){
     if(component.get("v.CompName")==$A.get("{!$Label.c.VME_Category_Adjustment}")){
      this.fireConfirmEvt(component, event, helper);
        }
       if(component.get("v.CompName")=='Variant'){
       this.fireConfirmEvt1(component, event, helper);
       }
         if(component.get("v.CompName")==$A.get("{!$Label.c.VME_NewVMECampaign}")){
          this.sendSavedRecordDetails(component, event, helper);
    } 
     if(component.get("v.CompName")==$A.get("{!$Label.c.VME_showRetailers}")){
          this.endRetailerScheme(component, event, helper);
    } 
},


fireConfirmEvt :function(component, event, helper){
  var compEvent = component.getEvent("statusEvent");
    compEvent.setParams({ 
            "CurrentVME" : component.get("v.CurrentVME"),
            "CurrentScheme" : component.get("v.CurrentScheme")
        });
        compEvent.fire();
        component.destroy();
  },


  fireConfirmEvt1 :function(component, event, helper){
   var compEvent = component.getEvent("statusEvent1");
    compEvent.setParams({ 
            "CurrentVME" : component.get("v.CurrentVME"),
            "CurrentScheme" : component.get("v.CurrentScheme")
        });
        compEvent.fire();
        component.destroy();
  },


endRetailerScheme : function(component, event, helper){
  var currentScheme =component.get("v.CurrentScheme");
  var action =component.get("c.getUpdatedChildSchemeList");
        action.setParams({ 
          parentSchemeId : currentScheme.VME_Parent_Scheme__c,
          scheme : currentScheme
        });
        action.setCallback(this, function(response) {
          var state = response.getState();
          if (state === "SUCCESS") {
            var result = response.getReturnValue();
            if(result.length>0){
           this.showToast(component, event, helper,$A.get("{!$Label.c.VME_recordSaved}"), 'Record is removed successfully.','success', 'info_alt');
           this.closeMe(component, event, helper);
        // component.set("v.dealerList",result);
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
})