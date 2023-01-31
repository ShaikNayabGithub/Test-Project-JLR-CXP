({
	doInit: function(component, event, helper) {
		helper.getOpportunityDetails(component, event, helper);
		helper.getPriceBookListHelper(component, event, helper);
		component.find("oppLoader").reloadRecord(true);        
	},
	showModal: function(component, event, helper) {
		console.log("show Modal");
		component.set("v.showModal", true);
	},
	closeModal: function(component, event, helper) {
		component.set("v.showModal", false);
		$A.get("e.force:closeQuickAction").fire();
	},
	removeLineItem: function(component, event, helper) {
		helper.removeOpportunityLineItemhelper(component, event, helper);
	},
	updatePriceBook: function(component, event, helper) {
		console.log(component.get("v.selectedPriceBook"));
		helper.updateOpportunityhelper(component, event, helper);
	}
});