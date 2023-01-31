({
    getcurrentLead : function(component, event, helper) {
        var action = component.get('c.getLead');
        action.setParams({  leadId : component.get("v.recordId")  });
        action.setCallback(component, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS'){
                component.set("v.currentLead",response.getReturnValue());
            } 
        });
        $A.enqueueAction(action);        
    },
     getcurrentLeadAccess : function(component, event, helper) {
        var action = component.get('c.getLeadAccess');
        action.setParams({  leadId : component.get("v.recordId")  });
        action.setCallback(component, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS'){
                component.set("v.currentLeadAccess",response.getReturnValue());
            } 
        });
        $A.enqueueAction(action);
    },
    getLeadLabels : function(component, event, helper) {
        var action = component.get('c.getLeadLabelMap');
        action.setParams({  objectName : 'Lead'  });
        action.setCallback(component, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS'){
                component.set("v.leadFieldLabelMap",response.getReturnValue());
            } 
        });
        $A.enqueueAction(action);
    },
    saveCurrentLead: function(component, event, helper) {
        console.log('saveLead');
        let button = event.getSource();
        var action = component.get('c.saveLead');
        action.setParams({  leadtobeupdated : component.get("v.currentLead")  });
        action.setCallback(component, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS'){ 
                var saveResult = response.getReturnValue();  
                console.log(saveResult.errorMessage);
                var toastEvent = $A.get("e.force:showToast");
                if(saveResult.errorMessage == 'No Error'){
                component.set("v.currentLead",response.getReturnValue().updatedLead);
                toastEvent.setParams({
                    "title": $A.get("$Label.c.Success"),
                    "type" : "success",
                    "message": $A.get("$Label.c.Lead_Updated_SuccessNew")
                }); 
                     toastEvent.fire();
                    button.set('v.disabled',false);
                }else{
                     toastEvent.setParams({
                    "title": "Error!",
                    "type" : "error",
                    "message": saveResult.errorMessage
                }); 
                     toastEvent.fire();
                    button.set('v.disabled',false);
                }
               
                
            } 
        });
        $A.enqueueAction(action);
    },allCommOptOut: function(component, event, helper, currentLead) {
        var currentRecord = currentLead;
        if(currentRecord.All_Communications_opt_out__c){ 
            currentRecord.HasOptedOutOfEmail = true;
            currentRecord.et4ae5__HasOptedOutOfMobile__c = true;
            currentRecord.Whitemail_Opt_Out__c = true;
            currentRecord.SMS_Opt_Out__c = true;
            currentRecord.DoNotCall = true;
            
            
        } 
        component.set("v.currentLead",currentRecord);
    }
})