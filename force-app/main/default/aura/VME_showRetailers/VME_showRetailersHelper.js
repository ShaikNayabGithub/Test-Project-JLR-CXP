({
	 statusPopup : function(component,event,helper,title,bodyMessage,recordId,CurrentScheme,showOkay,showBoth,CompName) {
     this.showSpinner(component,event,helper);
        $A.createComponent(
            "c:VME_ConfirmModal",
            {
                "title": title,
                "bodyMsg": bodyMessage,
              "recordId": recordId,
                "showOkay":showOkay,
                 "showBoth":showBoth,
                 "CurrentScheme":CurrentScheme,
                 "CompName":CompName
            },
            function(msgBox){                
                if (component.isValid()) {
                    var targetCmp = component.find('ModalDialogPlaceholder');
                    var body = targetCmp.get("v.body");
                    body.push(msgBox);
                    targetCmp.set("v.body", body); 
                }
            }
        );
     this.hideSpinner(component,event,helper);
    },

      showSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
     
    hideSpinner: function (component, event, helper) {
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    },
})