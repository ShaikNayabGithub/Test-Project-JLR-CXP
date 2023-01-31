({
    doInit : function(component, event, helper) {  
        
        helper.getSalutationPicklistValues(component, event, helper);       
        helper.getEnquiryTypePicklistValues(component, event, helper);       
        helper.getBrandPicklistValues(component, event, helper);       
        helper.getVehicleModelPicklistValuesByBrand(component, event, helper);
        
        /*helper.getTypePicklistValues(component, event, helper);    
        helper.getPurchaseTypePicklistValuesByType(component, event, helper);
        helper.getSubTypePicklistValuesByType(component, event, helper);*/
        
    },
    
    brandOnChange : function (component, event, helper){
        helper.updateAvailableVehicleModelsBasedOnSelectedBrand(component, event, helper);
    },
    
    typeOnChange : function (component, event, helper){
        helper.updateAvailablePurchaseAndSubTypesBasedOnSelectedType(component, event, helper);
    },
    
    createLead : function(component,event,helper){
        
        var button = event.getSource();
        
        var toastEvent = $A.get("e.force:showToast");
        var newLead =  component.get("v.newLead");
        
        var salutation = newLead.Salutation;
        var enquiryType = newLead.Enquiry_Type__c;
        var firstName = newLead.FirstName;
        var lastName = newLead.LastName;
        var brand = newLead.Brand_Offline__c;
        var vehicleModel = newLead.Vehicle_Model_Offline__c;
        
        var phone = newLead.Phone;
        var email = newLead.Email;
        
        if((salutation === undefined || salutation === '')
           || (enquiryType === undefined || enquiryType === '')
           || (firstName === undefined || firstName === '')
           || (lastName === undefined || lastName === '')
           || (brand === undefined || brand === '')
           || (vehicleModel === undefined || vehicleModel === '')) {
            
            toastEvent.setParams({
                "title": "error!",
                "type":"error",
                "message": "Enter Mandatory Fields."
                
            });
            toastEvent.fire();
        }
        else if((phone === undefined || phone == '') && (email === undefined || email === '')){
            
            toastEvent.setParams({
                "title": "error!",
                "type":"error",
                "message": "One of Phone or Email must be entered."
            });
            toastEvent.fire();
        }
            else
            {
                button.set('v.disabled',true);               
                helper.createLead(component, event, helper);
            }
        
    }
    
    
})