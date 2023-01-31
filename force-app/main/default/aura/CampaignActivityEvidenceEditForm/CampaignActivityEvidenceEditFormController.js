({
    navToRecord : function (component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        
        navEvt.setParams({
            "recordId": component.get("v.evidencerecordId")
        });
        navEvt.fire();
    },
    
    showSpinner:  function(component, event) {
        var spinner = component.find('Id_spinner');
        $A.util.removeClass(spinner, "slds-hide");
    },
    hideSpinner :  function(component, event) {
        
        var errors = JSON.parse(JSON.stringify(event.getParams().error)).body.output.errors;
        console.log(errors);
        debugger;
        var spinner = component.find('Id_spinner');
        $A.util.addClass(spinner, "slds-hide");
        
        for(var i=0; i<errors.length; i++)
        {
        var toastEvent = $A.get("e.force:showToast");  
        toastEvent.setParams({
           "title": "error",
           "message": errors[i].message,
            "type" :"error"
        });
       toastEvent.fire();
    }
    },
    
    handleSuccess : function (component, event, helper) {

        var payload = event.getParams().response;
        
		var payystong = JSON.stringify(payload);
        var recordName =   JSON.parse(payystong).fields.Name.value; 
                debugger;
        var cmpEvent = component.getEvent("evidanceCreated");

        cmpEvent.setParams({
            "newRecordId" : payload.id,
            "newRecordName" : recordName});
        cmpEvent.fire();
        var spinner = component.find('Id_spinner');
        $A.util.addClass(spinner, "slds-hide");
},
    
    handleSubmit : function (component, event, helper) {    
        $A.get('e.force:refreshView').fire();
    },
        
        loadForm : function(component) {
            var status = component.find("statusValue").get("v.value");
            debugger;
            component.set("v.show", false);
            if (status == 'Draft' || status == 'Claim Rejected'){
               component.set("v.show", true);
            }
        }
})