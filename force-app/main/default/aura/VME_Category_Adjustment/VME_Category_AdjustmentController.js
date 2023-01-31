({
   doInit: function(component, event, helper) {
        if($A.get("{!$Label.c.VME_Show_Configure_Btn}")=="true"){
      component.set('v.showConfigure', true);
     }else{
      component.set('v.showConfigure', false);
     }
      helper.showSpinner(component, event, helper);
      helper.getUserCurrency(component, event, helper);
      helper.getQuarterDetails(component, event, helper);
      var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
      component.set('v.today', today);

  },


  endVMECampaign: function(component, event, helper) {
    var currentVMECampaign = event.getSource().get("v.value");
     helper.showSpinner(component, event, helper);
    helper.statusPopup(component, event, helper,  $A.get("{!$Label.c.VME_Confirmation}"), $A.get("{!$Label.c.VME_Confirm_EndAllSchemes}"), currentVMECampaign, null, false, true, $A.get("{!$Label.c.VME_Category_Adjustment}"),$A.get("{!$Label.c.VME_CategoryAdjustment}"));
  },


  handlefilterCmpEvent: function(component, event, helper) {
    component.set("v.isSearch", false);
    component.set("v.campWrapper", null);
    helper.getAllQMSPData(component, event, helper,true);
  },
  
  editVMECampFields: function(component, event, helper) {
   helper.editVMECampFields(component, event, helper) ;
  },


  editVMESchFields: function(component, event, helper) {
    helper.editVMESchFields(component, event, helper);
  },


  cancel: function(component, event, helper) {
    helper.cancelVMECamp(component, event, helper,null);
  },


  handleSplitSchemeEvt: function(component, event, helper) {
    helper.hideSpinner(component, event, helper);
    component.set("v.VMESchemeValue", event.getParam("endedSchemeData"));
    component.set("v.openSchemeSplitModel", event.getParam("openModel"));
    component.set("v.CurrentVMECamp", event.getParam("VMECampParent"));
  },


  handleAdjustVariantEvt: function(component, event, helper) {
    helper.handleAdjustVariantEvt(component, event, helper);
  },


  handleCancelAdjustVariantEvt: function(component, event, helper) {
     helper.hideSpinner(component, event, helper);
    component.set("v.openSchemeAdjustModel", true);
  },


  handleConfirm: function(component, event, helper) {
  
    helper.hideSpinner(component, event, helper);
    var currentVMECampaign = event.getParam("CurrentVME");
    helper.saveVMECampaign(component, event, helper, currentVMECampaign,$A.get("{!$Label.c.VME_End}"));
  },
 

   handleCancelSplitSchemeEvt: function(component, event, helper){
   helper.handleCancelSplitSchemeEvt(component, event, helper);
  },

  
  addVMECampaign :function(component,event,helper){
    
     component.set("v.openNewCampModel",false);
    var resultList = component.get("v.campWrapper");
    var vmeCampList =[];
    for(var i in resultList.vmeCampaignWrapList){
          vmeCampList.push(resultList.vmeCampaignWrapList[i].vmeCampaignWrap);
    }
    component.set("v.parentCampaign",resultList.campWrap);
    component.set("v.VMECampaignList",vmeCampList);
    component.set("v.compIdentity",$A.get("{!$Label.c.VME_CategoryAdjustment}"));
    component.set("v.openNewCampModel",true);

  },


  handlerefreshCmpEvt : function(component,event,helper){
     helper.hideSpinner(component, event, helper); 
    helper.getAllQMSPData(component,event,helper,false);
    component.set("v.openSchemeAdjustModel",false);
  },


  handleVMEsavedDetailsConfirm : function(component,event,helper){
    helper.hideSpinner(component, event, helper);
    component.set("v.openNewschemeModel",false);
    component.set("v.parameterName",event.getParam("VMEParameter"));
    component.set("v.compIdentity",event.getParam("CompId"));
    component.set("v.CurrentVMECamp",event.getParam("recordDetails"));
    component.set("v.VMESchemeValue",event.getParam("revisedScheme"));
    component.set("v.containBaseScheme",event.getParam("containBaseScheme"));
    component.set("v.openNewschemeModel",true);
  },


  handlesavedSchemeDetailsConfirm :function(component,event,helper){
   
    helper.hideSpinner(component, event, helper);
    component.set("v.openProductMixModel",false);
    component.set("v.parameterName",event.getParam("VMEParameter"));
    component.set("v.createdSchemeId",event.getParam("newSchemeId"));
    component.set("v.VMESchemeValue",event.getParam("revisedScheme"));
    component.set("v.compIdentity",event.getParam("CompId"));
    component.set("v.CurrentVMECamp",event.getParam("recordDetails"));
    component.set("v.openProductMixModel",true);
  },


  handleVinMixCmpEvt :function(component,event,helper){
    
    helper.hideSpinner(component, event, helper);
    component.set("v.openVinMixModel",false);
    component.set("v.createdSchemeId",event.getParam("newSchemeId"));
    component.set("v.parameterName",event.getParam("VMEParameter"));
     component.set("v.VMESchemeValue",event.getParam("revisedScheme"));
    component.set("v.CurrentVMECamp",event.getParam("recordDetails"));
    component.set("v.compIdentity",event.getParam("CompId"));
     component.set("v.retailerId",event.getParam("RetailerId"));
    component.set("v.openVinMixModel",true);
  },


   handleDealerMixCmpEvt :function(component,event,helper){
      helper.hideSpinner(component, event, helper);
       component.set("v.openDealerMixModel",false);
      component.set("v.createdSchemeId",event.getParam("newSchemeId"));
      component.set("v.parameterName",event.getParam("VMEParameter"));
      component.set("v.VMESchemeValue",event.getParam("revisedScheme"));
      component.set("v.CurrentVMECamp",event.getParam("recordDetails"));
      component.set("v.SchemeType",event.getParam("schemeApplicable"));
       component.set("v.compIdentity",event.getParam("CompId"));
      component.set("v.availableFilters",event.getParam("filters"));
      component.set("v.openDealerMixModel",true);
  },
  



  
})