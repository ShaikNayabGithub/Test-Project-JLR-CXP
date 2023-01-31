({
	doInit : function(component, event, helper) {
		 var getRejCanActivities =component.get("c.getRejCanActivities");
        getRejCanActivities.setParams({ campaignId : component.get("v.campaignId")}); 
        getRejCanActivities.setCallback(this, function(getRejCanActivitiesResponse){
            
            if(getRejCanActivitiesResponse.getState() == 'SUCCESS'){ 
                 component.set("v.activityList", getRejCanActivitiesResponse.getReturnValue());
            }
            
        });
        $A.enqueueAction(getRejCanActivities);
	},
    
    redirectTorecord  : function(component, event, helper) {
        var target = event.currentTarget;
        var activityId = target.getAttribute("id"); 
        debugger;
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": activityId,
            "slideDevName": "detail"
        });
        navEvt.fire();
    }
})