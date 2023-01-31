({
    createTask : function(component, event, helper) {
        var recordType = event.getParam("value");
        var navEvt = $A.get("e.force:createRecord");
        if(recordType != null && recordType != ''){
        	navEvt.setParams({
            	"entityApiName" : "Task",
            	"recordTypeId" : recordType
        	});
        }
        else{
            navEvt.setParams({
                "entityApiName" : "Task"
            });
        }
        navEvt.fire();
	},
    createCase : function(component, event, helper) {
        var recordType = event.getParam("value");
        var navEvt = $A.get("e.force:createRecord");
        if(recordType != null && recordType != ''){
        	navEvt.setParams({
            	"entityApiName" : "Case",
            	"recordTypeId" : recordType
        	});
        }
        else{
            navEvt.setParams({
                "entityApiName" : "Case"
            });
        }
        navEvt.fire();
	},
    createAccount : function(component, event, helper) {
        var recordType = event.getParam("value");
        var navEvt = $A.get("e.force:createRecord");
        if(recordType != null && recordType != ''){
        	navEvt.setParams({
            	"entityApiName" : "Account",
            	"recordTypeId" : recordType
        	});
        }
        else{
            navEvt.setParams({
                "entityApiName" : "Account"
            });
        }
        navEvt.fire();
	},
    createContact : function(component, event, helper) {
        var recordType = event.getParam("value");
        var navEvt = $A.get("e.force:createRecord");
        if(recordType != null && recordType != ''){
        	navEvt.setParams({
            	"entityApiName" : "Contact",
            	"recordTypeId" : recordType
        	});
        }
        else{
            navEvt.setParams({
                "entityApiName" : "Contact"
            });
        }
        navEvt.fire();
	}
})