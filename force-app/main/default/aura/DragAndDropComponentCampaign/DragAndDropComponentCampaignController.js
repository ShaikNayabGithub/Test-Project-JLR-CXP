({
    handleUploadFinished: function (component, event) {
        // This will contain the List of File uploaded data and status
        var uploadedFiles = event.getParam("files");
        alert(label.c.LC_COOP_Files_Uploaded + uploadedFiles.length);
    },

    loadCampaignActivities: function (component) {
        var action = component.get("c.getCampaignActivities");
        var recordIdParam = component.get("v.CommunityRecordId");     
        if(recordIdParam == null) {
             recordIdParam = component.get("v.recordId");
        }
        action.setParams({campaignId: recordIdParam});
        action.setCallback(this, function(response){
           var state = response.getState();
            if(state === "SUCCESS"){
                component.set("v.activities", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    
    handleSubmit : function(component, event, helper) {
        component.find("edit").get("e.recordSave").fire();
    },    
  
    
    forceNavigate : function(component, event) {
    	var createRecordEvent = $A.get("e.force:createRecord");
        var recordIdParam = component.get("v.recordId");
        var campaignRecord;
        if(recordIdParam != null){
            campaignRecord = component.get("v.campaignRecord");
        }
        else{
            recordIdParam = component.get("v.CommunityRecordId");
            if(recordIdParam != null){
                campaignRecord = component.get("v.communityRecord");
            }
        }
        createRecordEvent.setParams({ "entityApiName": "CooP_Campaign_Activity__c", "defaultFieldValues":{"Campaign__c":recordIdParam, "Start_Date__c":campaignRecord.StartDate, "End_Date__c":campaignRecord.EndDate}});
		createRecordEvent.fire();
     },
    
    submitForApproval : function(component, event) {
    }
})