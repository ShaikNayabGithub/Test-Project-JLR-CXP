({
    doInit : function(component, event, helper) {
        
        helper.getFYdefaultvalues(component, event, helper);
        helper.getModelListHelper(component,event,helper);
        helper.getUserDetailsHelper(component,event,helper);
        
    },
    
    redirectTorecord : function(component, event, helper) { 
        var target = event.currentTarget;
        var campaignId = target.getAttribute("id"); 
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": campaignId,
            "slideDevName": "detail"
        });
        navEvt.fire();
    },
    
    onYearChange: function(component, event, helper) {
        var selectedYear =  component.get("v.selectedYear");
        var inputField = component.find('fyyear');
        var yearFormat = /^[0-9]{2}-[0-9]{2}/;
        if(selectedYear.match(yearFormat)){
            var finalYear = (''+component.get("v.currentFYDetails").financailYear).substring(0,2)+selectedYear.split('-')[1];
            if(parseInt(finalYear) > component.get("v.currentFYDetails").financailYear + 2){
                inputField.setCustomValidity("Year is not valid");
            }else{
                inputField.setCustomValidity("");
            }
        }else{
            inputField.setCustomValidity("Enter correct year format");
        }
        inputField.reportValidity();
        component.set("v.selectedQuarter","none");
    },
    
    onBrandChange: function(component, event, helper) {
        component.set("v.selectedModel","none");
        if(component.get("v.selectedBrand") == 'Jaguar'){            
            component.set("v.modelList", component.get("v.modelMap").Jaguar);
        }else if(component.get("v.selectedBrand") == 'Land Rover'){            
            component.set("v.modelList", component.get("v.modelMap")['Land Rover']);
        }else{
            component.set("v.modelList", component.get("v.modelMap")['Jaguar Land Rover']);            
        }
        var spinner = component.find('Id_spinner');
        $A.util.removeClass(spinner, "slds-hide"); 
        helper.getCampaignsHelper(component, event, helper);
    },
    
    setQuarter : function(component, event, helper) {
        var spinner = component.find('Id_spinner');
        $A.util.removeClass(spinner, "slds-hide"); 
        helper.getRetailerHelper(component,event,helper);
    },
    
    getCampaigns : function(component, event, helper) {
        var spinner = component.find('Id_spinner');
        $A.util.removeClass(spinner, "slds-hide"); 
        helper.getCampaignsHelper(component, event, helper);
    },
    
    setSelectedRetailer : function(component, event, helper) {
        var selectedValue = event.getParam("selectedValue");
        if(selectedValue =='--None--'){
            component.set("v.showActivityModal",false); 
        }else{
            component.set("v.selectedRetailer",selectedValue);
        }
        var spinner = component.find('Id_spinner');
        $A.util.removeClass(spinner, "slds-hide"); 
        helper.getCampaignsHelper(component, event, helper);
    },
    
    showActivityModal: function(component, event, helper) {
        debugger;
        component.set("v.campaignId",null); 
        component.set("v.activityId",null); 
        component.set("v.campaignActivityName",null); 
        var buttonAction=event.getSource().get("v.name")
        var idList = buttonAction.split('-$');
        
        component.set("v.campaignId",idList[0]); 
        component.set("v.campaignName",idList[1]);
        component.set("v.showActivityModal",true);
        component.set("v.campaignCurency",idList[2]);
        component.set("v.modalHeading","New Campaign Activity"); 
    },
    
    showSubmitModal: function(component, event, helper) {
        component.set("v.campaignId",event.getSource().get("v.name")); 
        component.set("v.showSubmitModal",true); 
        component.set("v.modalHeading","Submit For Approval"); 
    },
    
    closeModal:function(component,event,helper){    
        component.set("v.showActivityModal",false);   
        component.set("v.showSubmitModal",false); 
        component.set("v.showApprovalModal",false);
        component.set("v.showCancelModal",false);
        component.set("v.showCommentModal",false);
        component.set("v.showconfirmModal",false);   
    },
    
    showSubmitModal: function(component, event, helper) {
        component.set("v.campaignId",event.getSource().get("v.name")); 
        component.set("v.showSubmitModal",true); 
        component.set("v.modalHeading","Submit For Approval"); 
    },
    
    showApprovalModal: function(component, event, helper) {
        component.set("v.campaignId", event.getSource().get("v.name")); 
        component.set("v.showApprovalModal", true); 
        component.set("v.modalHeading","Campaign Approval"); 
    },
    
    showCommentModal: function(component, event, helper) {
        component.set("v.campaignId", event.getSource().get("v.name")); 
        component.set("v.showCommentModal", true); 
        component.set("v.modalHeading","Campaign Comments"); 
    },
    
    saveComments: function(component, event, helper) {
        var spinner = component.find('Id_spinner');
        $A.util.removeClass(spinner, "slds-hide"); 
        helper.saveCommentsHelper(component, event, helper);
    },
    
    showCancelModal: function(component, event, helper) {
        var buttonAction = event.getSource().get("v.name"); 
        var idList = buttonAction.split('-');
        var editForm = component.find("editForm");
        debugger;
        
        
        component.set("v.campaignId",idList[0]); 
        component.set("v.activityId",idList[1]);
        component.set("v.showCancelModal", true); 
        component.set("v.modalHeading","Campaign Activity Cancellation"); 
    },
    
    approvalhandler: function(component, event, helper){
        var buttonAction = event.getSource().get("v.name"); 
        if (buttonAction=='Reject' ) {
            var inputCmp = component.find("customComment");
            var value = inputCmp.get("v.value");
            if(value==undefined || value=='' ){
                inputCmp.setCustomValidity("Rejection comment is reqired.");
                inputCmp.reportValidity();
            }else{
                var spinner = component.find('Id_spinner');
                $A.util.removeClass(spinner, "slds-hide"); 
                helper.approveOrRejectHelper(component, event, helper);
            }
        }else if (buttonAction=='Cancel' ) {
            var inputCmp = component.find("customComment");
            var value = inputCmp.get("v.value");
            if(value==undefined || value==''){
                inputCmp.setCustomValidity("Cancellation comment is reqired.");
                inputCmp.reportValidity();
            }else{
                var spinner = component.find('Id_spinner');
                $A.util.removeClass(spinner, "slds-hide"); 
                helper.approveOrRejectHelper(component, event, helper);
            }
        }else {
            var spinner = component.find('Id_spinner');
            $A.util.removeClass(spinner, "slds-hide"); 
            helper.approveOrRejectHelper(component, event, helper);
        }
    },
    
    editActivity: function(component, event, helper){
        
        component.set("v.campaignId",null); 
        component.set("v.activityId",null); 
        component.set("v.campaignActivityName",null); 
        var buttonAction = event.getSource().get("v.name");
        var idList = buttonAction.split('-$');
        var editForm = component.find("editForm");
        debugger;
        
        
        component.set("v.campaignId",idList[0]); 
        component.set("v.activityId",idList[1]); 
        component.set("v.campaignActivityName",idList[2]);        
        component.set("v.showActivityModal",true);
        component.set("v.campaignCurency",idList[3]);
        component.set("v.modalHeading","New Campaign Activity"); 
    },
    
    saveAllRecords: function(component, event, helper){ 
        var button = event.getSource();
        button.set('v.disabled',true);
        var spinner = component.find('Id_spinner');
        $A.util.removeClass(spinner, "slds-hide"); 
        if($A.util.isUndefinedOrNull(component.get("v.currentUser").ContactId)){
            helper.saveAllHelper(component, event, helper);
        }else{
            helper.saveActivitiesHelper(component, event, helper);
        }
        
    },
    
    reset: function(component, event, helper){
        component.set("v.showconfirmModal",true);
        component.set("v.modalHeading","Reset Confirmation"); 
        
    },
    
    proceedToReset : function(component, event, helper){        
        $A.get('e.force:refreshView').fire();
    },
    
})