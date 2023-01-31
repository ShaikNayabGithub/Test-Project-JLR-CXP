({
	doInit: function(component, event, helper) {
		//  helper.getassetListHelper(component, event, helper);
		helper.getAssetFieldLabelHelper(component, event, helper);
		helper.getProductFieldLabelHelper(component, event, helper);
		helper.getOpportunityHelper(component, event, helper);
		//helper.getproductListHelper(component, event, helper);
		helper.getmodelListHelper(component, event, helper);
		//CXPD-2223
		helper.getRegionMarketHelper(component, event, helper);
		console.log("completed init");
	},

	handleChange: function(component, event) {
		var selectedOptionValue = event.getParam("value");
		component.set("v.selectedModels", selectedOptionValue.toString());
	},

	selectingAsset: function(component, event, helper) {
		var availableCheckboxes = component.find("rowSelectionCheckboxId");
		var resetCheckboxValue = false;
		var currentCheckboxValue = event.getSource().get("v.value");
		var createButton = component.find("createButton");
		var vehicleInfo = component.find("vehicleInfo"); // CXPD-1360
		var updateButton = component.find("updateButton");
		var saveDerivative = component.find("saveDerivative");
		if (currentCheckboxValue == true) {
			if (Array.isArray(availableCheckboxes)) {
				availableCheckboxes.forEach(function(checkbox) {
					checkbox.set("v.value", resetCheckboxValue);
				});
			} else {
				availableCheckboxes.set("v.value", resetCheckboxValue);
			}
			event.getSource().set("v.value", true);
			$A.util.removeClass(createButton, "slds-hide");
			$A.util.removeClass(vehicleInfo, "slds-hide"); // CXPD-1360
			$A.util.removeClass(updateButton, "slds-hide");
			$A.util.addClass(saveDerivative, "slds-hide");
			var assetdetails = event
				.getSource()
				.get("v.text")
				.split("-;"); //CXPD-1360 - Updated splitter string
			component.set("v.assetId", assetdetails[0]);
			component.set("v.assetName", assetdetails[1]);
			component.set("v.selectedProduct", assetdetails[2]);
			component.set("v.assetModelAlternative", assetdetails[3]); // CXPD-1360
			component.set("v.assetPurchaseType", assetdetails[4]); // CXPD-1584
		} else {
			$A.util.addClass(createButton, "slds-hide");
			$A.util.addClass(vehicleInfo, "slds-hide"); // CXPD-1360
			console.log(component.get("v.selectedProduct"));
			if (component.get("v.selectedProduct") == "") {
				$A.util.addClass(updateButton, "slds-hide");
			} else {
				$A.util.removeClass(saveDerivative, "slds-hide");
			}
			component.set("v.assetId", null);
			component.set("v.assetName", null);
			component.set("v.assetModelAlternative", null); // CXPD-1360
			component.set("v.assetPurchaseType", null); // CXPD-1584
		}
	},

	createOppProductFromProduct: function(component, event, helper) {
		var createProd = component.get("c.createOppProduct");
		createProd.setParams({
			opportunityId: component.get("v.recordId"),
			productId: component.get("v.selectedProduct"),
			modelId: component.get("v.selectedModal"),
			assetId: component.get("v.assetId")
		});
		createProd.setCallback(this, function(lineItem) {
			var prodstate = lineItem.getState();
			if (prodstate === "SUCCESS" && lineItem.getReturnValue() == "Success") {
				var navEvt = $A.get("e.force:navigateToSObject");
				navEvt.setParams({
					recordId: component.get("v.recordId")
				});
				navEvt.fire();
			} else {
                helper.showToastMessage(component, event, lineItem.getReturnValue());
				component.set("v.showModal", false);
			}
		});
		$A.enqueueAction(createProd);
	},

	productLineSave: function(component, event, helper) {
		helper.productLineSaveHelper(component, event, helper);
	},

	previousStage: function(component, event, helper) {
		component.set("v.stage", true);
	},

	refreshAssetOnModalChange: function(component, event, helper) {
		var productValue = component.get("v.selectedProduct");
		var updateButton = component.find("updateButton");
		var saveDerivative = component.find("saveDerivative");
		if (productValue != "") {
			$A.util.removeClass(updateButton, "slds-hide");
			$A.util.removeClass(saveDerivative, "slds-hide");
		} else {
			$A.util.addClass(updateButton, "slds-hide");
			$A.util.addClass(saveDerivative, "slds-hide");
		}
		helper.getassetListHelper(component, event, helper);
	},

	refreshAssetAndProductOnModalChange: function(component, event, helper) {
		component.set("v.selectedProduct", null);
		component.set("v.vinNumber", null); //CXPD-1360
		helper.getassetListHelper(component, event, helper);
		helper.getproductListHelper(component, event, helper);
	},

	updateProductDetails: function(component, event, helper) {
		component.set("v.showModal", false);
		helper.updateProductDetailsHelper(component, event, helper);
	},

	navgiateToOpportunity: function(component, event, helper) {
		var navEvt = $A.get("e.force:navigateToSObject");
		navEvt.setParams({ recordId: component.get("v.recordId") });
		navEvt.fire();
	},

	showModal: function(component, event, helper) {
		component.set("v.showModal", true);
	},

	hideModal: function(component, event, helper) {
		component.set("v.showModal", false);
	},

	updateProductFilter: function(component, event, helper) {
		var productFilter = component.get("v.productFilter");
		helper.getproductListFilteredHelper(component, event, helper, productFilter);
	},

	//CXPD-1360 - Added below functions
	searchAssetByVIN: function(component, event, helper) {
		if (!component.get("v.vinNumber")) {
			return;
		}
		var searchAssetAction = component.get("c.getAssetListUsingVIN");
		searchAssetAction.setParams({
			vinNumber: component.get("v.vinNumber")
		});
		searchAssetAction.setCallback(this, function(assetResponse) {
			var assetstate = assetResponse.getState();
			if (assetstate === "SUCCESS") {
				component.set("v.assestList", assetResponse.getReturnValue());
				if (assetResponse.getReturnValue().length == 0) {
					component.set("v.noVehicleMessage", $A.get("$Label.c.No_Vehicles_Message"));
				}
			}
		});
		$A.enqueueAction(searchAssetAction);
	},

	onVehicleInformation: function(component, event, helper) {
		var assetId = component.get("v.assetId");
		if (!assetId) {
			return;
		}
		$A.util.addClass(component.find("firstScreen"), "slds-hide");
		var assetName = component.get("v.assetName");
		var assetModelAlternative = component.get("v.assetModelAlternative");
		var vehicleInfoAction = component.get("c.getRelatedAccAndOppty");
		vehicleInfoAction.setParams({
			assetId: component.get("v.assetId")
		});
		vehicleInfoAction.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var accOpptyWrapper = response.getReturnValue();
				var relatedAccount = accOpptyWrapper.relatedAccount;
				if (relatedAccount.length > 0) {
					relatedAccount.forEach(function(objAcc) {
						objAcc.AssetVIN = assetName;
						objAcc.AssetModel = assetModelAlternative;
						objAcc.CreatedName = objAcc.CreatedBy.Name;
					});
					component.set("v.relatedAccount", relatedAccount);

					// Prepare Potential Duplicate Accounts
					var potentialDuplicateAccount = accOpptyWrapper.potentialDuplicateAccount;
					potentialDuplicateAccount.forEach(function(objDupAcc) {
						objDupAcc.CreatedName = objDupAcc.CreatedBy.Name;
					});
					component.set("v.potentialDuplicateAccount", potentialDuplicateAccount);

					// Prepare Opportunity List
					var relatedOpptys = accOpptyWrapper.relatedOpptyList;
					/*relatedOpptys.forEach(function(objOppty){
                        objOppty.AssetVIN = assetName;
                        objOppty.CreatedName = objOppty.CreatedBy.Name;
                    });*/
					component.set("v.relatedOpportunities", relatedOpptys);
					// Prepare columns for lightning datatable
					component.set("v.potentialDuplicateAccountColumns", [
						{ label: "Account Name", fieldName: "Name", type: "text" },
						{ label: "Email", fieldName: "PersonEmail", type: "email" },
						{ label: "Mobile", fieldName: "PersonMobilePhone", type: "phone" },
						{ label: "Phone", fieldName: "Phone", type: "phone" },
						{ label: "Account Type", fieldName: "Record_Type_Name__c", type: "text" },
						{ label: "Created By", fieldName: "CreatedName", type: "text" },
						{ label: "Created Date", fieldName: "CreatedDate", type: "date" }
					]);
					component.set("v.accountColumns", [
						{ label: "Account Name", fieldName: "Name", type: "text" },
						{ label: "Email", fieldName: "PersonEmail", type: "email" },
						{ label: "Mobile", fieldName: "PersonMobilePhone", type: "phone" },
						{ label: "Phone", fieldName: "Phone", type: "phone" },
						{ label: "Account Type", fieldName: "Record_Type_Name__c", type: "text" },
						{ label: "Asset", fieldName: "AssetVIN", type: "text" },
						{ label: "Asset Model", fieldName: "AssetModel", type: "text" }, //Column name 'Asset Model Alternative' better?
						{ label: "Created By", fieldName: "CreatedName", type: "text" },
						{ label: "Created Date", fieldName: "CreatedDate", type: "date" }
					]);
					component.set("v.opportunityColumns", [
						{ label: "Opportunity Name", fieldName: "opptyName", type: "text" },
						{ label: "Account Name", fieldName: "opptyAccName", type: "text" },
						{ label: "Asset", fieldName: "opptyLineItemAsset", type: "text" },
						{ label: "Created By", fieldName: "opptyCreatedBy", type: "text" },
						{ label: "Created Date", fieldName: "opptyCreatedDate", type: "date" }
					]);
				} else {
					//set error message if required
				}
				component.set("v.showVehicleInformation", true);
			}
		});
		$A.enqueueAction(vehicleInfoAction);
	},

	accountMerge: function(component, event, helper) {
		if (!component.get("v.selectedAccount")) {
			helper.showToastMessage(component, event, "Please select an Account for Account Merge");
			return;
		}
		var selectedAccount = component.get("v.selectedAccount");
		var accName = selectedAccount.Name;
		var urlEvent = $A.get("e.force:navigateToURL");
		urlEvent.setParams({
			url: "/merge/accmergewizard.jsp?srch=" + accName
		});
		urlEvent.fire();
	},

	onPreviousClick: function(component, event, helper) {
		component.set("v.showVehicleInformation", false);
		$A.util.removeClass(component.find("firstScreen"), "slds-hide");
		component.set("v.selectedAccount", null);
		component.set("v.selectedOppty", null);
	},

	onAccountSelection: function(component, event, helper) {
		var selectedRows = event.getParam("selectedRows");
		component.set("v.selectedAccount", selectedRows[0]);
	},

	onOpptySelection: function(component, event, helper) {
		var selectedRows = event.getParam("selectedRows");
		if (selectedRows.length > 1) {
			component.set("v.isButtonActive", true);
			helper.showToastMessage(component, event, "Please select a Single Opportunity");
		} else if (selectedRows.length == 1) {
			component.set("v.isButtonActive", false);
			component.set("v.selectedOppty", selectedRows[0]);
		} else {
			component.set("v.isButtonActive", false);
			component.set("v.selectedOppty", null);
		}
	},

    nextStage: function(component, event, helper) {
        let currentOppty = component.get("v.currentOpportunity");
        if(currentOppty) {
            // CXPD-1584 - Restricting New Vehicle/Asset to get linked on Used Vehicle Opportunity
        	let assetPurchaseType = component.get("v.assetPurchaseType");
            if(assetPurchaseType && !((currentOppty.Purchase_Type__c == 'New Vehicle' && assetPurchaseType == 'New') || (currentOppty.Purchase_Type__c == 'Used Vehicle' && assetPurchaseType == 'Used'))) {
                let errorMessage = "It's a " + assetPurchaseType + " asset, please do check the Purchase Type value on opportunity.";
                helper.showToastMessage(component, event, errorMessage);
            } 
            // CXPD-1578 - Bypass validation rule when oppty purchase type is Used Vehicle
            else if(currentOppty.Purchase_Type__c != 'Used Vehicle') {
                var linkedOpportunities = component.get("c.getAssetLinkedOpportunities");
                linkedOpportunities.setParams({
                    assetId: component.get("v.assetId")
                });
                linkedOpportunities.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        let returnValue = response.getReturnValue();
                        if (returnValue) {
                            let errorMessage = component.get("v.assetName") + " is already linked with opportunity (" + returnValue.Opportunity.Name + ") created by " + returnValue.Opportunity.CreatedBy.Name + " on " + $A.localizationService.formatDate(returnValue.Opportunity.CreatedDate, "dd-MMM-yyyy");
                            // Display Error Message
                            helper.showToastMessage(component, event, errorMessage);
                        } else {
                            // Proceed to next screen to add vehicle
                            helper.getLineItemhelper(component, event, helper);
                            component.set("v.stage", false);
                        }
                    } else {
                        // Display Error Message
                        helper.showToastMessage(component, event, response.getReturnValue());
                    }
                });
                $A.enqueueAction(linkedOpportunities);
            } else {
                // Proceed to next screen to add vehicle
                helper.getLineItemhelper(component, event, helper);
                component.set("v.stage", false);
            }
        } else {
            let errorMessage = "Unexpected Error has occurred. Please Contact System Administrator.";
            // Display Error Message
            helper.showToastMessage(component, event, errorMessage);
        }
    },
    
    onAddVehicleSecondScreen: function(component, event, helper) {
        let currentOppty = component.get("v.currentOpportunity");
        if(currentOppty) {
            // CXPD-1584 - Restricting New Vehicle/Asset to get linked on Used Vehicle Opportunity
        	let assetPurchaseType = component.get("v.assetPurchaseType");
            if(assetPurchaseType && !((currentOppty.Purchase_Type__c == 'New Vehicle' && assetPurchaseType == 'New') || (currentOppty.Purchase_Type__c == 'Used Vehicle' && assetPurchaseType == 'Used'))) {
                let errorMessage = "It's a " + assetPurchaseType + " asset, please do check the Purchase Type value on opportunity.";
                helper.showToastMessage(component, event, errorMessage);
            } 
            // CXPD-1578 - Bypass validation rule when oppty purchase type is Used Vehicle
            else if(currentOppty.Purchase_Type__c != 'Used Vehicle') {
                var linkedOpportunities = component.get("c.getAssetLinkedOpportunities");
                linkedOpportunities.setParams({
                    assetId: component.get("v.assetId")
                });
                linkedOpportunities.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        let returnValue = response.getReturnValue();
                        if (returnValue) {
                            let errorMessage = component.get("v.assetName") + " is already linked with opportunity (" + returnValue.Opportunity.Name + ") created by " + returnValue.Opportunity.CreatedBy.Name + " on " + $A.localizationService.formatDate(returnValue.Opportunity.CreatedDate, "dd-MMM-yyyy");
                            // Display Error Message
                            helper.showToastMessage(component, event, errorMessage);
                        } else {
                            // Proceed to next screen to add vehicle
                            helper.navigateToAddVehicleSecondScreen(component, event, helper);
                        }
                    } else {
                        // Display Error Message
                        helper.showToastMessage(component, event, response.getReturnValue());
                    }
                });
                $A.enqueueAction(linkedOpportunities);
            } else {
                // Proceed to next screen to add vehicle
                helper.navigateToAddVehicleSecondScreen(component, event, helper);
            }
        } else {
            let errorMessage = "Unexpected Error has occurred. Please Contact System Administrator.";
            // Display Error Message
            helper.showToastMessage(component, event, errorMessage);
        }
    },

	backToScreenTwo: function(component, event, helper) {
		component.set("v.showVehicleInformation", true);
		component.set("v.showAddVehicleInfo", false);
		component.set("v.selectedOppty", null);
		component.set("v.opptyNameSelected", component.get("v.opptyName"));
	},
    
    handleSelect: function(component, event, helper) {
    	let selectedRows = component.find('accountTable').getSelectedRows();
        component.set("v.selectedAccountRows", selectedRows);
    },
    
    showMergeAccountModal: function(component, event, helper) {
        let selectedRows = component.find('accountTable').getSelectedRows();
        if(!selectedRows || selectedRows.length <= 1) {
            let errorMessage = "You must select two or three records to merge.";
            helper.showToastMessage(component, event, errorMessage);
        } else if(selectedRows.length > 3) {
            let errorMessage = "You may only select up to three records to merge.";
            helper.showToastMessage(component, event, errorMessage);
        } else {
            component.set("v.selectedAccountRows", selectedRows);
            component.set("v.showReviewAccountModal", true);    
        }
	},

	hideMergeAccountModal: function(component, event, helper) {
		component.set("v.showReviewAccountModal", false);
	},
    
    sendDuplicationAccountsForReview: function(component, event, helper) {
        // Logic to set selected primary account as a first record
        let data = component.get("v.selectedAccountRows");
        let primaryAccountId = component.get("v.primaryAccount");        
        data.forEach(function(item, i){
            if(item.Id === primaryAccountId){
                data.splice(i, 1);
                data.unshift(item);
            }
        });
        console.log(data);
        
        // Call server side action
        let sendReview = component.get("c.sendAccountsForReview");
		sendReview.setParams({
			accountList: component.get("v.selectedAccountRows")
		});
		sendReview.setCallback(this, function(response) {
			let state = response.getState();
			if (state === "SUCCESS") {
				let responseBody = response.getReturnValue();
                if(responseBody) {
                    helper.showToastMessage(component, event, responseBody);
                } else {
                    component.set("v.showReviewAccountModal", false);
                    // Display Success Message
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "type": "success",
                        "message": "Duplicate Account has been sent for Review."
                    });
                    toastEvent.fire();
                }
			} else {
                helper.showToastMessage(component, event, response.getReturnValue());
			}
		});
		$A.enqueueAction(sendReview);
	}
});