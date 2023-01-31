({
    init : function(component, event, helper) {
        helper.getSpc(component, event, helper);
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        component.set('v.StartDate', today);
        component.set('v.maxDate', today);
        
        var minDate = new Date();
        minDate.setDate(minDate.getDate() - 29);
        var minDateVal = $A.localizationService.formatDate(minDate, "YYYY-MM-DD");
        component.set('v.minDate', minDateVal);
    },
    
    cancelSpc : function(component, event, helper) {
        var allValid = component.find('formField').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
        if (allValid) {
            var spinner = component.find('Id_spinner');
            $A.util.removeClass(spinner, "slds-hide");  
            const spcId = component.get('v.selectedValue');
            const cancelDate = component.get('v.StartDate');
            debugger;
            let action= component.get('c.cancelSelectedSpc');
            action.setParams({"spcId": spcId, "cancelDate":cancelDate});
            action.setCallback(this, function(response) {
                var state = response.getState();
                var toastEvent = $A.get("e.force:showToast");
                if (state === 'SUCCESS') {
                    var cancelMsg =  $A.get("$Label.c.SPC_Cancel_Message");
                    var cancelTitleMsg =  $A.get("$Label.c.SPC_Success");
                    toastEvent.setParams({"title":cancelTitleMsg, "type":"success", "message":cancelMsg});
                    var actionEvt =component.getEvent("Actionname");
                    actionEvt.setParams({
                        "actionname": 'Close'
                    });
                    actionEvt.fire();
                }else{
                    toastEvent.setParams({"title":"Error", "type":"error", "message":"Something went wrong!"});
                    var spinner = component.find('Id_spinner');
                    $A.util.addClass(spinner, "slds-hide");
                }
                toastEvent.fire();
            });
            $A.enqueueAction(action);
        }
    }
})