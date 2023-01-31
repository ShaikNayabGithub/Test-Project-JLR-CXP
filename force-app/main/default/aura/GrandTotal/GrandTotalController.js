({
	doInit : function(component, event, helper) {
        component.set("v.show", false);
        var masterMap = component.get("v.brandModelCountMap");
        debugger;
        if(masterMap[0] != undefined){
        	component.set("v.map", masterMap[0].grandMap);
        	component.set("v.show", true);
        }
    }
})