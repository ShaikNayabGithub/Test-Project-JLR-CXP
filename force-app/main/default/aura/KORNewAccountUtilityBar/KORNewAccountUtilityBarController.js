({
	handleSelect: function(component, event, helper) {
		var selected = event.getParam('name');
		var recordTypeId = selected === 'Individual' ? '0121o000000TjjTAAS' : '0121o000000TjjOAAS';

		var navEvt = $A.get("e.force:createRecord");
		navEvt.setParams({
			"entityApiName" : "Account",
			"recordTypeId" : recordTypeId
		});
		navEvt.fire();
		component.set('v.selectedItem', '');
		var utilityAPI = component.find("createAccount");
        utilityAPI.minimizeUtility();

	}


})