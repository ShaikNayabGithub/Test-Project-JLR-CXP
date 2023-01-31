({
    doInit : function(component, event, helper) {
        var setup = component.get("c.getEvents");
        setup.setParams({whereQuery : component.get('v.whereQueryProp'), limitNum : component.get('v.limitNumProp'), justMine : component.get('v.justMineProp')});
        //setup.setParams({approvalProcess : 'Streamlined_Opp_Approval_Aus_MENA_Eng'});
        // setup.setParams({approvalProcess : component.get('v.approvalProcessNames')});
        setup.setCallback(this, function(listDetail) {
            if(listDetail.getState() === 'SUCCESS'){
                console.log(listDetail.getReturnValue());
                component.set('v.eventList', listDetail.getReturnValue());   
                component.set("v.spinner", false); 
            }
            component.set("v.spinner", false); 
        });
        $A.enqueueAction(setup);
    }
    
})