({
    loadRecord : function(component, event) {
        component.set("v.showSpinner",true);
        var action = component.get("c.getcurrentRecordData"); 
        action.setParams({
            "recordId" : component.get("v.recordId") 
        });
        action.setCallback(this, function(a){
            var state = a.getState(); 
            if(state == 'SUCCESS') {
                var resp = a.getReturnValue();
                console.log('Resp --> '+JSON.stringify(resp));
                if(resp != null){
                    component.set('v.isValidStage', resp.isValidStage);
                    if(resp.isValidStage){
                        component.set('v.FinContWrap',resp);
                        component.set('v.fchName',resp.accName);
                        component.set('v.cont', resp.cont);
                        component.set('v.userRegion', resp.userRegion);
                        if(resp.userRegion == 'IN'){
                            component.set('v.isNonIndiaUser',false);
                            component.set('v.finRefHelpText',"Loan Number");
                        }else{
                            component.set('v.isNonIndiaUser',true);
                        }
                        component.set('v.countryCode', resp.countryCode);
                        // added for CXPD-2365 : Contract Attributes Feedback. Contract attributes in New Finance contract should be optional for Korea 
                        var countryCodeHelper = component.get("v.countryCode");
                        console.log('country code is' + countryCodeHelper);
                        if (countryCodeHelper == 'KR'){
                            component.set("v.disableContractMandatory",false); 
                        };
                        console.log('disableContractMandatory is' + component.get("v.disableContractMandatory")) ;

                        

                        $A.util.addClass(component.find("toggle2"), "slds-hide");
                        $A.util.addClass(component.find("toggle3"), "slds-hide");
                    }else{
                        component.set('v.message', resp.message);
                        $A.util.addClass(component.find("toggle1"), "slds-hide");
                        $A.util.addClass(component.find("toggle3"), "slds-hide");
                    }
                }
            }
            component.set("v.showSpinner",false);
        });
        $A.enqueueAction(action);
    },
    saveContract : function(component, event,jsonVal) {
        component.set("v.showSpinner",true);
        var self = this;
        var action = component.get('c.saveContract'); 
        action.setParams({
            "recordId" : component.get("v.recordId"),
            "jsonStr" : jsonVal 
        });
        action.setCallback(this, function(a){
            var state = a.getState(); // get the response state
            if(state == 'SUCCESS') {
                var resp = a.getReturnValue();
                console.log('Resp --> '+JSON.stringify(resp));
                if(resp != null){
                    if(!resp.hasErr && resp.message != null && resp.recId != null && resp.contNumber != null){
                        component.set("v.contractnumber",resp.contNumber);
                        component.set("v.contractId",resp.recId);
                        self.showToast(component,'Success','success',resp.message);
                        $A.util.removeClass(component.find("financeConfPopup"), "slds-hide");
                        $A.util.addClass(component.find("financeConfPopup"), "slds-show");
                    }else if(resp.hasErr && resp.message != null){
                        self.showToast(component,'Error!','error',resp.message);
                    }
                }
            }
            component.set("v.showSpinner",false);
        });
        $A.enqueueAction(action);
    },
    navigateToRecord : function (component, event) {
        $A.get("e.force:closeQuickAction").fire();
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.contractId"),
            "slideDevName": "detail"
        });
        navEvt.fire();
        $A.get('e.force:refreshView').fire();
    },
    handlefinAccountchange : function (component, event) {
        $A.util.removeClass(component.find("togglePopupId"), "slds-hide");
        $A.util.addClass(component.find("togglePopupId"), "slds-show");
    },
    handleValidation : function (component,fieldId) {
        return component.find(fieldId).reduce(function(isValidSoFar, inputCmp){
            inputCmp.reportValidity();
            return isValidSoFar && inputCmp.checkValidity();
        },true);
    },
    showToast : function(component,title,type,message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "mode": "dismissible",
            "type":type,
            "message": message
        });
        toastEvent.fire();
    },
    handleAccountChange : function(component, event,recId) {
        console.log('recId--> '+recId);
        component.set("v.showSpinner",true);
        var action = component.get('c.handleAccountChange'); 
        action.setParams({
            "recordId" : component.get('v.recordId'),
            "accId" : recId 
        });
        action.setCallback(this, function(a){
            var state = a.getState(); 
            console.log('Rsp State --> '+state);
            if(state == 'SUCCESS') {
                var resp = a.getReturnValue();
                console.log('Resp --> '+JSON.stringify(resp));
                if(resp != null){
                    if(resp.cont != null){
                        component.set('v.cont.FCH_First_Name__c', resp.cont.FCH_First_Name__c);
                        component.set('v.cont.FCH_Last_name__c', resp.cont.FCH_Last_name__c);
                        component.set('v.cont.FCH_Email__c', resp.cont.FCH_Email__c);
                        component.set('v.cont.FCH_Phone__c', resp.cont.FCH_Phone__c);
                        component.set('v.cont.FCH_Mobile__c', resp.cont.FCH_Mobile__c);    
                    }
                    component.set('v.fchName',resp.accName);
                    component.set('v.FinContWrap.fchId',resp.fchId);
                    component.set('v.FinContWrap.accType', resp.accType);
                    component.set('v.FinContWrap.fchContactId', resp.fchContactId);
                    component.set('v.FinContWrap.isFchPerson', resp.isFchPerson);
                    component.set('v.FinContWrap.isFCHChanged', resp.isFCHChanged);
                    if(resp.isFchPerson != null && !resp.isFchPerson){
                        component.set('v.FinContWrap.language', resp.language);
                        component.set('v.FinContWrap.gender', resp.gender);
                        $A.util.removeClass(component.find("contSectionId"), "slds-hide");
                        $A.util.addClass(component.find("contSectionId"), "slds-show");
                    }else if(resp.isFchPerson != null && resp.isFchPerson){
                        $A.util.removeClass(component.find("contSectionId"), "slds-show");
                        $A.util.addClass(component.find("contSectionId"), "slds-hide");
                    }
                }
            }
            component.set("v.showSpinner",false);
        });
        $A.enqueueAction(action);
    },
    getPicklistValues : function(component, event) {
        var finHelperCmp = component.find("finContHelperId");
        
        finHelperCmp.getPicklistValues("Contract","Contract_Status__c",function(result){
            component.set("v.contractStatusList",result);
        });
        
        
        finHelperCmp.getPicklistValues("Contract","Finance_Product_Central__c",function(result){
            component.set("v.productCentralList",result);
        });
        
        finHelperCmp.getPicklistValues("Contract","JLR_Subvention__c",function(result){
            component.set("v.subventionList",result);
        });
        
        finHelperCmp.getPicklistValues("Contract","JLR_Subvention_Type__c",function(result){
            component.set("v.subventionTypeList",result);
        });
        
        finHelperCmp.getPicklistValues("Contact","Language__c",function(result){
            component.set("v.languageList",result);
        });
        
        finHelperCmp.getPicklistValues("Contact","Gender__c",function(result){
            component.set("v.genderList",result);
        });
        finHelperCmp.getPicklistValues("Contact","Salutation",function(result){
            component.set("v.salutationList",result);
        });
        finHelperCmp.getPicklistValues("Contract","Loan_Sourcing__c",function(result){
            component.set("v.financeSourcingChanneList",result);
        });
       /* finHelperCmp.getPicklistValues("Contract","Finance_Type__c",function(result){
            component.set("v.financeTypeList",result);
        });
        finHelperCmp.getPicklistValues("Contract","Product_Type__c",function(result){
            component.set("v.productTypeList",result);
        }); */
        finHelperCmp.getPicklistValues("Contract","Financier_Name__c",function(result){
            component.set("v.financierList",result);
        });
       this.getContractFieldValues(component,'Product Type','MENA')
       this.getContractFieldValues(component,'Finance Type','MENA');
        
    },
    getContractFieldValues : function(component,fieldName,market) {
        component.set("v.showSpinner",true);
        console.log('market --> '+market);
        console.log('fieldName --> '+fieldName);
        var action = component.get("c.getContractPicklistValues"); 
        action.setParams({
             "market" : market, 
            "fieldName" : fieldName           
        });
        action.setCallback(this, function(a){
            var state = a.getState(); 
            if(state == 'SUCCESS') {
                var resp = a.getReturnValue();
                console.log('Resp --> '+JSON.stringify(resp));
                if(resp != null){
                    if(fieldName == 'Product Type'){
                        component.set("v.productTypeList",resp);
                    }else  if(fieldName == 'Finance Type'){
                        component.set("v.financeTypeList",resp);
                    }
                }
            }
        });
         $A.enqueueAction(action);
    }
})