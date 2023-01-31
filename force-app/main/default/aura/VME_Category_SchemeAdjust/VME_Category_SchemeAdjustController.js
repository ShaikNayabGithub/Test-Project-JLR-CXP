({
   doInit :  function(component, event, helper) {
        helper.getUserCurrency(component,event,helper);
         var tempObj =component.get("v.tempVMESchemeObj");
     
        var VMESchObj =component.get("v.VMESchemeObj");
         var day = 60 * 60 * 24 * 1000;
        var todayDate =new Date();
        var tommorrow =  $A.localizationService.formatDate(new Date(todayDate.getFullYear(),todayDate.getMonth(),todayDate.getDate()).getTime() + day, "YYYY-MM-DD");
     
       var endDate =new Date(tempObj.VME_End_Date__c);
       var endDateOfScheme = new Date(endDate.getFullYear(),endDate.getMonth(),endDate.getDate());
       var startDate =new Date(tempObj.VME_Start_Date__c);
       var startDateOfScheme = new Date(startDate.getFullYear(),startDate.getMonth(),startDate.getDate());
       
       if(endDateOfScheme.getTime()<= new Date(todayDate.getFullYear(),todayDate.getMonth(),todayDate.getDate()).getTime() ){
             VMESchObj.VME_End_Date__c =tommorrow;
       }else{
           VMESchObj.VME_End_Date__c =tempObj.VME_End_Date__c;
       }

        if(startDateOfScheme.getTime()<= new Date(todayDate.getFullYear(),todayDate.getMonth(),todayDate.getDate()).getTime() ){
              VMESchObj.VME_Start_Date__c=tommorrow;
           component.set("v.minDate",tommorrow);
       }else{
           VMESchObj.VME_Start_Date__c =  tempObj.VME_Start_Date__c;
           component.set("v.minDate",tempObj.VME_Start_Date__c);
       }
       VMESchObj.RecordTypeId = tempObj.RecordTypeId;
       VMESchObj.VME_Retailer__c =tempObj.VME_Retailer__c;
       VMESchObj.CurrencyIsoCode =tempObj.CurrencyIsoCode;
       VMESchObj.VME_Scheme_Type__c =tempObj.VME_Scheme_Type__c;
       VMESchObj.VME_Campaign__c = tempObj.VME_Campaign__c;
       VMESchObj.VME_PU_Amount__c =tempObj.VME_PU_Amount__c;
        VMESchObj.VME_Volume__c =tempObj.VME_Volume__c;
        VMESchObj.VME_JLR_Share__c = tempObj.VME_JLR_Share__c;
       VMESchObj.VME_Level_3_Description__c =tempObj.VME_Level_3_Description__c;
       if(tempObj.VME_Retailer__c !=null && tempObj.VME_Retailer__c!=undefined){
       component.set("v.nameOfRetailer",tempObj.VME_Retailer__r.Name);
     }
        component.set("v.VMESchemeObj",VMESchObj);
   },
	openModel: function(component, event, helper) {
      component.set("v.isOpenSchemeComponent", true);
   },
   closeModel: function(component, event, helper) {
      var cmpEvent = component.getEvent("cancelAdjustVariantEvt"); 
          cmpEvent.setParams({
            "openAdjustModel" : true
          });
            cmpEvent.fire();     
      component.set("v.isOpenSchemeComponent", false);
   },

   saveAndClose: function(component, event, helper) {
      var VMESchObj =component.get("v.VMESchemeObj");
      var parentVMECampaign =component.get("v.parentVMECampaign");
      var minError =false;

      if (VMESchObj.VME_Start_Date__c <parentVMECampaign.VME_Start_Date__c) {
          minError =true;
      } 
      var allValid = component.find('requiredField').reduce(function (validSoFar, inputCmp) {
          var valueData = inputCmp.get("v.value");
             if (valueData.length > 16) {
            inputCmp.setCustomValidity("The maximum length of input fields is 16");
        }
        else {
            inputCmp.setCustomValidity(""); // if there was a custom error before, reset it
        }
             inputCmp.reportValidity();
        inputCmp.showHelpMessageIfInvalid();
        return validSoFar && inputCmp.checkValidity();
        }, true);

    if(minError){
      helper.showToast(component, event, helper, $A.get("{!$Label.c.VME_Error}"),'The start date of scheme cannot be less than the VME Campaign start date','error','info_alt');
    }
     if (allValid  && !minError) {
        helper.splitSchemeRecord(component, event, helper);
        }
     if(!allValid) {
          helper.showToast(component, event, helper, $A.get("{!$Label.c.VME_Error}"),'Please fill all the input fields correctly.','error','info_alt');
        }
   },
})