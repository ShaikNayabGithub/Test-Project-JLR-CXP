({
    handleSuccess : function(component, event, helper) {
        var payload = event.getParams().response;
        console.log(JSON.stringify(payload));
    }    
})