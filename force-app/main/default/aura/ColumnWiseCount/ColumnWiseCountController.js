({
	doInit : function(component, event, helper) {
        var key = component.get("v.key");
        var map = component.get("v.map");
        var defaultvalue = 0;
        if(map[key] != undefined)
        	component.set("v.value" , map[key]);
        else
            component.set("v.value" , defaultvalue);
    }
})