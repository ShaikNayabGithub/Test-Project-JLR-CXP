({
    getViewData : function(component,event) {
        this.showspinner(component, event);
        var actionPerm = component.get("c.CXPpermission");       
        actionPerm.setCallback(this,function(response){
            var state = response.getState();      
            if (state === 'SUCCESS') {
                var resultList = response.getReturnValue();	
                component.set("v.CXPPermission", resultList);
            }
        });
        $A.enqueueAction(actionPerm);
        
        var actionPerm1 = component.get("c.Portalpermission");       
        actionPerm1.setCallback(this,function(response){
            var state = response.getState();      
            if (state === 'SUCCESS') {
                var resultList = response.getReturnValue();	
                component.set("v.PortalPermission", resultList);
            }
        });
        $A.enqueueAction(actionPerm1);
        
        var action = component.get("c.fetchColumnValues");       
        action.setCallback(this,function(response){
            var state = response.getState();      
            if (state === 'SUCCESS') {
                var resultList = response.getReturnValue();	
                component.set("v.columnsList", resultList);
            }
        });
        $A.enqueueAction(action);
        
        var action0 = component.get("c.fetchCountryValues");       
        action0.setCallback(this,function(response){
            var state = response.getState();      
            if (state === 'SUCCESS') {
                var resultList0 = response.getReturnValue();	
                component.set("v.countryOptions", resultList0);
            }
        });
        $A.enqueueAction(action0);
        
        var action1 = component.get("c.fetchTableData");       
        action1.setCallback(this,function(response){
            var state = response.getState();      
            if (state === 'SUCCESS') {
                debugger;
                var resultList1 = response.getReturnValue();
                for(var key in resultList1){
                	for(var key2 in resultList1[key].ModelCountMap)
                		console.log(key2 + '  ' + resultList1[key].ModelCountMap[key2]);
                }
                component.set("v.brandModelCountMap", resultList1);
                component.set("v.show", true);
            }
            this.hidespinner(component, event);
        });
        $A.enqueueAction(action1);
    },
    
    getFilteredData : function(component,event) {
        this.showspinner(component, event);
        var action = component.get("c.fetchTableData");
        console.log(component.get("v.selectedCountry"));
        action.setParams({ "startDate" : component.get("v.startDate"), "endDate" : component.get("v.endDate"), "Country" : component.get("v.selectedCountry") });
        action.setCallback(this,function(response){
            var state = response.getState();      
            if (state === 'SUCCESS') {
                debugger;
                var resultList1 = response.getReturnValue();	
                component.set("v.brandModelCountMap", resultList1);
            }
            this.hidespinner(component, event);
        });
        $A.enqueueAction(action);
    },
    
    showspinner : function(component, event){
        var m = component.find('modalspinnerLookup');
        $A.util.removeClass(m, "slds-hide");
    },
    
    hidespinner : function(component, event){
        var m = component.find('modalspinnerLookup');
        $A.util.addClass(m, "slds-hide");
    }
})