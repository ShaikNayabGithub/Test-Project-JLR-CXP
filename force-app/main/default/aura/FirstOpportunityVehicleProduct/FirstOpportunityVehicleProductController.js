({
	doInit : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        if(recordId == null || recordId == ''){
            recordId = component.get("v.communityRecordId");
        }
        if(recordId != null && recordId != ''){
            var action = component.get("c.getOpportunityProducts");
            action.setParams({oppId : recordId});
            action.setCallback(this, function(response) {
               var state = response.getState();
                if(state === "SUCCESS") {
                    var productArray = action.getReturnValue();
                    var productSize = 0;
                    if(productArray != null){
                        productSize = productArray.length;
                    }
                    component.set("v.numberProducts", productSize);
                    if(productSize == 1){
                        component.set("v.oppProduct", productArray[0]);
                    }
                    else{
                        component.set("v.oppProduct", null);
                    }
                }
            });
            $A.enqueueAction(action);
        }
    }
})