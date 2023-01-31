({
	doInit: function(component, event, helper) {
		helper.getRecordshelper(component, event, helper);
		helper.getSalesManager(component, event, helper);
	},
	navigateToRecord: function(component, event, helper) {
		var navEvt = $A.get("e.force:navigateToSObject");
		navEvt.setParams({ recordId: event.currentTarget.getAttribute("id") });
		navEvt.fire();
	},
	handleApplicationEvent: function(component, event, helper) {
		console.log("entered" + event.getParam("tabName"));
		component.set("v.tableName", event.getParam("tabName"));
		component.set("v.iconName", event.getParam("iconName"));
	},
	showModal: function(component, event, helper) {
		var x = component.get("v.NavigatetoNewOppPage");
		if (!x) {
			component.set("v.showModal", true);
		} else {
			var urlEvent = $A.get("e.force:navigateToURL");
			urlEvent.setParams({ url: "/new-opportunity" }); // Pass your community URL
			urlEvent.fire();
		}
	},
	closeModal: function(component, event, helper) {
		component.set("v.showModal", false);
	},
	showSpinner: function(component, event, helper) {
		component.set("v.showSpinner", true);
	},
	hideSpinner: function(component, event, helper) {
		component.set("v.showSpinner", false);
	}
});