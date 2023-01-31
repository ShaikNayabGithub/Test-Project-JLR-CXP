({
     initialiseSearch : function(component) {
        var action = component.get("c.initAssets");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                var result = response.getReturnValue();
                console.log('MainResult:' + result);
                component.set("v.assetList" , result.assets);
                console.log('assests=:' + JSON.stringify(result));
                component.set("v.userperset", result.perset);
                console.log('userperset=:' + result.perset);
                var permset = component.get("v.userperset");
                component.set("v.showSpinner", false);
            }else if(state === 'ERROR'){
				component.set("v.showSpinner", false);
				var toastEvent = $A.get("e.force:showToast");
                var errormess = 'An Error occured during search of assets, please try refreshing. Error Message: '+response.getError()[0].message;
                toastEvent.setParams({"title":"Error", "type":"error", "message":errormess});
                toastEvent.fire();
            }else
				component.set("v.showSpinner", false);
        });
        $A.enqueueAction(action);
    },
    quatosValidationHelper : function(component,event) {        
        var buttonName = event.getSource().get("v.name");  
        var action = component.get("c.getAvailableQuota");
        action.setParams({assetOppTypeKey: buttonName});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                var TQInfo = response.getReturnValue();
                console.log(TQInfo);
                if(TQInfo.rdaType.toLowerCase() == 'Dealer_Owned'.toLowerCase() ){
                    if(Number(TQInfo.maxLimit) <=  Number(TQInfo.reachedLimit)){
                        component.set("v.popupMessage", $A.get("$Label.c.Max_Quota_Reached_Message"));
                        component.set("v.showModal",true);
                    } else if(TQInfo.typeOfSale.toLowerCase() == 'Demonstrator'.toLowerCase() && Number(TQInfo.demoQuotaLimit) >= Number(0)){                        
                        component.set("v.showModal",true);
                        component.set("v.popupMessage", $A.get("$Label.c.Demo_Quarter_Quota_Reached_Message"));
                        component.set("v.isLimitExceeded", true);
                    }else if(TQInfo.typeOfSale.toLowerCase() == 'Dealer Loan'.toLowerCase() && Number(TQInfo.loanQuotaLimit) >= Number(0)){                        
                        component.set("v.showModal",true);
                        component.set("v.popupMessage", $A.get("$Label.c.Loan_Quarter_Quota_Reached_Message"));
                        component.set("v.isLimitExceeded", true);
                    }else {
                        this.newRDAHelper(component, event, buttonName);
                    }
                }else {
                    this.newRDAHelper(component, event, buttonName );
                }
            }
        });
        $A.enqueueAction(action);
    },
 newRDAHelper : function(component, event, buttonName) {
        component.set("v.buttonInfo",'')
         component.set("v.userperset1",'')
        var action = component.get("c.createRDA");
               action.setParams({assetOppTypeKey: buttonName});
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('Action');
            if(state === 'SUCCESS'){
                var rda = response.getReturnValue();
                console.log('rda:' + rda);
                var createRDAEvent = $A.get("e.force:createRecord");
                createRDAEvent.setParams({
                    "entityApiName": "RDA__c",
                    "recordTypeId": rda.RecordTypeId,
                    "defaultFieldValues": {'Opportunity__c':rda.Opportunity__c, 'Account__c':rda.Account__c, 'Asset__c':rda.Asset__c, 'Product__c':rda.Product__c, 'Common_Type_of_Sale_Code__c':rda.Common_Type_of_Sale_Code__c, 'Handover_Date__c':rda.Handover_Date__c, 'Asset_VIN__c':rda.Asset_VIN__c,'Is_Fleet_Management_Organisation__c':rda.Is_Fleet_Management_Organisation__c}
                });
                //createRDAEvent.fire();
                component.set('v.defaultrda', rda);
                component.set('v.showRDAModal', true);
                component.set('v.userperset1', component.get("v.userperset"));
                
            }
            else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({"title":"Error", "type":"error", "message":"Could not create RDA"});
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },

})