({
	getassetListHelper: function(component, event, helper) {
		var assetList = [];
		component.set("v.assestList", assetList);
		var searchAssetAction = component.get("c.getAssetList");
		searchAssetAction.setParams({
			opportunityId: component.get("v.recordId"),
			modelId: component.get("v.selectedModal"),
			productId: component.get("v.selectedProduct")
		});
		searchAssetAction.setCallback(this, function(assetResponse) {
			var assetstate = assetResponse.getState();
			if (assetstate === "SUCCESS") {
				component.set("v.assestList", assetResponse.getReturnValue());
				console.log('asset list is here');
				console.log('rowRecordid---->>> ' + JSON.stringify(component.get("v.recordId")));
				console.log('rowRecordmodal---->>> ' + JSON.stringify(component.get("v.selectedModal")));
				console.log('rowRecordproduct---->>> ' + JSON.stringify(component.get("v.selectedProduct")));
				console.log('rowRecord---->>> ' + JSON.stringify(component.get("v.assestList")));
				if (assetResponse.getReturnValue().length == 0) {
					/* var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": component.get("v.recordId")
                    });
                    navEvt.fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Info!",
                        "type" : "info",
                        "message": $A.get("$Label.c.No_Vehicles_Message") 
                    }); 
                    toastEvent.fire(); */
					component.set("v.noVehicleMessage", $A.get("$Label.c.No_Vehicles_Message"));
				}
			}
		});
		$A.enqueueAction(searchAssetAction);
	},

	getAssetFieldLabelHelper: function(component, event, helper) {
		var searchAssetAction = component.get("c.getFieldLabel");
		searchAssetAction.setParams({
			objectName: "Asset"
		});
		searchAssetAction.setCallback(this, function(assetFieldLabelMap) {
			var assetstate = assetFieldLabelMap.getState();
			if (assetstate === "SUCCESS") {
				component.set("v.assetFieldLabelMap", assetFieldLabelMap.getReturnValue());
			}
		});
		$A.enqueueAction(searchAssetAction);
	},

	getProductFieldLabelHelper: function(component, event, helper) {
		var searchAssetAction = component.get("c.getFieldLabel");
		searchAssetAction.setParams({
			objectName: "Product2"
		});
		searchAssetAction.setCallback(this, function(productFieldLabelMap) {
			var assetstate = productFieldLabelMap.getState();
			if (assetstate === "SUCCESS") {
				component.set("v.productFieldLabelMap", productFieldLabelMap.getReturnValue());
			}
		});
		$A.enqueueAction(searchAssetAction);
	},

	productLineSaveHelper: function(component, event, helper) {
		var button = event.getSource();
		button.set("v.disabled", true);

		var opptyId;
		if (component.get("v.selectedOppty")) {
			opptyId = component.get("v.selectedOppty").opptyId;
		} else {
			opptyId = component.get("v.recordId");
		}

		var action = component.get("c.saveProductLineItem");
		action.setParams({
			oppLineItem: component.get("v.oppProductLineItem"),
			// opportunityId : component.get("v.recordId"),
			opportunityId: opptyId,
			assetId: component.get("v.assetId"),
			modelId: component.get("v.selectedModal"),
			productId: component.get("v.selectedProduct")
		});
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var toastEvent = $A.get("e.force:showToast");
				if (response.getReturnValue() == "Success") {
					toastEvent.setParams({
						title: "Success!",
						type: "success",
						message: $A.get("$Label.c.Success_Message")
					});
				} else {
                    this.showToastMessage(component, event, response.getReturnValue());
					button.set("v.disabled", false);
				}
				toastEvent.fire();
				var navEvt = $A.get("e.force:navigateToSObject");
				navEvt.setParams({ recordId: component.get("v.recordId") });
				navEvt.fire();
			}
		});
		$A.enqueueAction(action);
	},

	getLineItemhelper: function(component, event, helper) {
		var getLineItem = component.get("c.getLineItem");
		getLineItem.setParams({
			opportunityId: component.get("v.recordId"),
			assetId: component.get("v.assetId"),
			modelId: component.get("v.selectedModal"),
			prodId: component.get("v.selectedProduct")
		});
		getLineItem.setCallback(this, function(lineItem) {
			var assetstate = lineItem.getState();
			console.log(assetstate);
			if (assetstate === "SUCCESS") {
				component.set("v.oppProductLineItem", lineItem.getReturnValue());
			} else if(assetstate === 'ERROR') {
                let errors = lineItem.getError();
                this.showToastMessage(component, event, errors[0].message);
            } else {
                this.showToastMessage(component, event, lineItem.getReturnValue());
            }
		});
		$A.enqueueAction(getLineItem);
	},

	getmodelListHelper: function(component, event, helper) {
		var action = component.get("c.searchModelList");
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				component.set("v.modalList", response.getReturnValue());
			}
		});
		$A.enqueueAction(action);
	},

	getproductListHelper: function(component, event, helper) {
		var action = component.get("c.searchProductList");
		action.setParams({
			oppId: component.get("v.recordId"),
			modelId: component.get("v.selectedModal")
		});
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				component.set("v.productList", response.getReturnValue());
				component.set("v.filteredProductList", response.getReturnValue());
				helper.getassetListHelper(component, event, helper);
			}
		});
		$A.enqueueAction(action);
	},

	getproductListFilteredHelper: function(component, event, helper, prodFilterString) {
		var action = component.get("c.getFilteredListOfProducts");
		action.setParams({
			peList: component.get("v.productList"),
			filterString: prodFilterString
		});
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				component.set("v.filteredProductList", response.getReturnValue());
			}
		});
		$A.enqueueAction(action);
	},

	getOpportunityHelper: function(component, event, helper) {
		var searchAssetAction = component.get("c.getOpportunity");
		searchAssetAction.setParams({
			opportunityId: component.get("v.recordId")
		});
		searchAssetAction.setCallback(this, function(assetFieldLabelMap) {
			var assetstate = assetFieldLabelMap.getState();
			if (assetstate === "SUCCESS") {
				component.set("v.currentOpportunity", assetFieldLabelMap.getReturnValue());
				component.set("v.opptyName", assetFieldLabelMap.getReturnValue().Name); //CXPD-1360
				component.set("v.selectedModal", assetFieldLabelMap.getReturnValue().Primary_Model_Interest__c);
				component.set(
					"v.oppSaleType",
					"Opportunity Sale Type: " + assetFieldLabelMap.getReturnValue().Purchase_Type__c
				);

				if (assetFieldLabelMap.getReturnValue().OpportunityLineItems != undefined) {
					assetFieldLabelMap.getReturnValue().OpportunityLineItems.forEach(function(element) {
						component.set("v.selectedProduct", element.Product2Id);
						var lineItem = component.get("v.oppProductLineItem");
						lineItem.Id = element.Id;
						component.set("v.oppProductLineItem", lineItem);
						component.set("v.lineItemProduct", element.Product2Id);
						$A.enqueueAction(component.get("c.refreshAssetOnModalChange"));
					});
				}
				helper.getproductListHelper(component, event, helper);
			}
		});
		$A.enqueueAction(searchAssetAction);
	},

	updateProductDetailsHelper: function(component, event, helper) {
		var searchAssetAction = component.get("c.updateOpportunity");
		searchAssetAction.setParams({
			opportunityId: component.get("v.recordId"),
			assetId: component.get("v.assetId"),
			modelId: component.get("v.selectedModal"),
			productId: component.get("v.selectedProduct")
		});
		searchAssetAction.setCallback(this, function(updatedOpportunity) {
			var assetstate = updatedOpportunity.getState();
			if (assetstate === "SUCCESS" && updatedOpportunity.getReturnValue() == "Success") {
				var navEvt = $A.get("e.force:navigateToSObject");
				navEvt.setParams({
					recordId: component.get("v.recordId")
				});
				navEvt.fire();
			} else {
                this.showToastMessage(component, event, updatedOpportunity.getReturnValue());
			}
		});
		$A.enqueueAction(searchAssetAction);
	},

	// CXPD-1498 An asset which is already linked with an opportunity cannot be linked with another opportunity using Vehicle selection component.
	getAssetLinkedOpportunities: function(component, event, helper) {
		var linkedOpportunities = component.get("c.getAssetLinkedOpportunities");
		linkedOpportunities.setParams({
			assetId: component.get("v.assetId")
		});
		linkedOpportunities.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				
			} else {
                this.showToastMessage(component, event, response.getReturnValue());
			}
		});
		$A.enqueueAction(linkedOpportunities);
	},
    
    navigateToAddVehicleSecondScreen : function(component, event, helper) {
        var oppId;
        var modelId;
        if(component.get('v.selectedOppty')){
            var oppty = component.get('v.selectedOppty');
            oppId = oppty.opptyId;
            modelId = oppty.opptyPrimaryModelInt;
            component.set('v.opptyNameSelected', oppty.opptyName);
        }else{
            oppId = component.get("v.recordId");
            modelId = component.get("v.selectedModal");
            component.set('v.opptyNameSelected', component.get('v.opptyName'));
        }
        var getLineItem = component.get("c.getLineItem");
        getLineItem.setParams({
            opportunityId : oppId, 
            assetId : component.get("v.assetId"), 
            modelId : modelId, 
            prodId : component.get("v.selectedProduct")
        });
        getLineItem.setCallback(this, function(lineItem) {
            var assetstate = lineItem.getState();
            console.log(assetstate);
            if(assetstate === 'SUCCESS'){
                component.set("v.oppProductLineItem" , lineItem.getReturnValue());   
                // Display show vehicle add information
                component.set("v.showVehicleInformation", false);
                component.set("v.showAddVehicleInfo", true);
            } else if(assetstate === 'ERROR') {
                let errors = lineItem.getError();
                this.showToastMessage(component, event, errors[0].message);
            } else {
                this.showToastMessage(component, event, lineItem.getReturnValue());
            }
        });
        $A.enqueueAction(getLineItem);
    },

	//CXPD-1360
	showToastMessage: function(component, event, errorMessage) {
		var toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams({
			title: "Error!",
			type: "error",
			message: errorMessage
		});
		toastEvent.fire();
	},
    //CXPD-2223
	getRegionMarketHelper: function(component, event, helper) {
        var searchregionmarket = component.get("c.getregionmarket");       
        searchregionmarket.setCallback(this, function(RegionMarketVal) {
            var assetstate = RegionMarketVal.getState();
            // alert('market name is'+RegionMarketVal.getReturnValue());
            if (assetstate === "SUCCESS") {
                component.set("v.RegionMarketVal", RegionMarketVal.getReturnValue());
	}
            // alert('assigned market name is'+component.get("v.RegionMarketVal"));

        });
        $A.enqueueAction(searchregionmarket);
    },
});