({
	myAction : function(component, event, helper) {
		
	},
    init : function (cmp) {
        var flow = cmp.find("flowData");
        var recordId = cmp.get("v.recordId");
        console.log("recordId = " + recordId);
        var inputVariables = [
         { name : "recordId", type : "String", value: recordId }
        ];
        flow.startFlow("Milestone_Event_Flow", inputVariables);
    },
    handleStatusChange : function (component, event) {
       	if(event.getParam("status") === "FINISHED") {
           	console.log("flow finished getting outVars...");
           
           	var outputVariables = event.getParam("outputVariables");
           	console.log("outvars = " + outputVariables);
           	var outputVar;
           	for(var i = 0; i < outputVariables.length; i++) {
               	console.log("i = " + i);
               	outputVar = outputVariables[i];
               	if(outputVar.name === "varRelatedOpportunity") {
               		var urlEvent = $A.get("e.force:navigateToSObject");
                urlEvent.setParams({
                   "recordId": outputVar.value,
                   "isredirect": "true"
                });
                urlEvent.fire();
             }
          }
       }
    }
})