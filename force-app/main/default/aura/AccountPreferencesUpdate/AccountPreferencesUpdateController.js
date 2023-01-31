({
    
    doInit: function(component, event, helper) {
        // $A.get('e.force:refreshView').fire();
        helper.getcurrentAccount(component, event, helper);
        helper.getcurrentAccountAccess(component, event, helper);
        helper.getAccountLabels(component, event, helper); 
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
        helper.saveCurrentAccount(component, event, helper);
    },
    allCommOptOut: function(component, event, helper) { 
        helper.allCommOptOut(component, event, helper, component.get("v.currentAccount"));   
    },
    oneCommOptIn: function(component, event, helper) { 
        if(event.getSource().get("v.checked")){
            helper.channelOptOut(component, event, helper, component.get("v.currentAccount"));
         }else{
        helper.oneCommOptIn(component, event, helper, component.get("v.currentAccount"));
         }
    },
    mainOptOut: function(component, event, helper) { 
        helper.mainOptOutHelper(component, event, helper,component.get("v.currentAccount"));
    },
    
    allTopsOptOut: function(component, event, helper) { 
        helper.allTopsOptOut(component, event, helper,component.get("v.currentAccount"));
    },
    LRTopicsOptout: function(component, event, helper) { 
        if(event.getSource().get("v.checked")){
            helper.LRAllTopisOptOut(component, event, helper,component.get("v.currentAccount"));
        }else{           
            helper.JLRTopsOptIn(component, event, helper,component.get("v.currentAccount")); 
        }
    },
    JTopicsOptout: function(component, event, helper) { 
        if(event.getSource().get("v.checked")){
            helper.JAllTopisOptOut(component, event, helper,component.get("v.currentAccount"));
        }else{           
            helper.JLRTopsOptIn(component, event, helper,component.get("v.currentAccount")); 
        }
    },
    LReventExperiencesOptOut : function(component, event, helper) { 
         if(event.getSource().get("v.checked")){
        helper.LReventExperiencesOptOut(component, event, helper,component.get("v.currentAccount"));
        }else{           
            helper.LRAllTopisOptIn(component, event, helper,component.get("v.currentAccount")); 
        }
    },
    JeventExperiencesOptOut : function(component, event, helper) { 
         if(event.getSource().get("v.checked")){
        helper.JeventExperiencesOptOut(component, event, helper,component.get("v.currentAccount"));
        }else{           
            helper.JAllTopisOptIn(component, event, helper,component.get("v.currentAccount")); 
        }
    },
     LReventExperiencesOptIn : function(component, event, helper) { 
         if(!event.getSource().get("v.checked")){
       	 helper.LReventExperiencesOptIn(component, event, helper,component.get("v.currentAccount"));
        }
    },
    JeventExperiencesOptIn : function(component, event, helper) { 
         if(!event.getSource().get("v.checked")){
        helper.JeventExperiencesOptIn(component, event, helper,component.get("v.currentAccount"));
        }
    },
})