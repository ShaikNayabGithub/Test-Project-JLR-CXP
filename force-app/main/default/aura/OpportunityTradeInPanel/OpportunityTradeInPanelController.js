({
    preloadValues : function(component, event, helper) {
        var initialModel = component.find("typedModel").get("v.value");
        var initialBrand = component.find("typedBrand").get("v.value");
        var initialTradeIn = component.find("typedTradeIn").get("v.value");
        if(initialModel != null){
        	component.set("v.selectedModel", initialModel);
        }
        if(initialBrand != null){
            component.set("v.selectedBrand", initialBrand);
        }
        if(initialTradeIn != null){
	        component.set("v.tradeIn", initialTradeIn);
        }
    },
    populateBrand : function(component, event, helper) {
        var typedText = component.get("v.selectedModel");
        if(typedText == null || typedText == ""){
            component.set("v.numRecords", 0);
        }
        else{
			var action = component.get("c.getTradeInBrand");
        	action.setParams({typed : typedText});
	       	action.setCallback(this, function(response) {
	            var state = response.getState();
	               if(state === 'SUCCESS' && response.getReturnValue() != null){
	                   var records = response.getReturnValue();
	                   component.set("v.listOfSearchRecords", records);
	                   component.set("v.numRecords", records.length);
	               }
	               else{
	                   component.set("v.numRecords", 0);
	               }
			});
	        $A.enqueueAction(action);
        }
	},
    divFunction : function(component, event, helper) {
        var vehicle = event.getSource().get("v.label");
        var brand = vehicle.substring(vehicle.lastIndexOf(' (')+2, vehicle.length);
        var model = vehicle.substring(0, vehicle.lastIndexOf(' ('));
        brand = brand.substring(0, brand.length-1);
        component.set("v.selectedModel", model);
        component.set("v.selectedBrand", brand);
        component.find("typedBrand").set("v.value", brand);
        component.find("typedModel").set("v.value", model);
        component.set("v.numRecords", 0);
    },
    saveDetails : function(component, event, helper) {
        var selectedTradeIn = component.get("v.tradeIn");
        component.find("typedTradeIn").set("v.value", selectedTradeIn);
        component.find("oppEditForm").submit();
        $A.get('e.force:refreshView').fire();
    }
})