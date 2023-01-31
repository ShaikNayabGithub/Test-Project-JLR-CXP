({
    gotoObject : function(component, event, helper) {
        var objectName = component.get("v.objectName");
        var navEvt = $A.get("e.force:navigateToObjectHome");
        navEvt.setParams({
            "scope" : objectName
        });
        navEvt.fire();
    },
    createObject : function(component, event, helper) {
        var objectName = component.get("v.objectName");
        var recordType = component.get("v.recordTypeId");
        var navEvt = $A.get("e.force:createRecord");
        if(recordType != null && recordType != ''){
        	navEvt.setParams({
            	"entityApiName" : objectName,
            	"recordTypeId" : recordType
        	});
        }
        else{
            navEvt.setParams({
                "entityApiName" : objectName
            });
        }
        navEvt.fire();
    }
})