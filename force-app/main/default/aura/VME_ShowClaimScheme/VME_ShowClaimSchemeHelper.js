({
	getUserCurrency : function(component,event,helper){
               var action =component.get("c.get_User_Currency");
                 action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set("v.UserCurrency",response.getReturnValue());
                }
                    });
            $A.enqueueAction(action);        
    },
    getUserDetails : function(component,event,helper){
    	var action = component.get("c.fetchUser");
        action.setCallback(this, function(response) {                        
            if (response.getState() === "SUCCESS") {
                
                var storeResponse = response.getReturnValue();                                
                component.set("v.userInfo", storeResponse);                                
            }
        });
        $A.enqueueAction(action);
    },
	getClaimScheme : function(component,event,helper) {
		var action=component.get("c.getClaimSchemeData");
		var claimId=component.get("v.recordId");
		action.setParams({
			"claimId" : claimId
		});
		action.setCallback(this,function(response){
			component.set("v.vmeschemeObj",response.getReturnValue().schemeObj);
			component.set("v.vmeCampaignObj",response.getReturnValue().campaignObj);
		});
		$A.enqueueAction(action);
	}
})