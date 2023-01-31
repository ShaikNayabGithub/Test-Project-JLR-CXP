({
    closeMe : function(component, event, helper) {
        component.destroy(); 
    },

    reviseScheme : function(component, event, helper) {
        if(component.get("v.baseScheme")==false){
         var compEvent = component.getEvent("reviseBtnEvt");
    compEvent.setParams({
      "CompId" : null,
      "VMEParameter" :component.get("v.VMEParameter"),
      "recordDetails" : component.get("v.recordDetails"),
      "revisedScheme" :  component.get("v.revisedScheme"),
      "newSchemeId" :  component.get("v.newSchemeId")
        });
        compEvent.fire();
        component.set("v.isOpen",false);
    }

    if(component.get("v.baseScheme")==true){
        var cmpEvent = component.getEvent("SplitSchemeEvt"); 
        cmpEvent.setParams({
        "openModel" : true,
        "endedSchemeData" : component.get("v.revisedScheme"),
        "VMECampParent"   : component.get("v.recordDetails")
       });
    
            cmpEvent.fire(); 
          component.set("v.isOpen",false);
    }
    },

})