({
    getAssetRoles : function(component, event, helper) {
        var action = component.get('c.getAllAccountAssetRoles');
        action.setParams({  accountId : component.get("v.recordId")  });
        action.setCallback(component, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS'){
                 component.set("v.assetRoleList",response.getReturnValue().accountAssetRolesList);
                component.set("v.accountRecordType",response.getReturnValue().recordTypeName);
            } 
        });
        $A.enqueueAction(action);
    },
    getUserAccountId : function(component, event, helper) {
        var action = component.get('c.getLoggedInUserAccountId');
        action.setCallback(component, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS'){
                component.set("v.loggedInUserAccountId",response.getReturnValue());
               console.log( component.get("v.loggedInUserAccountId"));
            } 
        });
        $A.enqueueAction(action);
    },
    changeOwner : function(component, event, helper, vehicleId) {
        console.log('Id'+ vehicleId);        
               console.log( component.get("v.loggedInUserAccountId"));
        if(component.get("v.loggedInUserAccountId") != 'Not Community User'){      
        component.set("v.updatingFieldValue",component.get("v.loggedInUserAccountId"));
        }
        component.set("v.showModal",true);   
        component.set("v.updatingAsset",'updatingAsset'); 
        component.set("v.modalHeading",'Change Owner');
        component.set("v.updatingRecordId",vehicleId);
        component.set("v.updatingObject",'Asset');
        component.set("v.updatingField",'AccountId'); 
        
	},
     vehicleUpdate : function(component, event, helper, vehicleId) {        
        console.log('Id'+ vehicleId);
        component.set("v.showModal",true);  
        component.set("v.updatingAsset",'updatingAsset');               
        component.set("v.isOwnerChange",false);
         component.set("v.modalHeading",'Update vehicle Mileage');         
        component.set("v.updatingRecordId",vehicleId);
        component.set("v.updatingObject",'Asset');
        component.set("v.updatingField",'Mileage__c');
	},
    
    getAssetRoleRecordTypes : function(component, event, helper) { 
          var action = component.get('c.getRoleRecordTypeList');
        action.setCallback(component, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS'){
                component.set("v.recordTypeList",response.getReturnValue());
                console.log(response.getReturnValue());
            } 
        });
        $A.enqueueAction(action);
	},
     vehicleNavigate : function(component, event, helper, vehicleId) {  
           var action = component.get('c.changeAssetOwner');         
        action.setParams({  assetId : vehicleId  });
        action.setCallback(component, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS'){
               var assetId = response.getReturnValue();
                if(assetId != 'NotEditable'){
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": assetId
                    });
                    navEvt.fire();
                } else {
                     var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "error!",
                        "type":"error",
                        "message": "Insufficient access rights"
                    });
                    toastEvent.fire();
                } 
            }
        });
        $A.enqueueAction(action);
	},
    
})