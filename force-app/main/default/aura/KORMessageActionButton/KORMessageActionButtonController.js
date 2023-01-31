({
    cancel : function (component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },
    doInit: function(component, event, helper) {
        var newRecordId = component.get("v.recordId");
    },
    recordUpdate: function(component, event, helper) {
        var toNumber = component.get("v.record").PersonMobilePhone;
        component.set("v.toNumber", toNumber);
    },
    sendMessage : function(component, event, helper) {

        var allValid = component.find('field').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);

        if (allValid) {
            var content = component.get("v.content");
            var toNumber = component.get("v.toNumber");
            var recordId = component.get("v.recordId");
            helper.openConfirm(component, helper, content, toNumber, recordId);    
        }
    },

});