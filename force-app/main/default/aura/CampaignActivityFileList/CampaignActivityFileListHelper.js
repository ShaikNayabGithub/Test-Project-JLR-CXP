({
	loadCampaignActivityFiles : function(cmp) {
    	var action = cmp.get("c.getActivityFiles");
        var recordIdParam = cmp.get("v.campaignActivityId");
        console.log('Got Campaign Activity Id ' + recordIdParam);
        action.setParams({campaignActivityId: recordIdParam});
        action.setCallback(this, function(response){
           var state = response.getState();
            if(state === "SUCCESS"){
                cmp.set("v.activityFiles", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
	}
})