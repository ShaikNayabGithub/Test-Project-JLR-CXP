({   
    keyCheck : function(component, event, helper){
        if (event.which == 13){
            helper.getAsset(component, event, helper);   
        }
    },
    
    addSP : function (component, event, helper) {
        component.set("v.isExtended", false);
        component.set("v.isCancel", false);
        component.set("v.modalName", $A.get("$Label.c.SPC_Add_Service_Plan"));
        component.set("v.showModal", true);
        component.set("v.isTransfer", false);
    },
    
    addESP : function (component, event, helper) {
        component.set("v.isExtended", true);
        component.set("v.showModal", true);
        component.set("v.isCancel", false);
        component.set("v.modalName", $A.get("$Label.c.SPC_Extend_Service_Plan"));
        component.set("v.isTransfer", false);
    },
    
    cancelSP : function (component, event, helper) {
        component.set("v.isExtended", false);
        component.set("v.showModal", true);
        component.set("v.isCancel", true); 
        component.set("v.modalName", $A.get("$Label.c.SPC_Cancel_Service_Plan"));
        component.set("v.isTransfer", false);
    },      
    
    closeModal:function(component,event,helper){    
        component.set("v.showModal", false);
    },
    
    closeactionevt : function(component,event,helper){
        console.log('--> '+event.getParam("actionname"));
        if(event.getParam("actionname") === 'Close'){
            component.set("v.showModal", false);
            helper.getAsset(component, event, helper);
        }
         console.log('--> '+(event.getParam("actionname") === 'ExtendedAdded'));
        if(event.getParam("actionname") === 'ExtendedAdded'){
            component.set("v.showExtendedBtn", false);
            component.set("v.isTransfer", false);
             console.log('--> '+component.get("v.showExtendedBtn"));
            console.log('--> '+component.get("v.isTransfer"));
        }
    },
    
    handleClick : function(component, event, helper) {
        helper.getAsset(component, event, helper); 
    },
    
    transferSp : function(component, event, helper) {
        component.set("v.isTransfer", true);
        let spc = component.get("v.servicePlanContracts");
        let selectedIndex = event.getSource().get("v.name");
        component.set("v.selectedServicePlan", spc[selectedIndex]);
        component.set("v.showModal", true);
        component.set("v.isExtended", false);
        component.set("v.isCancel", false); 
        component.set("v.modalName", $A.get("$Label.c.SPC_Transfer_Service_Plan"));
    },
    
    /*transfer : function(component, event, helper) {
        component.set('v.showSpinner',true);  
        var spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-show");
        var assId = component.get('v.assetFound').Id;
        var action1 = component.get('c.transferAsset');
        action1.setParams({ assId: assId});
        action1.setCallback(this, function(response1) {
            var state1 = response1.getState();
            if (state1 === 'SUCCESS') {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({"title":"Success", "type":"success", "message":"Vehicle Ready To Be Added To Opportunity"});
                toastEvent.fire();                
                component.set('v.showResults',false);    
                var spinner = component.find("mySpinner");
                $A.util.toggleClass(spinner, "slds-hide");
                component.set('v.showSpinner',false);  
                
            }else{                
                var toastEvent = $A.get("e.force:showToast");                
                toastEvent.setParams({"title":"Error", "type":"error", "message":response1.getError()[0].message});
                toastEvent.fire();
                component.set('v.showResults',true);  
                var spinner = component.find("mySpinner");
                $A.util.toggleClass(spinner, "slds-hide");
                component.set('v.showSpinner',false);  
            }
        });
        $A.enqueueAction(action1);
    },*/
    
})