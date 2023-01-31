({
    handleSubmit : function(component, event, helper) {
        var payload = event.getParams().response;
        console.log(JSON.stringify(payload));
    },    
     handleSuccess : function(component, event, helper) {
        var payload = event.getParams().response;
        console.log(JSON.stringify(payload));
    }, 
  handleLoad : function(component, event, helper) {
        var payload = event.getParams().response;
        console.log(JSON.stringify(payload));
    } 
})