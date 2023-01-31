({
    doInit : function(component, event, helper) {
        //standard fields
        var properId = component.get("v.recordId");
        if(properId == null || properId == ''){
            properId = component.get("v.communityRecordId");
        }
    	var standardFieldArray = [];
        var sf1 = component.get("v.standardField1");
        if(sf1 != null){
            standardFieldArray.push(sf1);
            var sf2 = component.get("v.standardField2");
            if(sf2 != null){
                standardFieldArray.push(sf2);
                var sf3 = component.get("v.standardField3");
                if(sf3 != null){
                    standardFieldArray.push(sf3);
                    var sf4 = component.get("v.standardField4");
                    if(sf4 != null){
                        standardFieldArray.push(sf4);
                    }
                }
            }
        }
        component.set("v.standardFields", standardFieldArray);
        //icon fields
    	var iconFieldArray = [];
        var iconArray = [];
        var jlrField = component.get("v.jlrIconBrand");
        if(jlrField == true){
            iconFieldArray.push("Brand__r.Name");
        }
        else{
            iconFieldArray.push("Id");
        }
        var if1 = component.get("v.iconField1");
        var ic1 = component.get("v.icon1");
        if(if1 != null && ic1 != null){
            iconFieldArray.push(if1);
            iconArray.push(ic1);
            var if2 = component.get("v.iconField2");
            var ic2 = component.get("v.icon2");
            if(if2 != null && ic2 != null){
                iconFieldArray.push(if2);
                iconArray.push(ic2);
                var if3 = component.get("v.iconField3");
                var ic3 = component.get("v.icon3");
                if(if3 != null && ic3 != null){
                    iconFieldArray.push(if3);
                    iconArray.push(ic3);
                }
            }
        }
        component.set("v.iconFields", iconFieldArray);
        component.set("v.iconNames", iconArray);
      	component.find("forceRecordCmp").reloadRecord();
    },
    
	displayValues : function(component, event, helper) {
        var fieldArray = component.get("v.iconFields");
        var dbValues = [];
        for(var fieldCount=0; fieldCount<fieldArray.length; fieldCount++){
			var fieldName = fieldArray[fieldCount];
        	var fieldValue = component.get("v.simpleRecord")[fieldName];
        	dbValues.push(fieldValue);
        }
        component.set("v.iconValues", dbValues);
	}
})