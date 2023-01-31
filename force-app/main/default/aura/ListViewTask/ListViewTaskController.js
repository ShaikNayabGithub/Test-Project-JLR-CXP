({
    doInit : function(component, event, helper) {
        var setup = component.get("c.getTasks");
  
        //string whereQuery, string limitNum
        setup.setParams({whereQuery : component.get('v.whereQueryProp'), limitNum : component.get('v.limitNumProp'), justMine : component.get('v.justMineProp')});
        
        //"title":"Success", "type":"success",
        // setup.setParams({approvalProcess : component.get('v.whereQueryProp')});
        setup.setCallback(this, function(listDetail) {
            if(listDetail.getState() === 'SUCCESS'){
                console.log(listDetail.getReturnValue());
                component.set('v.taskList', listDetail.getReturnValue()); 
                 component.set("v.spinner", false); 
            }
          
                   component.set("v.spinner", false); 
        });
        $A.enqueueAction(setup);
         
    },
    
})