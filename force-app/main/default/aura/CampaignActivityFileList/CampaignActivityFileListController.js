({
	initialisation: function (cmp, event, helper) {
        helper.loadCampaignActivityFiles(cmp);
    },
    
    handleUploadFinished: function (cmp, event, helper) {
        // This will contain the List of File uploaded data and status
        var uploadedFiles = event.getParam("files");
         var title = $A.get("$Label.c.LC_COOP_Success");
        var filesMessage = $A.get("$Label.c.LC_COOP_Files_Uploaded") + uploadedFiles.length ;
        
       // alert("Files uploaded : " + uploadedFiles.length);
         var toastEvent = $A.get("e.force:showToast");  
        
        toastEvent.setParams({
           "title": title,
            "message": filesMessage
        });
       toastEvent.fire();
        helper.loadCampaignActivityFiles(cmp);
        var danddevent = cmp.getEvent("activityDragAndDrop");
		danddevent.fire();
    }
})