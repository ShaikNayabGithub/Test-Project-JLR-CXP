({
    handleUploadFinished: function (component, event) {
        // This will contain the List of File uploaded data and status
        var uploadedFiles = event.getParam("files");
        alert("Files uploaded : " + uploadedFiles.length);
    },
    

    loadCampaignActivitiesEvidence: function (component, event) {
        
        var action = component.get("c.getCampaignActivities");
        var recordIdParam = component.get("v.CommunityRecordId"); 
        var createdRecord = event.getParam("newRecordId");
        var recordName = event.getParam("newRecordName");
        if(recordIdParam == null) {
             recordIdParam = component.get("v.recordId");
        }
        action.setParams({campaignId: recordIdParam});
        action.setCallback(this, function(response){
           var state = response.getState();
            if(state === "SUCCESS"){
                component.set("v.activities", response.getReturnValue());
                debugger;
                if(createdRecord !=null)
                    component.set("v.selectedEvidenceId",createdRecord);
                if(recordName !=null)
                    component.set("v.selectedEvidenceName",recordName);
            }
        });
        $A.enqueueAction(action);
    },
    
    handleSubmit : function(component, event, helper) {
        component.find("edit").get("e.recordSave").fire();
    },
    
    handleSaveSuccess : function(component, event) {
        component.set("v.saveState", "SAVED");
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "The record has been updated successfully."
        });
        toastEvent.fire();
    },
      
   
    onChangeSetValue :function(component, event) {
        component.set("v.showNew",false);
        console.log(component.get("v.selectedEvidenceId"));
        var selectedId=component.get("v.selectedEvidenceId");
        if(selectedId !='none'){
        var actvyEvidence= component.get("v.activities");
            for(var i=0; i<actvyEvidence.length; i++)
            {
                if(actvyEvidence[i].Id==selectedId)
                {
                    component.set("v.selectedEvidenceName",actvyEvidence[i].Name);
                }
            }
        }
        component.set("v.showNew",true);
    },
    
    submitForApproval : function(component, event) {
    }
})