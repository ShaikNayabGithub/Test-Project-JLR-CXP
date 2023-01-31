({
	doInit : function(component, event, helper) {
        component.set("v.showSpinner", true);
		var setup = component.get("c.getApprovalList");
        //setup.setParams({approvalProcess : 'Streamlined_Opp_2stepApproval_ROW_Korea'});
        setup.setParams({approvalProcess : component.get('v.approvalProcessNames')});
        setup.setCallback(this, function(listDetail) {
            if(listDetail.getState() === 'SUCCESS'){
                component.set('v.approvalList', listDetail.getReturnValue());                
            }
        component.set("v.showSpinner", false);
        component.set("v.approvalComment", '');
        });
        $A.enqueueAction(setup);
	},
    handleSelect : function(component, event, helper) {
        var actionparam = event.getParam('value');
        var actiontype;
        var actionworkitem;
        if(actionparam.indexOf('Approve') > -1){
            actiontype = 'Approve';
        }
        else if(actionparam.indexOf('Reject') > -1){
            actiontype = 'Reject';
        }
        actionworkitem = actionparam.substr(actiontype.length);
        component.set('v.approvalWorkitem', actionworkitem);
        if(actiontype == 'Approve'){
            component.set('v.showReject', false);
            component.set('v.showApprove', true);
        }
        else if(actiontype == 'Reject'){
            component.set('v.showApprove', false);
            component.set('v.showReject', true);
        }
    },
    closeModal : function(component, event, helper) {
        component.set('v.showApprove', false);
        component.set('v.showReject', false);
    },
    approveRequest : function(component, event, helper) {
		helper.handleRequest(component, 'Approve');
    },
    rejectRequest : function(component, event, helper) {
		helper.handleRequest(component, 'Reject');
    }
})