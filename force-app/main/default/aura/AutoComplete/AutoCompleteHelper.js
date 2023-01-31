({
    searchRecords : function(component, searchString) {
        var action = component.get("c.getRecords");
        action.setParams({
            "searchString" : searchString,
            "objectApiName" : component.get("v.objectApiName"),
            "idFieldApiName" : component.get("v.idFieldApiName"),
            "valueFieldApiName" : component.get("v.valueFieldApiName"),
            "extendedWhereClause" : component.get("v.extendedWhereClause"),
            "isPerson" : component.get("v.isPerson"),
            "Derivative_Product2Id" : component.get("v.Derivative_Product2Id"),        
            "maxRecords" : component.get("v.maxRecords")
        });
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                const serverResult = response.getReturnValue();
                const results = [];
                const offerMap =[];
                 console.log('test1');
                serverResult.forEach(element => {
                    const result = {id : element[component.get("v.idFieldApiName")], value : element[component.get("v.valueFieldApiName")], service : element.Service_Plan_Product2Id__c};
                    results.push(result);
                const offer = {key : element[component.get("v.idFieldApiName")], value : element.Id, service : element.Service_Plan_Product2Id__c};
                    offerMap.push(offer);
                });
                component.set("v.results", results);
                component.set("v.offerMap", offerMap);
            
                if(serverResult.length>0){
                    component.set("v.openDropDown", true);
                }
            } else{
                var toastEvent = $A.get("e.force:showToast");
                if(toastEvent){
                    toastEvent.setParams({
                        "title": "ERROR",
                        "type": "error",
                        "message": "Something went wrong!! Check server logs!!"
                    });
                    toastEvent.fire();
                }
            }
        });
        $A.enqueueAction(action);
    }
})