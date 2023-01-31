({
        doInit: function(component, event, helper) {
            helper.showSpinner(component, event, helper);
            helper.getRecordTypesMethod(component, event, helper);
            helper.getCatSubCatMap(component, event, helper);
            helper.getMarketCodesMap(component, event, helper);
            helper.getBrandCodesMap(component, event, helper);
            helper.getUserDetails(component, event, helper);
            var parentCamp = JSON.parse(JSON.stringify(component.get("v.parentCamp")));
            component.set("v.minDate",parentCamp.StartDate); 
            component.set("v.maxDate",parentCamp.EndDate); 
        },


        closeConfirmModel: function(component, event, helper) {
                helper.hideSpinner(component, event, helper);
                component.set("v.isOpenComp", false);
        },


        Next: function(component, event, helper) {
            helper.Next(component, event, helper);
        },


        handleLoad: function(component, event, helper) {
                component.set("v.showtypes", false);
        },


        handleSubmit: function(component, event, helper) {
                event.preventDefault();
                helper.showSpinner(component, event, helper);
                helper.handleSubmit(component, event, helper);   
        },


        handleSuccess: function(component, event, helper) {
            var record = event.getParam("response");
             helper.hideSpinner(component, event, helper);
            helper.statusPopup(component, event, helper, $A.get("{!$Label.c.VME_Confirmation}"), 'Please confirm to create new L3 VME Campaign.',null, null, false, true, $A.get("{!$Label.c.VME_NewVMECampaign}"),record.id,$A.get("{!$Label.c.VME_CategoryAdjustment}"));
        },


        handleError: function(component, event, helper) {
       
            helper.hideSpinner(component, event, helper);
            helper.showToast(component, event, helper, 'Something went wrong!!!', 'Please scroll up to check the error or contact administrator.', 'error', 'info_alt');
        },
        showSpinnerApex: function(component, event, helper) {
       // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
   },
    
 // this function automatic call by aura:doneWaiting event 
    hideSpinnerApex : function(component,event,helper){
     // make Spinner attribute to false for hide loading spinner    
       component.set("v.Spinner", false);
    }

})