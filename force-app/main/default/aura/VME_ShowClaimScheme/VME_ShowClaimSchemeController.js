({
	doInit : function(component, event, helper) {
		helper.getUserCurrency(component,event,helper);
		helper.getUserDetails(component,event,helper);
		helper.getClaimScheme(component,event,helper);
	}
})