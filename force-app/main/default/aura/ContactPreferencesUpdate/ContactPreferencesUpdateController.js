({
    
    doInit: function(component, event, helper) {
        // $A.get('e.force:refreshView').fire();
        helper.getcurrentContact(component, event, helper);
        helper.getcurrentContactAccess(component, event, helper);
        helper.getContactLabels(component, event, helper); 
        //component.find("recordHandler").reloadRecord();
    }, 
    showSpinner : function (component, event, helper) {      
        component.set("v.showSpinner",true);   
    },
    hideSpinner : function (component, event, helper) {      
        component.set("v.showSpinner",false);   
    },
    handleSaveRecord : function(component, event, helper) {
        let button = event.getSource();
        button.set('v.disabled',true);
        helper.saveCurrentContact(component, event, helper);
    },
    allCommOptOut: function(component, event, helper) { 
        helper.allCommOptOut(component, event, helper, component.get("v.currentContact"));   
    },
    oneCommOptIn: function(component, event, helper) { 
        if(event.getSource().get("v.checked")){
            helper.channelOptOut(component, event, helper, component.get("v.currentContact"));
        }else{
            helper.oneCommOptIn(component, event, helper, component.get("v.currentContact"));
        }
    },
    
    allTopsOptOut: function(component, event, helper) { 
        helper.allTopsOptOut(component, event, helper,component.get("v.currentContact"));
    },
    LRTopicsOptout: function(component, event, helper) { 
        if(event.getSource().get("v.checked")){
            helper.LRAllTopisOptOut(component, event, helper,component.get("v.currentContact"));
        }else{           
            helper.JLRTopsOptIn(component, event, helper,component.get("v.currentContact")); 
        }
    },
    JTopicsOptout: function(component, event, helper) { 
        if(event.getSource().get("v.checked")){
            helper.JAllTopisOptOut(component, event, helper,component.get("v.currentContact"));
        }else{           
            helper.JLRTopsOptIn(component, event, helper,component.get("v.currentContact")); 
        }
    },
    LReventExperiencesOptOut : function(component, event, helper) { 
        if(event.getSource().get("v.checked")){
            helper.LReventExperiencesOptOut(component, event, helper,component.get("v.currentContact"));
        }else{           
            helper.LRAllTopisOptIn(component, event, helper,component.get("v.currentContact")); 
        }Contact
    },
    JeventExperiencesOptOut : function(component, event, helper) { 
        if(event.getSource().get("v.checked")){
            helper.JeventExperiencesOptOut(component, event, helper,component.get("v.currentContact"));
        }else{           
            helper.JAllTopisOptIn(component, event, helper,component.get("v.currentContact")); 
        }
    },
    LReventExperiencesOptIn : function(component, event, helper) { 
        if(!event.getSource().get("v.checked")){
            helper.LReventExperiencesOptIn(component, event, helper,component.get("v.currentContact"));
        }
    },
    JeventExperiencesOptIn : function(component, event, helper) { 
        if(!event.getSource().get("v.checked")){
            helper.JeventExperiencesOptIn(component, event, helper,component.get("v.currentContact"));
        }
    },
})