({
    closeMe: function(component, event, helper) {
         helper.closeMe(component, event, helper);
    },
    
     doInit: function(component, event, helper) {
         
        //get record type Id
        var recordTypeId = component.get("v.pageReference").state.recordTypeId;
        component.set("v.recordTypeId",recordTypeId);
      
         
        //get action name edit/new
        var actionName = component.get("v.pageReference").attributes.actionName;
        console.log('actionName-' + actionName);
         
        //get object API name
        var objectApiName = component.get("v.pageReference").attributes.objectApiName;
        console.log('objectApiName-' + objectApiName);
         helper.getDynamicRecordTypeIdHelper(component, event, helper,objectApiName);
    },
})