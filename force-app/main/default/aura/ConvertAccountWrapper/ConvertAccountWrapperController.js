/**
 * Created by caleb on 17/03/2020.
 */

({
    myAction : function(component, event, helper) {

    },
    init : function (cmp, event, helper) {
        var flow = cmp.find("flowData");
        var opportunityId = helper.getUrlParameter('opportunityId');
        var flowName = helper.getUrlParameter('flowName');
        console.log("opportunityId = " + opportunityId);
        var inputVariables = [
            { name : "opportunityId", type : "String", value: opportunityId }
        ];
        flow.startFlow(flowName, inputVariables);
    },
    handleStatusChange : function (cmp, event, helper) {
        if(event.getParam("status") === "FINISHED") {

            var opportunityId = helper.getUrlParameter('opportunityId');
            console.log('opportunityId = ' + opportunityId);
            var urlEvent = $A.get("e.force:navigateToSObject");
            urlEvent.setParams({
                "recordId": opportunityId,
                "isredirect": "true"
            });
            urlEvent.fire();
        }
    },
    handleCancel: function (cmp, event, helper) {
        var opportunityId = helper.getUrlParameter('opportunityId');
        console.log('opportunityId = ' + opportunityId);
        var urlEvent = $A.get("e.force:navigateToSObject");
        urlEvent.setParams({
            "recordId": opportunityId,
            "isredirect": "true"
        });
        urlEvent.fire();
    }
});