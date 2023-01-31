({
	doInIt : function(component, event, helper) { 
        helper.getViewData(component,event);
    },
    
    clear : function(component, event, helper) { 
        $A.get('e.force:refreshView').fire();
    },
    
    Search : function(component, event, helper) { 
        helper.getFilteredData(component,event);
    }
})