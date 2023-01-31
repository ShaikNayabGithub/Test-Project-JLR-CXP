({
     navToRecord : function (component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
       
         navEvt.setParams({
             "recordId": component.get("v.activity.Id")
        });
            navEvt.fire();
    },
     handleSaveSuccess : function(component, event) {
       component.set("v.saveState", "SAVED");
       // var toastEvent = $A.get("e.force:showToast");
       // var title = $A.get("$Label.c.LC_COOP_Success");
      //    var message = $A.get("$Label.c.LC_COOP_The_Record_Has_Been_Updated_Successfully");
      //   toastEvent.setParams({
     //       "title": title,
    //        "message": message
     //   });
     //   toastEvent.fire();
    }
})