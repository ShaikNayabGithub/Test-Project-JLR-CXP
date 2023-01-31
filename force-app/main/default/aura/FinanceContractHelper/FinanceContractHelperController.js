({
    getPicklistValues : function(component, event, helper) {
        var params = event.getParam('arguments');
        var objectName;
        var fieldName;
        var callback;
        if (params) {
            objectName = params.objectName;
            fieldName = params.fieldName;
            callback = params.callback;
            helper.getPicklistValues(component,objectName,fieldName,callback);
        }
    }
})