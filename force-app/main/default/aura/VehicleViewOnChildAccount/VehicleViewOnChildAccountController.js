({
	 doInit : function(component, event, helper) {
		helper.getAssetRoles(component, event, helper);
		helper.getUserAccountId(component, event, helper);
        helper.getAssetRoleRecordTypes(component, event, helper);
	},
    closeModal:function(component,event,helper){    
        component.set("v.showModal",false);               
        component.set("v.isOwnerChange",false);
         component.set("v.modalHeading",'');        
        helper.getAssetRoles(component, event, helper);
		helper.getUserAccountId(component, event, helper);
    },
    showSpinner : function (component, event, helper) {      
         component.set("v.showSpinner",true);   
    },
    hideSpinner : function (component, event, helper) {      
         component.set("v.showSpinner",false);   
    },
     hideButton : function (component, event, helper) {      
        console.log('test for button');
    },
    handleSelect : function (component, event, helper) {  
        var selectedMenuItemValue = event.getParam("value").split(" ");
        console.log('Selected Value'+selectedMenuItemValue[0]);
        if(selectedMenuItemValue[0] == 'EditOwner'){
            helper.changeOwner(component, event, helper, selectedMenuItemValue[1]);
        }else if(selectedMenuItemValue[0] == 'EditVehicle'){            
            helper.vehicleUpdate(component, event, helper, selectedMenuItemValue[1]);
        }else if(selectedMenuItemValue[0] == 'EditAsset'){            
            helper.vehicleNavigate(component, event, helper, selectedMenuItemValue[1]);
        }
        
    },
    newAssetRole : function (component, event, helper) {  
    /*  var createRecordEvent = $A.get("e.force:createRecord");
    createRecordEvent.setParams({
        "entityApiName": "Role__c"
    });
    createRecordEvent.fire(); */
          
        component.set("v.showModal",true); 
        component.set("v.updatingAsset",'creatingRole'); 
    },
    openNewRoleRecord : function (component, event, helper) { 
        let currentUrl = decodeURIComponent(window.location.search.substring(1));        
        var recordtypeId= component.get("v.selectedValue");
        var recordId = ''+component.get("v.recordId");
        console.log(recordId);
         var action = component.get('c.closeModal');
         $A.enqueueAction(action);
       
     var createRecordEvent = $A.get("e.force:createRecord");
    createRecordEvent.setParams({
        "entityApiName": "Role__c",
        "recordTypeId" : recordtypeId, 
        "defaultFieldValues": {
            "Account__c" : recordId
        },
        "panelOnDestroyCallback": function(event) {
           // window.location.hash = windowHash;
            var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": component.get("v.recordId")
                });
             decodeURIComponent(window.location.search.substring(1)) == currentUrl ? navEvt.fire() : console.log('nav to account');
           
        }
    });
    createRecordEvent.fire(); 
          
    },
    
})