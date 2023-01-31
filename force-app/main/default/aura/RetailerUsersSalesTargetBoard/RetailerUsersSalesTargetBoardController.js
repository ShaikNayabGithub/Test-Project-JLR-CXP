({
	doInit: function(component, event, helper) {
		var action = component.get("c.getTargetRecords");
		action.setParams({ recordTypeName: component.get("v.targetType") });
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				component.set("v.targetRecords", response.getReturnValue());
				helper.calculateTotals(component);
			}
		});
		$A.enqueueAction(action);
	},
	saveRecords: function(component, event, helper) {
		var button = event.getSource();
		button.set("v.disabled", true);
		var action = component.get("c.saveTargetRecords");
		action.setParams({ salesTargetWrapper: JSON.stringify(component.get("v.targetRecords")) });
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var toastEvent = $A.get("e.force:showToast");
				if (response.getReturnValue() == "Success") {
					toastEvent.setParams({
						title: "Success!",
						type: "success",
						message: $A.get("$Label.c.LC_COOP_The_Record_Has_Been_Updated_Successfully")
					});
				} else {
					toastEvent.setParams({
						title: "Error!",
						type: "error",
						message: response.getReturnValue()
					});
				}
				toastEvent.fire();
				button.set("v.disabled", false);
			}
		});
		$A.enqueueAction(action);
	},
	calcTotals: function(component, event, helper) {
		helper.calculateTotals(component);
	}
});