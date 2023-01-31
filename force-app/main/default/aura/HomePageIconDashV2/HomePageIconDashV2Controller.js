({
    doInit : function(component, event, helper) {
        var profileaction = component.get("c.getIsSalesManager");
        profileaction.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.salesmanager" , response.getReturnValue());
            }
        });
        $A.enqueueAction(profileaction);
        var action = component.get("c.getDashboardStats");
             action.setParams({"daysInPast": component.get('v.showOppsXDaysOld')});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                console.log(response.getReturnValue());
                component.set("v.dashStats" , response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    eventFire : function(component, event, helper) {
        console.log(event.currentTarget.getAttribute("id"));
        var appEvent = $A.get("e.c:HomeApplicationEvent");
        var thisTableName = event.currentTarget.getAttribute("id");
        var thisIconName = '/Home/Icon_Assigned_Opportunities.png';
        if(thisTableName == $A.get("$Label.c.Follow_Ups_Today")) thisIconName = '/Home/Icon_FollowUpsToday.png';
        else if(thisTableName == $A.get("$Label.c.Follow_Ups_Overdue")) thisIconName = '/Home/Icon_OverdueFollowUps.png';
        appEvent.setParams({ "tabName" : thisTableName, "iconName" : thisIconName});
        appEvent.fire();
    },
    gotoTargets : function(component, event, helper) {
       var pageName = event.currentTarget.getAttribute("id");
          var navService = component.find("navService");
        var pageReference = {
            type: 'comm__namedPage',
            attributes: {                
                pageName: pageName
            }
        };
        navService.navigate(pageReference);
    },
    gotoApprovals : function(component, event, helper) {        
          var navService = component.find("navService");
        var pageReference = {
            type: 'comm__namedPage',
            attributes: {                
                pageName: 'approval-list'
            }
        };
        navService.navigate(pageReference);
    }
})