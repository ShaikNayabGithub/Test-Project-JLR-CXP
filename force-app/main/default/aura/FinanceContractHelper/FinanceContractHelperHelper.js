({
    getPicklistValues : function(component,objName,FieldName,callback) {
        var getPicklistValData = component.get('c.getPicklistValuesData'); 
        getPicklistValData.setParams({
            "ObjectApi_name" : objName,
            "Field_name" : FieldName 
        });
        getPicklistValData.setCallback(this, function(a){
            var state = getPicklistValData.getState();
            if (state === "SUCCESS") {
                if(callback) callback(getPicklistValData.getReturnValue());
            }else{
                if(callback) callback(getPicklistValData.getReturnValue());
            }
        });
        $A.enqueueAction(getPicklistValData);
    }
})