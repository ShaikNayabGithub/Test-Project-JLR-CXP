({
closeMe : function(component, event, helper) {
    var homeEvent = $A.get("e.force:navigateToObjectHome");
        homeEvent.setParams({
            "scope": component.get("v.sObjectName")
        });
        homeEvent.fire();
	},
TacticalAction :function(component, event, helper){
var evt = $A.get("e.force:navigateToComponent");      
evt.setParams({
componentDef:"c:VME_Tactical_Actions",
});

evt.fire();
},
})