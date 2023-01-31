({
	closeMe : function(component, event, helper) {
		component.set("v.isOpenComp",false);
	},
	getFiltersData : function(component, event, helper){
		console.log(JSON.parse(JSON.stringify(component.get("v.brandWiseMap"))));
		console.log(JSON.parse(JSON.stringify(component.get("v.userDetails"))));
		console.log(component.get("v.isOpenComp"));
	}
})