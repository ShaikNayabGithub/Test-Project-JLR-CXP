({
    getAccountInformation: function(component, event, errorMessage) {
        var action = component.get("c.getAccountDetail");
        action.setParams({ accountId: component.get("v.recordId") });
        
        action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
                let accountObj = response.getReturnValue();
				component.set("v.accountObj", response.getReturnValue());
                if(accountObj.Phone_Verified_Date__c) {
                    component.set("v.IsPhoneVerified", true);
                } 
                if(accountObj.Mobile_Verified_Date__c) {
                    component.set("v.IsMobileVerified", true);
                } 
                if(accountObj.HomePhone_Verified_Date__c) {
                    component.set("v.IsHomePhoneVerified", true);
                } 
                if(accountObj.PersonEmail_Verified_Date__c) {
                    component.set("v.IsPersonEmailVerified", true);
                } 
                if(accountObj.Email2_Verified_Date__c) {
                    component.set("v.IsEmail2Verified", true);
                } 
                if(accountObj.Email3_Verified_Date__c) {
                    component.set("v.IsEmail3Verified", true);
                } 
			} else if (state === "ERROR") {
				var errors = response.getError();
				console.log(JSON.stringify(errors));
			}
		});
		$A.enqueueAction(action);
    }
})