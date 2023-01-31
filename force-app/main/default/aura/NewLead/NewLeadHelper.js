({   
    getSalutationPicklistValues : function(component, event, helper) {
        var action = component.get("c.getPicklistValues");
        action.setParams({
            "field": 'Salutation',           
        });       
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){ 
                component.set("v.salutationPicklistValues" , response.getReturnValue());
            }            
        }); 
        $A.enqueueAction(action);
        
    },
    
    getEnquiryTypePicklistValues : function(component, event, helper) {
        var action = component.get("c.getPicklistValues");
        action.setParams({
            "field": 'Enquiry_Type__c',           
        });       
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){ 
                component.set("v.enquiryTypePicklistValues" , response.getReturnValue());
            }            
        }); 
        $A.enqueueAction(action);
        
    },
    
    getBrandPicklistValues : function(component, event, helper) {
        var action = component.get("c.getPicklistValues");
        action.setParams({
            "field": 'Brand_Offline__c',           
        });       
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){ 
                component.set("v.brandPicklistValues" , response.getReturnValue());
            }            
        }); 
        $A.enqueueAction(action);
        
    },
    
    getVehicleModelPicklistValuesByBrand : function(component, event, helper) {
        var action = component.get("c.getVehicleModelValuesByBrand");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){ 
                
                component.set("v.vehicleModelPicklistValuesByBrand", response.getReturnValue());
                helper.updateAvailableVehicleModelsBasedOnSelectedBrand(component, event, helper); 
                
            }            
        }); 
        $A.enqueueAction(action);
        
    },
    
    
    updateAvailableVehicleModelsBasedOnSelectedBrand : function(component, event, helper){
        var selectedBrand = component.find("brand").get("v.value");
        var vehicleModelPicklistValuesByBrand = component.get("v.vehicleModelPicklistValuesByBrand");
        component.set("v.vehicleModelPicklistValuesBySelectedBrand", vehicleModelPicklistValuesByBrand[selectedBrand]);
    },
    
    
    /*getTypePicklistValues : function(component, event, helper) {
        var action = component.get("c.getPicklistValues");
        action.setParams({
            "field": 'Type__c',           
        });      
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){ 
                component.set("v.typePicklistValues" , response.getReturnValue());
                
            }            
        }); 
        $A.enqueueAction(action);
        
    },
    
    getPurchaseTypePicklistValuesByType : function(component, event, helper) {
        var action = component.get("c.getPurchaseTypeValuesByType");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){ 
                component.set("v.purchaseTypePicklistValuesByType", response.getReturnValue());                
            }            
        }); 
        $A.enqueueAction(action);    
    },
    
    getSubTypePicklistValuesByType : function(component, event, helper) {
        var action = component.get("c.getSubTypeValuesByType");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){ 
                component.set("v.subTypePicklistValuesByType", response.getReturnValue());
                helper.updateAvailablePurchaseAndSubTypesBasedOnSelectedType(component,event,helper);
            }            
        }); 
        $A.enqueueAction(action);    
    },
    
    updateAvailablePurchaseAndSubTypesBasedOnSelectedType : function(component, event, helper){
        var selectedType = component.find("type").get("v.value");
        
        var purchaseTypePicklistValuesByType = component.get("v.purchaseTypePicklistValuesByType");
        component.set("v.purchaseTypePicklistValuesBySelectedType", purchaseTypePicklistValuesByType[selectedType]);        
        
        var subTypePicklistValuesByType = component.get("v.subTypePicklistValuesByType");
        component.set("v.subTypePicklistValuesBySelectedType", subTypePicklistValuesByType[selectedType]);
    }, */
    
    createLead : function(component, event, helper) {
        
        var action = component.get('c.saveLead');
        
        action.setParams({
            newLead: component.get("v.newLead")
        });
        
        action.setCallback(this, function(response) {
            
            var result = response.getReturnValue();
            var state = response.getState();       
            
            var toastEvent = $A.get("e.force:showToast");
            
            if (state === 'SUCCESS') {
                
                if(result.errorMessage === '' || result.errorMessage === undefined || result.errorMessage === null){
                    
                    toastEvent.setParams({
                        "title": "Success!",
                        "type":"success",
                        "message": "Lead created successfully."                
                    });                    
                    toastEvent.fire();  
                    
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": result.lead.ConvertedOpportunityId
                    });                    
                    navEvt.fire();  
                }
                
                else{
                    
                    var button = event.getSource();                
                    button.set('v.disabled',false);               
                    
                    toastEvent.setParams({
                        "title": "Error!",
                        "type":"error",
                        "message": result.errorMessage                
                    });
                    toastEvent.fire();
                    
                }                         
            }
            
        });
        $A.enqueueAction(action);        
    },
    
})