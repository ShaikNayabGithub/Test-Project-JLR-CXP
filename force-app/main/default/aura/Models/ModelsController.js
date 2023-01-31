({
	doInit : function(component, event, helper) {
		var map = component.get("v.map");
        var custs = [];
        for(var key in map){
            custs.push({value:map[key], key:key});
        }
        custs.sort(function compare(a, b) {
            var valueA = a.key;
            var valueB = b.key;
            if (valueA > valueB) {
                return 1;
            } else if (valueA < valueB) {
                return -1;
            }
            return 0;
        });
        component.set("v.modelsList", custs);
        component.set("v.show", true);
	}
})