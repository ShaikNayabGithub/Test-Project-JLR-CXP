({
    registerApproval : function(component, event, helper) {
        var recordIdParam = component.get("v.CommunityRecordId");     
        if(recordIdParam == null) {
            recordIdParam = component.get("v.recordId");
        }
        var userIdParam = component.get("v.communityUserId");
        if(userIdParam == null || userIdParam.trim() == '') {
            userIdParam = $A.get("$SObjectType.CurrentUser.Id");
            
        }
        var toastEvent = $A.get("e.force:showToast");  
        
        
        var action = component.get("c.submitForApproval");
        action.setParams({"recordId": recordIdParam, "approvalComment": component.get("v.approvalComment")});
        action.setCallback(this, function(response) {
            if(component.isValid() && response.getState() == "SUCCESS") {
                toastEvent.setParams({
                    "title": "success",
                    "message": "Sent for Approval"
                });
                toastEvent.fire();
                component.set("v.enableApproval",false);
            }
            else{
                var errors = response.getError();
                if(errors && errors[0] && errors[0].message){
                    toastEvent.setParams({
                        "title": "Error",
                        "message": "Could not send for Approval due to"+errors[0].message
                    });
                }
                else{
                    toastEvent.setParams({
                        "title": "Error",
                        "message": "Unknown error in sending for Approval"
                    });
                }
                toastEvent.fire();
            }
            
        });
        $A.enqueueAction(action);
    }
})