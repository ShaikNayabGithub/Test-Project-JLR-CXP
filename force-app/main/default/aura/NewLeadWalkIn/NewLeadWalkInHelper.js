({
    getpicklistValues : function(component, event, helper) {
        var action = component.get("c.getEnquiryValues");
        action.setCallback(this, function(response) {
            debugger;
            var state = response.getState();
            var arr = [];
            arr.push('Approved Pre-owned');
            arr.push('Approved Used Vehicle');
            arr.push('Brochure Request');
            arr.push('e-Brochure');
            arr.push('Extended Warranty');
            arr.push('Find & Price - Deposit');
            arr.push('Find & Price Enquiry');
            arr.push('Fleet and Business Enquiry');
            arr.push('Generic');
            arr.push('JLR Event');
            arr.push('KMI');
            arr.push('Mobile Lead');
            arr.push('Online Reservation');
            arr.push('Personalised Brochure Request');
            arr.push('Resurrected Lead');
            arr.push('Retention');
            arr.push('Test Drive Request');
            arr.push('Vehicle Configuration');
            arr.push('Owner Offers');
            arr.push('Accessory Offers');
            arr.push('New Vehicle Offers');
            arr.push('Used Vehicle Offers');
            arr.push('Request a Call Back');
            arr.push('KMI+');
            arr.push('Service Interception');
            if(state === 'SUCCESS'){ 
                //component.set("v.enquiryTypePicklistValues" , response.getReturnValue());
                component.set("v.enquiryTypePicklistValues" , arr);
            }            
        }); 
        $A.enqueueAction(action);
        
        var action1 = component.get("c.getBrandValues");
        action1.setCallback(this, function(response1) {
            var state1 = response1.getState();
            if(state1 === 'SUCCESS'){ 
                component.set("v.brandPicklistValues" , response1.getReturnValue());
            }            
        }); 
        $A.enqueueAction(action1);
        
        var action2 = component.get("c.getBrandModelsMap");
        action2.setCallback(this, function(response2) {
            var state2 = response2.getState();
            if(state2 === 'SUCCESS'){ 
                component.set("v.vehicleModelPicklistValuesByBrand", response2.getReturnValue());
                var selectedBrand = component.get("v.brandPicklistValues");
                var vehicleModelPicklistValuesByBrand = component.get("v.vehicleModelPicklistValuesByBrand");
                component.set("v.vehicleModelPicklistValuesBySelectedBrand", vehicleModelPicklistValuesByBrand[selectedBrand[0]]);
            }            
        }); 
        $A.enqueueAction(action2);
        
        var action3 = component.get("c.getCampaignCreateAccess");
        action3.setCallback(this, function(response3) {
            var state3 = response3.getState();
            if(state3 === 'SUCCESS'){ 
                component.set("v.campaignCreateAccess", response3.getReturnValue());
            }            
        }); 
        $A.enqueueAction(action3);
    },
    
    accountsList : function(component, event, helper) {
        var action = component.get("c.getAccount");
        action.setParams({
            "firstName": component.get("v.newLead").FirstName,     
            "lastName": component.get("v.newLead").LastName,
            "phoneNo": component.get("v.newLead").MobilePhone,
            "email": component.get("v.newLead").Email
        }); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){ 
                if(response.getReturnValue().length > 0){
                    component.set("v.showCreateLeadForm" , false);
                    component.set("v.showCompleteLeadForm" , false);
                    component.set("v.showAccounts" , true);
                    component.set("v.showOpportunities" , false);
                    component.set("v.accountsList" , response.getReturnValue());
                }
                else{
                    component.set("v.showCreateLeadForm" , true);
                    component.set("v.showCompleteLeadForm" , true);
                    component.set("v.showAccounts" , false);
                    component.set("v.showOpportunities" , false);
                }
                component.set("v.selectedAccountId", "");
            }            
        }); 
        $A.enqueueAction(action);
    },
    
    opportunitiesList : function(component, event, helper, accountId) {
        var action = component.get("c.getOpportunity");
        action.setParams({
            "accountId": accountId,     
        }); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){ 
                debugger;
                if(response.getReturnValue().length > 0){
                    component.set("v.showCreateLeadForm" , false);
                    component.set("v.showCompleteLeadForm" , false);
                    component.set("v.showAccounts" , false);
                    component.set("v.showOpportunities" , true);
                    component.set("v.opportunitiesList" , response.getReturnValue());
                }
                else{
                    component.set("v.showCreateLeadForm" , true);
                    component.set("v.showCompleteLeadForm" , true);
                    component.set("v.showAccounts" , false);
                    component.set("v.showOpportunities" , false);
                }
                
            }            
        }); 
        $A.enqueueAction(action);
    },
    
    createLead : function(component, event, helper, campaignID) {
        var action = component.get('c.saveLead');
        action.setParams({
            newLead: component.get("v.newLead"),
            campaignId: campaignID
        });
        this.showspinner(component, event);
        console.log(JSON.stringify(component.get("v.newLead")));
        action.setCallback(this, function(response) {
            debugger;
            var result = response.getReturnValue();
            var state = response.getState();       
            var toastEvent = $A.get("e.force:showToast");
            this.hidespinner(component, event);
            if (state === 'SUCCESS') {
                
                if(result.errorMessage === '' || result.errorMessage === undefined || result.errorMessage === null){
                    if(result != 'Existing Account'){
                       toastEvent.setParams({
                       "title": "Success!",
                       "type":"success",
                       "message": "Lead created successfully."                
                       });                    
                    toastEvent.fire();  
                    
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": result
                    });                    
                    navEvt.fire();  
                }
                else{
                    toastEvent.setParams({
                       "title": "Existing Individual!",
                       "type":"info",
                       "message": "Individual is already existing in system. Please change either Last Name, Mobile Phone or Email."                
                       });                    
                    toastEvent.fire();
                }
            }
                else{
                    /*var button = event.getSource();                
                    button.set('v.disabled',false);               
                    
                    toastEvent.setParams({
                        "title": "Error!",
                        "type":"error",
                        "message": result.errorMessage                
                    });
                    toastEvent.fire();*/
                }                         
            }
            else
                console.log(response.getError());
		});
        $A.enqueueAction(action);        
    },
    
    createOpp : function(component, event, helper, campaignID, accountId){
        var action = component.get('c.saveOpportunity');
        action.setParams({
            newLead: component.get("v.newLead"),
            campaignId: campaignID,
            accountId: accountId
        });
        this.showspinner(component, event);
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            var state = response.getState();       
            var toastEvent = $A.get("e.force:showToast");
            this.hidespinner(component, event);
            if (state === 'SUCCESS') {
                
                if(result.errorMessage === '' || result.errorMessage === undefined || result.errorMessage === null){
                    toastEvent.setParams({
                        "title": "Success!",
                        "type":"success",
                        "message": "Opportunity created successfully."                
                    });                    
                    toastEvent.fire();  
                    
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": result
                    });                    
                    navEvt.fire();  
                }
                else{}                         
            }
            else
                console.log(response.getError());
        });
        $A.enqueueAction(action);        
    },  
    
    showspinner : function(component, event){
        var m = component.find('modalspinnerLookup');
        $A.util.removeClass(m, "slds-hide");
    },
    
    hidespinner : function(component, event){
        var m = component.find('modalspinnerLookup');
        $A.util.addClass(m, "slds-hide");
    }
})