({
	  getDynamicRecordTypeIdHelper: function(component, event, helper,objectAPI) {
        var action = component.get("c.getDynamicRecordTypeId");
            action.setParams({
            objectType: objectAPI,
            recordTypeName: 'QMSp'
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state ===  $A.get("{!$Label.c.VME_SUCCESS}")) {
                var result = response.getReturnValue();
                console.log(result);
                component.set("v.selectedrecordType", result);
                if(component.get("v.recordTypeId")==result){
                     component.set("v.showDiv", true);
                }
                else{
                    component.set("v.showDiv", false);
             
                    var createRecordEvent = $A.get("e.force:createRecord");
                   var recordId = component.get("v.recordTypeId");
                    createRecordEvent.setParams({
                        "entityApiName": objectAPI,
                        "recordTypeId" : recordId
                        
                    });
                   
                    // this.closeMe(component,event,helper);
                    createRecordEvent.fire();
                
                   
                }
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            
        });
        $A.enqueueAction(action);
          
    },
    closeMe : function(component, event, helper) {
    var homeEvent = $A.get("e.force:navigateToObjectHome");
        homeEvent.setParams({
            "scope": component.get("v.sObjectName")
        });
        homeEvent.fire();
	},
})