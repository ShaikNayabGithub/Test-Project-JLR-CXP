({
	getOpportunityDetails: function(component, event, helper) {
		var getCurrentOpportunity = component.get("c.getOpportunity");
		getCurrentOpportunity.setParams({
			opportunityId: component.get("v.recordId")
		});
		getCurrentOpportunity.setCallback(this, function(opportunityRecord) {
			var assetstate = opportunityRecord.getState();
			if (assetstate === "SUCCESS") {
				component.set("v.currentOpportunity", opportunityRecord.getReturnValue());
				console.log(opportunityRecord.getReturnValue().Pricebook2Id);
				if (
					component.get("v.currentOpportunity").StageName == "Vehicle Selection" ||
					component.get("v.currentOpportunity").StageName == "Appraisal" ||
					component.get("v.currentOpportunity").StageName == "Negotiation & Approval"
				) {
					component.set("v.isButtonVisible", true);
				} else {
					component.set("v.isButtonVisible", false);
				}
                
				if (
					component.get("v.currentOpportunity").OpportunityLineItems != undefined &&
					component.get("v.currentOpportunity").OpportunityLineItems.length > 0
				) {
					component.get("v.currentOpportunity").OpportunityLineItems.forEach(function(element) {
						console.log(element);
						if (element.Asset__c != undefined) {
							component.set("v.hasLineItem", true);
						}
					});
				} else {
					component.set("v.hasLineItem", false);
				}
                
				if (component.get("v.currentOpportunity").Pricebook2Id != undefined) {
					component.set("v.isPriceBookSelected", false);
				} else {
					component.set("v.isPriceBookSelected", true);
				}
			}
		});
		$A.enqueueAction(getCurrentOpportunity);
	},
    
	removeOpportunityLineItemhelper: function(component, event, helper) {
		var button = event.getSource();
		button.set("v.disabled", true);
		var getCurrentOpportunity = component.get("c.removeOpportunityProduct");
		getCurrentOpportunity.setParams({
			opportunityId: component.get("v.recordId")
		});
		getCurrentOpportunity.setCallback(this, function(opportunityRecord) {
			var assetstate = opportunityRecord.getState();
			if (assetstate === "SUCCESS") {
				var toastEvent = $A.get("e.force:showToast");
				if (opportunityRecord.getReturnValue() == "Success") {
					toastEvent.setParams({
						title: "Success!",
						type: "success",
						message: "The record has been deleted successfully."
					});
					this.getOpportunityDetails(component, event, helper);
				} else {
					toastEvent.setParams({
						title: "Error!",
						type: "error",
						message: opportunityRecord.getReturnValue()
					});

					$A.get("e.force:closeQuickAction").fire();
				}

				toastEvent.fire();
			}
		});
		$A.enqueueAction(getCurrentOpportunity);
	},
    
	getPriceBookListHelper: function(component, event, helper) {
		var action = component.get("c.getPriceBookList");
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				console.log(response.getReturnValue());
				component.set("v.priceBookList", response.getReturnValue());
				if (response.getReturnValue().length > 0)
					component.set("v.selectedPriceBook", response.getReturnValue()[0].value);
				else if (response.getReturnValue() != undefined && response.getReturnValue().length == 0)
					component.set("v.selectedPriceBook", response.getReturnValue().value);
			}
		});
		$A.enqueueAction(action);
	},
    
	updateOpportunityhelper: function(component, event, helper) {
		var button = event.getSource();
		button.set("v.disabled", true);
		var getCurrentOpportunity = component.get("c.updateOpportunity");
		getCurrentOpportunity.setParams({
			opportunityId: component.get("v.recordId"),
			priceBookName: component.get("v.selectedPriceBook")
		});
		getCurrentOpportunity.setCallback(this, function(opportunityRecord) {
			var assetstate = opportunityRecord.getState();
			if (assetstate === "SUCCESS") {
				this.getOpportunityDetails(component, event, helper);
			}
		});
		$A.enqueueAction(getCurrentOpportunity);
	}
});