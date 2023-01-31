({
    createProduct : function(component, event, helper) {
        var passedOppId = component.get('v.recordId');
        if(passedOppId == null || passedOppId == ''){
            passedOppId = component.get('v.communityRecordId');
        }
        var passedAssetId = component.get('v.assetId')[0];
        if(passedAssetId == null){
            alert('You must select a valid Asset record');
        }
        else{            
        	var action = component.get("c.insertOppLineItem");
            action.setParams({opportunityId : passedOppId, assetId : passedAssetId});
	        action.setCallback(this, function(response) {
    	        var state = response.getState();
                if(state === 'SUCCESS' && response.getReturnValue() == true){
                    helper.handleSuccess();
                    $A.get('e.force:refreshView').fire();
                }
                else{
                    helper.handleError();
                }
			});
            $A.enqueueAction(action);
        }
    }
})