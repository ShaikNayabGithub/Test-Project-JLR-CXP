({
    handleRequest : function(component, approvalType) {
        var enteredComment = component.get('v.approvalComment');
        //if(enteredComment.trim() == ''){
        //    var toastEvent = $A.get("e.force:showToast");
        //    toastEvent.setParams({"title":"Error", "type":"error", "message":"You must enter a comment to proceed"});
        //    toastEvent.fire();
        //}
        //else{
        var setup = component.get("c.submitApprovalProcess");
        setup.setParams({recordId : component.get('v.approvalWorkitem'), comment : component.get('v.approvalComment'), approvalAction : approvalType});
        setup.setCallback(this, function(approvalDetail) {
            var successToast = false;
            var failMessage = '';
            if(approvalDetail.getState() === 'SUCCESS'){
                if(approvalDetail.getReturnValue() == 'success'){
                    successToast = true;
                }
                else failMessage = approvalDetail.getReturnValue();
            }
            if(successToast){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({"title":"Success", "type":"info", "message":approvalType + " approval successfully processed"});
                toastEvent.fire();
            }
            else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({"title":"Error", "type":"error", "message":"Could not " + approvalType + " approval: " + failMessage});
                toastEvent.fire();
            }
            component.set('v.showApprove', false);
            component.set('v.showReject', false);
           console.log('test');
            $A.enqueueAction(component.get("c.doInit"));
        });
        $A.enqueueAction(setup);
        //}
    }
})