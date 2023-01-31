({
     doInit : function (component, event, helper) {
         if(!$A.util.isUndefinedOrNull(component.get("v.recordId"))){
             debugger;
              var activityName = component.get("v.campaignActivityName");
             var nameList = activityName.split("-");             
             component.set("v.namePortion",nameList[(nameList.length)-1]);
             nameList.pop();
             component.set("v.activityType",nameList[(nameList.length)-1]);
             nameList.pop();
             component.set("v.campaignName",nameList.join("-"));
         }
    },
    
    showSpinner:  function(component, event) {
         var spinner = component.find('Id_spinner');
           $A.util.removeClass(spinner, "slds-hide");
    },
    hideSpinner :  function(component, event) {
         var spinner = component.find('Id_spinner');
           $A.util.addClass(spinner, "slds-hide");
    },
     handleSaveSuccess : function(component, event) {
         var toastEvent = $A.get("e.force:showToast");
         var title = $A.get("$Label.c.LC_COOP_Success");
         var message ='';
         if(!$A.util.isUndefinedOrNull(component.get("v.recordId"))){
            message = $A.get("$Label.c.LC_COOP_The_Record_Has_Been_Updated_Successfully");
     	}else{
   			message = "New Activity is created.";
		}
         toastEvent.setParams({
             "title": title,
             "type" : 'success',
             "message": message
         });
         toastEvent.fire();
         //$A.get('e.force:refreshView').fire();
        var PassSelectedValueEvent = $A.get("e.c:PassSelectedValue");
        PassSelectedValueEvent.setParams({"selectedValue": '--None--'});
        PassSelectedValueEvent.fire();
    },
    setActivityName: function(component, event, helper) {
        debugger;
        var name = component.get("v.campaignName")+'-'+component.get("v.activityType")+'-'+component.get("v.namePortion");
        component.find("activityName").set("v.value",name);
        debugger;
    }
})