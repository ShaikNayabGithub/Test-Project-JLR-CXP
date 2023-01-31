({
    searchHelper : function(component,event,getInputkeyWord) {
        var action = component.get("c.fetchLookUpValues");
        action.setParams({
            'searchKeyWord': getInputkeyWord,
            'ObjectName' : component.get("v.objectAPIName"),
            'fieldName' : component.get("v.fieldName"),
            'region' : component.get("v.region")
        });
        action.setCallback(this, function(response) {
            $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            console.log('state --> '+state);
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                console.log('storeResponse --> '+JSON.stringify(storeResponse));
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Result Found...');
                } else {
                    component.set("v.Message", '');
                }
                component.set("v.listOfSearchRecords", storeResponse);
            }
            
        });
        $A.enqueueAction(action);
    },
    searchContactData : function(component,event,getInputkeyWord) {
        var action = component.get("c.fetchContactDataValues");
        action.setParams({
            'searchKeyWord': getInputkeyWord,
            'ObjectName' : component.get("v.objectAPIName"),
            'countryCode' : component.get("v.countryCode"),
            'fieldType' : component.get("v.fieldType"),
        });
        action.setCallback(this, function(response) {
            $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            console.log('state --> '+state);
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                console.log('storeResponse --> '+JSON.stringify(storeResponse));
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Result Found...');
                } else {
                    component.set("v.Message", '');
                }
                component.set("v.listOfSearchRecords", storeResponse);
            }
            
        });
        $A.enqueueAction(action);
    },
    searchVehicleHelper : function(component,event,getInputkeyWord) {
        var action = component.get("c.fetchVehicleValues");
        action.setParams({
            'searchKeyWord': getInputkeyWord,
            'ObjectName' : component.get("v.objectAPIName"),
            'brandValue' : component.get("v.brandValue")
        });
        action.setCallback(this, function(response) {
            $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            console.log('state --> '+state);
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                console.log('storeResponse --> '+JSON.stringify(storeResponse));
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Result Found...');
                } else {
                    component.set("v.Message", '');
                }
                component.set("v.listOfSearchRecords", storeResponse);
            }
            
        });
        $A.enqueueAction(action);
    },
})