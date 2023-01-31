({
    doInit : function(component, event, helper){
        var oRecord = component.get('v.oRecord');
        var fieldName = component.get('v.fieldName');
        component.set('v.value',oRecord[fieldName]);
    },
    selectRecord : function(component, event, helper){      
        var getSelectRecord = component.get("v.oRecord");
        
        var compEvent = component.getEvent("oSelectedRecordEvent");
        compEvent.setParams({"recordByEvent" : getSelectRecord });  
        compEvent.fire();
        
        var searchtype = component.get("v.searchtype");
        console.log('searchtype --->  '+searchtype);
        if(searchtype != null || searchtype != 'null'){
            
            var cmpEvent = component.getEvent("FinanceContractEvent");
            cmpEvent.setParams({
                "message" : getSelectRecord,
                "recordType" : searchtype
            });
            cmpEvent.fire();
        }
    }
})