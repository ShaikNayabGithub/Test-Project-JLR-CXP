({
    getFYdefaultvalues : function(component, event, helper) {
        var getFYDetails = component.get("c.getFYearDetails");
        getFYDetails.setCallback(this, function(getFYDetailsResponse){
            if(getFYDetailsResponse.getState() == 'SUCCESS'){       
                component.set("v.currentFYDetails", getFYDetailsResponse.getReturnValue());   
                var selectedYear = ''+getFYDetailsResponse.getReturnValue().financailYear;
                var selectedFYYear = ''+selectedYear.substring(2,4)+'-'+(''+(parseInt(selectedYear)+1)).substring(2,4);
                component.set("v.selectedYear", selectedFYYear);
                component.set("v.selectedQuarter", getFYDetailsResponse.getReturnValue().Quarter);
                this.getRetailerHelper(component,event,helper)
            }
        });
        $A.enqueueAction(getFYDetails); 
    },
    
    getUserDetailsHelper : function(component, event, helper) {
        var getUserDetails = component.get("c.getUserDetails");
        getUserDetails.setCallback(this, function(getUserDetailsResponse){
            if(getUserDetailsResponse.getState() == 'SUCCESS'){    
                component.set("v.currentUser", getUserDetailsResponse.getReturnValue());                    
            } 
            
        });
        $A.enqueueAction(getUserDetails); 
    },
    
    getModelListHelper : function(component,event,helper) {
        var getModelList = component.get("c.getModelList");
        getModelList.setCallback(this, function(getModelListResponse){
            if(getModelListResponse.getState() == 'SUCCESS'){ 
                component.set("v.modelMap", getModelListResponse.getReturnValue());
                component.set("v.modelList", getModelListResponse.getReturnValue()['Jaguar Land Rover']);
            }
        });
        $A.enqueueAction(getModelList); 
    },
    
    getCampaignsHelper: function(component,event,helper) {
        var searchCampaigns = component.get("c.searchCampaigns");      
        var selectedYear =component.get("v.selectedYear");
        var selectedFYYear = ''+selectedYear.substring(2,4)+'-'+(''+(parseInt(selectedYear)+1)).substring(2,4);
        
        searchCampaigns.setParams({ selectedFYYear : selectedYear,
                                   selectedQuarter : component.get("v.selectedQuarter"),
                                   selectedBrand : component.get("v.selectedBrand"),
                                   selectedModel : component.get("v.selectedModel"),
                                   selectedRetailer : component.get("v.selectedRetailer")}); 
        searchCampaigns.setCallback(this, function(searchCampaignsResponse){
            if(searchCampaignsResponse.getState() == 'SUCCESS'){ 
                debugger;
                component.set("v.Results", searchCampaignsResponse.getReturnValue());
            }
            
            var spinner = component.find('Id_spinner');
            $A.util.addClass(spinner, "slds-hide"); 
            
        });
        $A.enqueueAction(searchCampaigns); 
    },
    
    getRetailerHelper: function(component,event,helper) {
        var selectedYear =component.get("v.selectedYear");
        debugger;
        var getCampaignsDetails = component.get("c.getCampaignsDetails");      
        getCampaignsDetails.setParams({ currentFYYear : selectedYear,
                                       currentQuarter : component.get("v.selectedQuarter")}); 
        getCampaignsDetails.setCallback(this, function(getCampaignsDetails){            
            if(getCampaignsDetails.getState() == 'SUCCESS'){ 
                debugger;
                component.set("v.retailerList",getCampaignsDetails.getReturnValue());
                var slectedRetailer=component.get("v.selectedRetailer");
                var results=component.get("v.Results");
                if( (slectedRetailer ===null || slectedRetailer ==='' || slectedRetailer ===undefined ) && results !=null )
                    component.set("v.selectedRetailer",getCampaignsDetails.getReturnValue()[0]);
                
                this.getCampaignsHelper(component,event,helper);
            }
            
        });
        $A.enqueueAction(getCampaignsDetails); 
    },
    
    saveAllHelper: function(component,event,helper) {
        var saveCampaigns =component.get("c.saveCampaigns");
        saveCampaigns.setParams({ updateCampaignList : component.get("v.Results")}); 
        saveCampaigns.setCallback(this, function(saveCampaignsResponse){
            
            if(saveCampaignsResponse.getState() == 'SUCCESS'){ 
                this.showToast(saveCampaignsResponse.getReturnValue());
                helper.saveActivitiesHelper(component, event, helper);
            }
            
            var spinner = component.find('Id_spinner');
            $A.util.addClass(spinner, "slds-hide"); 
            
        });
        $A.enqueueAction(saveCampaigns); 
    },
    
    saveActivitiesHelper: function(component,event,helper) {
        var campaignList = component.get("v.Results");
        var activityList = component.get("v.activityList"); 
        activityList=[];
        var x;
        for (x in campaignList) {
            var y;
            for(y in campaignList[x]["Campaign_activities__r"]){                
                activityList.push(campaignList[x]["Campaign_activities__r"][y]);
            }
        }
        var button = event.getSource();
        button.set('v.disabled',false);
        var saveCampaignActivitys =component.get("c.saveCampaignActivitys");
        saveCampaignActivitys.setParams({ updateCampaignActivityList : activityList}); 
        saveCampaignActivitys.setCallback(this, function(saveCampaignActivitysResponse){
            
            if(saveCampaignActivitysResponse.getState() == 'SUCCESS'){ 
                
                this.showToast(saveCampaignActivitysResponse.getReturnValue());
                this.getCampaignsHelper(component,event,helper);
            }
            
            var spinner = component.find('Id_spinner');
            $A.util.addClass(spinner, "slds-hide"); 
            
        });
        $A.enqueueAction(saveCampaignActivitys); 
        
    },
    
    approveOrRejectHelper: function(component,event,helper) {
        var selectedYear =component.get("v.selectedYear");
        var getApprovalMethod = component.get("c.approveOrReject");      
        getApprovalMethod.setParams({campaignId : component.get("v.campaignId"),
                                     campaignActID:component.get("v.activityId"),
                                     strComment : component.get("v.campaignComments"),
                                     strAction  : event.getSource().get("v.name")}); 
        getApprovalMethod.setCallback(this, function(getApprovalMethod){            
            if(getApprovalMethod.getState() == 'SUCCESS'){ 
                debugger;
                component.set("v.showApprovalModal", false);
                component.set("v.showCancelModal", false);
                component.set("v.showSubmitModal", false);
                component.set("v.campaignComments", '');
                this.getCampaignsHelper(component,event,helper);
                debugger;
                this.showToast(getApprovalMethod.getReturnValue());
            }
            
            var spinner = component.find('Id_spinner');
            $A.util.addClass(spinner, "slds-hide"); 
            
        });
        $A.enqueueAction(getApprovalMethod); 
    },
    
    saveCommentsHelper: function(component,event,helper) {
        
        var saveCampaignComments =component.get("c.saveCampaignComments");
        saveCampaignComments.setParams({ campaignId : component.get("v.campaignId"),
                                        comments :  component.get("v.campaignComments")}); 
        saveCampaignComments.setCallback(this, function(saveCampaignCommentsResponse){
            
            if(saveCampaignCommentsResponse.getState() == 'SUCCESS'){
                
                component.set("v.showApprovalModal", false);
                component.set("v.showCancelModal", false);
                component.set("v.showSubmitModal", false);
                component.set("v.showCommentModal", false);
                component.set("v.campaignComments", '');
                
                this.showToast(saveCampaignCommentsResponse.getReturnValue());     
            }
            
            var spinner = component.find('Id_spinner');
            $A.util.addClass(spinner, "slds-hide"); 
            
        });
        $A.enqueueAction(saveCampaignComments);         
    },   
    
    
    showToast : function(retunrMsg) {
        var msgLst = retunrMsg.split('-$-');
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": msgLst[0],
            "message": msgLst[1],
            "type":msgLst[0]
        });
        toastEvent.fire();
    }
    
})