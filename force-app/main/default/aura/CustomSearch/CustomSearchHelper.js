({   
    getModelList : function(component, event, helper) {
        var action = component.get("c.searchModelList");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){ 
                component.set("v.modalList" , response.getReturnValue());
                console.log('test');
                console.log(component.get("v.modalList"));
            }            
        }); 
        $A.enqueueAction(action);
        
    },
    getPriceBookListHelper : function(component, event, helper) {
        var action = component.get("c.getPriceBookList");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){  
                console.log(response.getReturnValue());
                component.set("v.priceBookList" , response.getReturnValue());                
                if( response.getReturnValue().length > 0) component.set("v.selectedPriceBook" , response.getReturnValue()[0].value); 
                else  if( response.getReturnValue().length == 0) component.set("v.selectedPriceBook" , response.getReturnValue().value); 
                console.log(component.get("v.selectedPriceBook"));
            }            
        }); 
        $A.enqueueAction(action);
        
    },
    getPurchaseTypeValues : function(component, event, helper) {
        var action = component.get("c.getPurchaseTypePickListValues");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){ 
                component.set("v.purchaseTypepickListValues" , response.getReturnValue());
                component.set("v.purchaseType" , 'New Vehicle');
            }            
        }); 
        $A.enqueueAction(action);
        
    },
    
    getLanguageValuesHelper : function(component, event, helper) {
        var action = component.get("c.getLanguagePickListValues");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){ 
                component.set("v.languageList" , response.getReturnValue());
                component.set("v.language" , 'English (UK)');
            }            
        }); 
        $A.enqueueAction(action);
        
    },
    
    
    getStageTypeValues : function(component, event, helper) {
        var action = component.get("c.getStageTypePickListValues");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){ 
                component.set("v.stageTypepickListValues" , response.getReturnValue());                
                component.set("v.nextAction",response.getReturnValue()[0].value);
            }            
        }); 
        $A.enqueueAction(action);
        
    },
    getRecordTypesHelper : function(component, event, helper) {
        var action = component.get("c.getRecordTypeList");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){ 
                component.set("v.getRecordTypeList" , response.getReturnValue());                
                component.set("v.accountType",response.getReturnValue()[0].value);
                console.log(response.getReturnValue());
                console.log(response.getReturnValue()[0].value);
            }            
        }); 
        $A.enqueueAction(action);
    },
    
    getAccountList : function(component, event, helper) {
        
        component.set("v.AccountList",null );
        component.set("v.contactList",null ); 
        component.set("v.assestList",null );
        console.log(component.get("v.chosenOption"));
        var action = component.get('c.searchForAccounts');
        action.setParams({searchText: component.get("v.searchText"), searchType: component.get("v.chosenOption")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                if(response.getReturnValue().resultAccountList.length > 0) component.set("v.AccountList",response.getReturnValue().resultAccountList );
                if(response.getReturnValue().resultContactList.length > 0) component.set("v.contactList",response.getReturnValue().resultContactList );
                if(response.getReturnValue().resultAssetList.length > 0) component.set("v.assestList",response.getReturnValue().resultAssetList );
            }
        }); 
        $A.enqueueAction(action);
    },
    getNavigateId : function(component, event, helper) {
        var selected = event.currentTarget.id;
        var action = component.get('c.getNavigationId');
        action.setParams({accountId: selected});
        action.setCallback(this, function(response) {
            var state = response.getState();            
            if (state === 'SUCCESS') {
                var getNavigationId = response.getReturnValue();
                if(getNavigationId != 'null'){
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": getNavigationId
                    });
                    navEvt.fire();
                }else{
                    component.set("v.selectedAccountId",selected);
                    component.set("v.AccountList",null );
                    component.set("v.contactList",null );  
                    component.set("v.assestList",null );  
                    component.set("v.selectedModal",'none');
                    component.set("v.nextAction",'none');
                    var todayDate = new Date();        
                    todayDate.setMinutes(todayDate.getMinutes()+10);
                    var newOpportunity = component.get("v.newOpportunity");
                    newOpportunity.Test_Drive_Preferred_Date_Time__c = todayDate.toISOString();
                    component.set("v.newOpportunity",newOpportunity);
                    var newButton = component.find('opportunityDiv');
                    $A.util.removeClass(newButton, "slds-hide");       
                    var newButton = component.find('createButton');
                    $A.util.addClass(newButton, "slds-hide");                    
                    var accountDiv = component.find('accountDiv');
                    $A.util.addClass(accountDiv, "slds-hide");
                }
            }
        });
        $A.enqueueAction(action);
    },
    savenewOpportunity : function(component, event, helper) {
        var preferredDate ;
        if(component.get("v.nextAction") == 'Test Drive Taken/Booked'){ 
            preferredDate = component.get("v.newOpportunity").Test_Drive_Preferred_Date_Time__c;
        } else{
            preferredDate =null;
        }
        
        var action = component.get('c.saveOpportunity');
        action.setParams({newAccountId: component.get("v.selectedAccountId"),
                          OpportunityStage : component.get("v.nextAction"),
                          preferreddate : preferredDate,
                          model: component.get("v.selectedModal"),
                          priceBookName: component.get("v.selectedPriceBook"),
                          PurchaseType: component.get("v.purchaseType") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            if (state === 'SUCCESS') {
                var Opportunity = response.getReturnValue();
                component.set("v.opportunityId",Opportunity.Id);
                if(component.get("v.nextAction") != 'Vehicle Selection'){
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": Opportunity.Id
                    });
                    navEvt.fire();
                }else{
                    component.set("v.isAssestSelectionEnabled" , true);                   
                }
            }else{
                console.log('not created Opportunity');
            } 
            
        });
        $A.enqueueAction(action);
    },
    createNewAccount : function(component, event, helper) {
        console.log(component.get("v.nextAction"));
        var preferredDate ;
        if(component.get("v.nextAction") == 'Test Drive Taken/Booked'){ 
            preferredDate = component.get("v.newOpportunity").Test_Drive_Preferred_Date_Time__c;
        } else{
            preferredDate =null;
        }
        
        var button = event.getSource();
        var action = component.get('c.saveAccount');
        action.setParams({newAccount: component.get("v.newAccount"),
                          corporateAccount :component.get("v.corporateAccount"),
                          OpportunityStage : component.get("v.nextAction"),
                          preferreddate : preferredDate,
                          model: component.get("v.selectedModal"),
                          priceBookName: component.get("v.selectedPriceBook"),
                          PurchaseType: component.get("v.purchaseType"),
                          accountType: component.get("v.accountType"),
                          language: component.get("v.language")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('Error Not valid'+state);
            if (state === 'SUCCESS') {
                var duplicateAccountWrapper = response.getReturnValue();
                if(duplicateAccountWrapper.duplicateAccountList.length > 0){
                    component.set("v.duplicateAccountList",duplicateAccountWrapper.duplicateAccountList); 
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "info!",
                        "type":"error",
                        "message": "Duplicate(s) found"
                    });
                    toastEvent.fire();
                    button.set('v.disabled',false);
                } 
                if(duplicateAccountWrapper.resultString != ''){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "info!",
                        "type":"error",
                        "message": duplicateAccountWrapper.resultString
                    });
                    toastEvent.fire();
                    button.set('v.disabled',false);
                    
                }
                
            console.log('resultOpportunity'+duplicateAccountWrapper.resultOpportunity.Id); 
                if(duplicateAccountWrapper.resultOpportunity.Id != 'undefined' && duplicateAccountWrapper.resultOpportunity.Id != undefined) {
                    component.set("v.opportunityId	",duplicateAccountWrapper.resultOpportunity.Id);
                    if(component.get("v.nextAction") != 'Vehicle Selection'){
                        var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            "recordId": duplicateAccountWrapper.resultOpportunity.Id
                        });
                        navEvt.fire();
                    }else{
                        component.set("v.isAssestSelectionEnabled" , true);                   
                    }
                }
                
            }else{
                // let button = event.getSource();
                console.log('error');
                button.set('v.disabled',false);
            }
        });
        $A.enqueueAction(action);
    },
    getContactFieldLabelHelper : function(component, event, helper) {
        
        var searchAssetAction = component.get("c.getFieldLabel");
        
        searchAssetAction.setParams({objectName : 'Contact'});
        searchAssetAction.setCallback(this, function(assetFieldLabelMap) {
            var assetstate = assetFieldLabelMap.getState();
            console.log(assetstate);
            if(assetstate === 'SUCCESS'){
                console.log(assetFieldLabelMap.getReturnValue());
                component.set("v.contactLabelMap" , assetFieldLabelMap.getReturnValue());                
                
            }
            
        });
        $A.enqueueAction(searchAssetAction);
    },
    getAccountFieldLabelHelper : function(component, event, helper) {
        
        var searchAssetAction = component.get("c.getFieldLabel");
        
        searchAssetAction.setParams({objectName : 'Account'});
        searchAssetAction.setCallback(this, function(assetFieldLabelMap) {
            var assetstate = assetFieldLabelMap.getState();
            console.log(assetstate);
            if(assetstate === 'SUCCESS'){
                component.set("v.accountLabelMap" , assetFieldLabelMap.getReturnValue());                
                
            }
            
        });
        $A.enqueueAction(searchAssetAction);
    },
})