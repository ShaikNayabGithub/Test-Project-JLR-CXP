({
    init : function(component, event, helper) {
           helper.getAccountHelper(component, event, helper);
    },
    convertIndividual : function(component, event, helper) {
       
           helper.convertRecordTypeHelper(component, event, helper);
    },
    convertCorporate : function(component, event, helper) {
        var button = event.getSource();
        button.set('v.disabled',true);
        console.log(component.get('v.currentAccount').Contacts);
        if((component.get('v.currentAccount').Contacts != undefined && component.get('v.currentAccount').Contacts.length > 0) || 
           (component.get('v.currentPrimaryAccount') != null && component.get('v.currentPrimaryAccount').Contacts != undefined && component.get('v.currentPrimaryAccount').Contacts.length > 0)) {
             var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": $A.get("$Label.c.Error"),
                    "type":"error",
                    "message": $A.get("$Label.c.Account_Convert_Error"),
                });
                toastEvent.fire();
            button.set('v.disabled',false);
        }else{
            helper.convertRecordTypeHelper(component, event, helper);
        }
           
    },
 
})