({
   doInit :function(component,event,helper){
       console.log($A.get("{!$Label.c.VME_Show_Configure_Btn}"));
     if($A.get("{!$Label.c.VME_Show_Configure_Btn}")=="true"){
      component.set('v.showConfigure', true);
     }else{
      component.set('v.showConfigure', false);
     }
     helper.showSpinner(component,event,helper);
        helper.getUserCurrency(component,event,helper);
        helper.getAllRecordTypesOfScheme(component,event,helper);
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        component.set('v.today', today);
    },
	openModel: function(component, event, helper) {
      // for Display Model,set the "isOpen" attribute to "true"
      component.set("v.isOpen", true);
   },

   closeModel: function(component, event, helper) {
     debugger;
     helper.refreshCategoryPage(component, event, helper);
   },
   endScheme :function(component,event,helper){
      var   currentSchemeId =event.getSource().get("v.value");
      var selectedScheme ;
      var resultList =component.get("v.vmeCampaignResult");
      for (var i in resultList.schemeList) {
        if(resultList.schemeList[i].Id ==currentSchemeId){
            selectedScheme = resultList.schemeList[i];
          }
      }
    helper.statusPopup(component,event,helper,$A.get("{!$Label.c.VME_Confirmation}"),'Are you sure? You want to end this L3 VME Campaign.',null,selectedScheme,false,true,'Variant',resultList.vmeCampaignWrap.Id);           
},
endAndSplitScheme:function(component,event,helper){
    var  currentSchemeId =event.getSource().get("v.value");
    var resultList =component.get("v.vmeCampaignResult");
      for (var i in resultList.schemeList) {
        if(resultList.schemeList[i].Id ==currentSchemeId ){
       
          helper.fireEvent(component, event, helper,resultList.schemeList[i]);
        }
      }
},
 handleConfirm :function(component,event,helper){
  var currentVMEScheme =   event.getParam("CurrentScheme");
  helper.endEditedScheme(component, event, helper,currentVMEScheme);

},
addScheme :function(component,event,helper){
  var containBaseScheme =false;
  var result =component.get("v.vmeCampaignResult");
    for (var i in result.schemeList) {
        if(result.schemeList[i].VME_InActive__c ==false &&  result.schemeList[i].VME_Scheme_Type__c=='Base'){
        containBaseScheme =true;
        }
      }
  var compEvent = component.getEvent("savedRecordDetailsEvt");
                          compEvent.setParams({
                           "recordDetails" : result.vmeCampaignWrap,
                           "CompId" : null,
                           "VMEParameter" : $A.get("{!$Label.c.New_VME_Parameter}"),
                           "containBaseScheme" : containBaseScheme
                       });
                          compEvent.fire();
                          component.set("v.isOpen", false);
  },

  configureScheme :function(component,event,helper){
    helper.configureScheme(component,event,helper,$A.get("{!$Label.c.Modify_VME_Parameter}"));
  },

   reviseScheme :function(component,event,helper){
    helper.reviseScheme(component,event,helper);
  },

  showRetailer  :function(component,event,helper){
      helper.getAllRetailer(component,event,helper);
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