({
	closeMe : function(component, event, helper) {
		
		component.set("v.isOpenComp",false);
	},

	endRetailerScheme : function(component, event, helper) {
    var currentScheme = event.getSource().get("v.value");
    helper.statusPopup(component,event,helper,$A.get("{!$Label.c.VME_Confirmation}"),'Are you sure? You want to remove dealer.',currentScheme.VME_Campaign__c,currentScheme,false,true,$A.get("{!$Label.c.VME_showRetailers}"));           

	},

  handleAdjustVariantEvt : function(component, event, helper) {
    component.set("v.isOpenComp",false);
  },
})