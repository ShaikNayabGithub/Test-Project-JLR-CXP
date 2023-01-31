({
	getRecordshelper : function(component, event, helper) {
		var getPageRecordList = component.get("c.getNewPageAUSRecordList");
        //daysInPast
         getPageRecordList.setParams({"daysInPast": component.get('v.showOppsXDaysOld')});
        getPageRecordList.setCallback(this, function(returnWrapper) {
            var assetstate = returnWrapper.getState();
            if(assetstate === 'SUCCESS'){
                var returnValue = returnWrapper.getReturnValue();
                console.log(returnValue.resultOpportunityList.length);
                if(returnValue.resultOpportunityList.length > 0 ) component.set("v.opportunityList" , returnValue.resultOpportunityList);                     
                if(returnValue.resultFollowUpTaskList.length > 0 ) component.set("v.followUpTaskList" , returnValue.resultFollowUpTaskList);  
                if(returnValue.resultOverdueTaskList.length > 0 ) component.set("v.overdueTaskList" , returnValue.resultOverdueTaskList);              
            	component.set("v.isAustralian" , returnValue.resultIsAustralian); 
            }
        });
        $A.enqueueAction(getPageRecordList);
	},
    getSalesManager : function(component, event, helper) {
		var getMgr = component.get("c.getIsSalesManager");
		getMgr.setCallback(this, function(returnWrapper) {
            var mgrstate = returnWrapper.getState();
            if(mgrstate === 'SUCCESS'){
            	component.set('v.isSalesManager', returnWrapper.getReturnValue());
            }
            else{
                component.set('v.isSalesManager', false);
            }
        });
        $A.enqueueAction(getMgr);
    }
})