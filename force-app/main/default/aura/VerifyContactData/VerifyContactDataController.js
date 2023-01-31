({
	doInit: function(component, event, helper) {
        helper.getAccountInformation(component, event, helper);
    },
    
    enableAction: function(component, event, helper) {
        // Enable Save Button when there is toggle between any switch to avoid unneccessary multiple save
        component.set("v.enableSave", true);
    },
    
    toggleVerify: function(component, event, helper) {
        component.set("v.message", '');
        let verifyTargetField = event.currentTarget.dataset.name;
        let accountObj = component.get("v.accountObj");
        
        if(verifyTargetField == 'Phone') {      
            if(event.currentTarget.dataset.verified === 'true') {
                component.set("v.IsPhoneVerified", false);
            } else if(accountObj.Phone) {
                component.set("v.IsPhoneVerified", true);
            } else { 
                alert('Please provide value in Phone field to verify.');
                return;
            }
        } else if(verifyTargetField == 'Mobile') {      
            if(event.currentTarget.dataset.verified === 'true') {
                component.set("v.IsMobileVerified", false);
            } else if(accountObj.PersonMobilePhone) {
                component.set("v.IsMobileVerified", true);
            } else {
                alert('Please provide value in Mobile field to verify.');
                return;
            }
        } else if(verifyTargetField == 'HomePhone') {           
            if(event.currentTarget.dataset.verified === 'true') {
                component.set("v.IsHomePhoneVerified", false);
            } else if(accountObj.PersonHomePhone) {
                component.set("v.IsHomePhoneVerified", true);
            } else {
                alert('Please provide value in Home Phone field to verify.');
                return;
            }
        } else if(verifyTargetField == 'PersonEmail') {           
            if(event.currentTarget.dataset.verified === 'true') {
                component.set("v.IsPersonEmailVerified", false);
            } else if(accountObj.PersonEmail) {
                component.set("v.IsPersonEmailVerified", true);
            } else {
                alert('Please provide value in Person Email field to verify.');
                return;
            }
        } else if(verifyTargetField == 'Email2') {           
            if(event.currentTarget.dataset.verified === 'true') {
                component.set("v.IsEmail2Verified", false);
            } else if(accountObj.Email2__pc) {
                component.set("v.IsEmail2Verified", true);
            } else {
                alert('Please provide value in Email 2 field to verify.');
                return;
            }
        } else if(verifyTargetField == 'Email3') {           
            if(event.currentTarget.dataset.verified === 'true') {
                component.set("v.IsEmail3Verified", false);
            } else if(accountObj.Email3__pc) {
                component.set("v.IsEmail3Verified", true);
            } else {
                alert('Please provide value in Email 3 field to verify.');
                return;
            }
        }
        // Enable Save Button when there is toggle between any switch to avoid unneccessary multiple save
        component.set("v.enableSave", true);
    },
    
	updateAccount: function(component, event, helper) {
        var checkboxMap = component.get("v.checkboxMap");
        checkboxMap['Phone'] = component.get("v.IsPhoneVerified");
        checkboxMap['Mobile'] = component.get("v.IsMobileVerified");
        checkboxMap['HomePhone'] = component.get("v.IsHomePhoneVerified");
        checkboxMap['PersonEmail'] = component.get("v.IsPersonEmailVerified");
        checkboxMap['Email2'] = component.get("v.IsEmail2Verified");
        checkboxMap['Email3'] = component.get("v.IsEmail3Verified");
        
        var action = component.get("c.updateAccountDetail");
        action.setParams({ 
            accountObj: component.get("v.accountObj"),
            verifyCheckboxMap: checkboxMap
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if(response.getReturnValue() == 'Success') {
                    // Display the total in a "toast" status message
                    var resultsToast = $A.get("e.force:showToast");
                    resultsToast.setParams({
                        "title": "Success!",
                        "type": "success",
                        "message": $A.get("$Label.c.Account_Updated_Success")
                    });
                    resultsToast.fire();
                    
                    // Close the action panel & refresh the page
                    $A.get("e.force:closeQuickAction").fire();  
                    $A.get('e.force:refreshView').fire(); 
                } else {
                    component.set("v.message", response.getReturnValue());
                }
                helper.getAccountInformation(component, event, helper);
            } else if (state === "ERROR") {
                console.log(JSON.stringify(response.getError()));
            }
        });
        $A.enqueueAction(action);
    }
});