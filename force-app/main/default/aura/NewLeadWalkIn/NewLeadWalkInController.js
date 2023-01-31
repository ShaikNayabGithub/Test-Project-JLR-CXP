({
    doInit : function(component, event, helper) {
        helper.getpicklistValues(component, event, helper);
    },
    
    
    brandOnChange : function (component, event, helper){
        var selectedBrand = component.find("brand").get("v.value");
        var vehicleModelPicklistValuesByBrand = component.get("v.vehicleModelPicklistValuesByBrand");
        component.set("v.vehicleModelPicklistValuesBySelectedBrand", vehicleModelPicklistValuesByBrand[selectedBrand]);
        component.find("vehicleModel").set("v.value", vehicleModelPicklistValuesByBrand[selectedBrand][0]);
    },
    
    searchLeads : function(component, event, helper) {
        var fn = component.get("v.newLead").FirstName;
        var ln = component.get("v.newLead").LastName;
        var ph = component.get("v.newLead").Email;
        var em = component.get("v.newLead").MobilePhone;
        if($A.util.isEmpty(fn) && $A.util.isEmpty(ln) && $A.util.isEmpty(ph) && $A.util.isEmpty(em)){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Required Fields Empty!",
                "type":"error",
                "message": "Please provide either information."                
            });                    
            toastEvent.fire();
        }
        else
            helper.accountsList(component, event, helper);
    },
    
    onSelectAccount: function(component, event, helper) {
        component.set("v.selectedAccountId" , event.getSource().get("v.text").accId);
        component.set("v.selectedEmail" , event.getSource().get("v.text").accEmail);
        component.set("v.selectedPhone" , event.getSource().get("v.text").accMobile);
        component.get("v.newLead").FirstName = event.getSource().get("v.text").accFName;
        component.get("v.newLead").LastName = event.getSource().get("v.text").accLName;
        component.get("v.newLead").Email = event.getSource().get("v.text").accEmail;
        component.get("v.newLead").MobilePhone = event.getSource().get("v.text").accMobile;
        helper.opportunitiesList(component, event, helper, event.getSource().get("v.text").accId);
    },
    
    onSelectOpportunity: function(component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": event.getSource().get("v.text")
        });                    
        navEvt.fire();
    },
    
    createLeads : function(component, event, helper) {
        var fn = component.get("v.newLead").FirstName;
        var ln = component.get("v.newLead").LastName;
        var em = component.get("v.newLead").Email;
        var ph = component.get("v.newLead").MobilePhone;
        if($A.util.isEmpty(fn))
            component.find('FirstName').reportValidity();
        else if($A.util.isEmpty(ln))
            component.find('LastName').reportValidity();
        else if($A.util.isEmpty(em) && $A.util.isEmpty(ph)){
            component.find('email').reportValidity();
       		component.find('phone').reportValidity();
        }
        else{
            if($A.util.isEmpty(component.get("v.selectedAccountId")))
            	helper.createLead(component, event, helper, component.get("v.selectedId"));
            else
                helper.createOpp(component, event, helper, component.get("v.selectedId"), component.get("v.selectedAccountId"));
        }
    },
    
    createNew : function(component, event, helper) {
        component.set("v.showCreateLeadForm" , true);
        component.set("v.showCompleteLeadForm" , true);
        component.set("v.showAccounts" , false);
        component.set("v.showOpportunities" , false);
    },
    
    createNewOpp : function(component, event, helper) {
        component.set("v.showCreateLeadForm" , true);
        component.set("v.showCompleteLeadForm" , true);
        component.set("v.ButtonText" , "Create New Walk-in");
        component.set("v.showAccounts" , false);
        component.set("v.showOpportunities" , false);
    }
})