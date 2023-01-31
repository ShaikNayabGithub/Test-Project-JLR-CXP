({
    openOpportunity : function(component, event, helper) {
        var cmpEvent = component.getEvent("FinanceContractEvent");
        cmpEvent.setParams({
            "message" : "Open_Opportunity" 
        });
        cmpEvent.fire();
        
    },
    openContract : function(component, event, helper) {
        var cmpEvent = component.getEvent("FinanceContractEvent");
        cmpEvent.setParams({
            "message" : "Open_Contract" 
        });
        cmpEvent.fire();
        
    }
})