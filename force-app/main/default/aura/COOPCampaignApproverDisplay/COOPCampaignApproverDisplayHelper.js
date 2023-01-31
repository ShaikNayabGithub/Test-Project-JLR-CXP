({
	getApproverDetails : function(component, event, helper) {
         var getNextApproverDetails = component.get("c.getNextApproverDetails");
        getNextApproverDetails.setParams({campaignId : component.get("v.campaignId")}); 
        getNextApproverDetails.setCallback(this, function(getNextApproverDetailsResponse){
                 if(getNextApproverDetailsResponse.getState() == 'SUCCESS'){  
                     debugger;
                     component.set("v.approverName",getNextApproverDetailsResponse.getReturnValue()); 
                     }
        });
        $A.enqueueAction(getNextApproverDetails); 
		
	}
})