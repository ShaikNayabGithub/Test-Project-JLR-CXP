({
    doInit : function(component, event, helper) {
        helper.loadRecord(component, event);
        helper.getPicklistValues(component, event);
    },
    closeModal : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    createContract : function(component, event, helper) {
        var contr = component.get("v.cont");
        console.log('contr --> '+JSON.stringify(contr));
        var isNonIndiaUser = component.get("v.isNonIndiaUser");
        var fchCheck = component.get("v.fchCheck");
        if(!isNonIndiaUser){
            if(contr  
              && ((!contr.Phone__c || !contr.Phone__c.trim().length)
               && (!contr.Mobile__c || !contr.Mobile__c.trim().length))){
                helper.showToast(component,'Error!','error','Please Complete Phone or Mobile fields');
                return;
            }
            if(fchCheck){
                if(contr 
                   && ((!contr.FCH_Phone__c || !contr.FCH_Phone__c.trim().length)
                   && (!contr.FCH_Mobile__c || !contr.FCH_Mobile__c.trim().length))){
                    helper.showToast(component,'Error!','error','Please Complete Finance Contract Holder Phone or Mobile fields');
                    return;
                }
            }
        }
        
        var contlkp = component.get("v.contlkp");
        console.log('contlkp --> '+JSON.stringify(contlkp));
        
        var selectedFinRec = component.get("v.selectedFinRec");
        console.log('selectedFinRec --> '+JSON.stringify(selectedFinRec));
        
        var selectedCurrFinRec = component.get("v.selectedCurrFinRec");
        console.log('selectedCurrFinRec --> '+JSON.stringify(selectedCurrFinRec));
        
        var currentVehicleBrand = component.get("v.currentVehicleBrand");
        console.log('currentVehicleBrand --> '+JSON.stringify(currentVehicleBrand));
        
        var currentVehicle = component.get("v.currentVehicle");
        console.log('currentVehicle --> '+JSON.stringify(currentVehicle));
        
        var selectedFinanceType = component.get("v.selectedFinanceType");
        console.log('selectedFinanceType --> '+JSON.stringify(selectedFinanceType));
        
        var selectedProductType = component.get("v.selectedProductType");
        console.log('selectedProductType --> '+JSON.stringify(selectedProductType));
        
        if(selectedProductType != null && selectedProductType.Id != null){
            component.set("v.FinContWrap.cont.Product_Type_Data__c",selectedProductType.Id);
        }
        
        if(selectedFinanceType != null && selectedFinanceType.Id != null){
            component.set("v.FinContWrap.cont.Finance_Type_Data__c",selectedFinanceType.Id);
        }
        
        if(currentVehicleBrand != null && currentVehicleBrand.Id != null){
            component.set("v.FinContWrap.cont.Current_Vehicle_Brand__c",currentVehicleBrand.Id);
        }
        
        if(currentVehicle != null && currentVehicle.Id != null){
            component.set("v.FinContWrap.cont.Current_Vehicle__c",currentVehicle.Id);
        }
        
        if(selectedFinRec != null && selectedFinRec.Finance_Service_Dealer_With_Market__c != null){
            component.set("v.FinContWrap.cont.FS_Provider__c",selectedFinRec.Finance_Service_Dealer_With_Market__c);
        }
        
        if(selectedCurrFinRec != null && selectedCurrFinRec.Finance_Service_Dealer_With_Market__c != null){
            component.set("v.FinContWrap.cont.Current_FS_Provider__c",selectedCurrFinRec.Finance_Service_Dealer_With_Market__c);
        }
        
        var userRegion = component.get("v.userRegion");
        component.set("v.FinContWrap.cont.Market__c",userRegion);
        
        var countryCode = component.get("v.countryCode");
        component.set("v.FinContWrap.cont.Country_ISO_Code__c",countryCode);

       
        var financeRenewal = component.get("v.financeRenewal");
        console.log('financeRenewal --> '+financeRenewal);
        if(financeRenewal != null){
            if(financeRenewal == 'Yes'){
                component.set("v.FinContWrap.cont.FS_Renewal__c",true);
            }else if(financeRenewal == 'No'){
                component.set("v.FinContWrap.cont.FS_Renewal__c",false);
            }
        }
        
        component.set("v.FinContWrap.cont",contr);
        component.set("v.FinContWrap.cont.Finance_Service_Dealer__c",contlkp.Finance_Service_Dealer__c);
        var endDate = component.get("v.FinContWrap.cont.EndDate");
        var endDateCustVal = component.get("v.endDate");
        console.log('endDateCustVal --> '+endDate);
        console.log('endDateCustVal --> '+endDateCustVal);
        if(endDateCustVal != null){
            component.set("v.FinContWrap.cont.EndDate",endDateCustVal);
        }
        console.log('endDate11 --> '+component.get("v.FinContWrap.cont.EndDate"));
        var valid;
        valid = helper.handleValidation(component,'fieldValid');
        console.log('valid --> '+valid);
        var isFchPerson =  component.get("v.FinContWrap.isFchPerson");
        if(valid && isFchPerson != null && !isFchPerson){
            valid = helper.handleValidation(component,'fchFieldValid');
        }
        
        var FinContWrap = component.get("v.FinContWrap");
        console.log('FinContWrap --> '+JSON.stringify(FinContWrap));
        console.log('valid --> '+valid);
        if(!valid){
            helper.showToast(component,'Error!','error','Please fill all the required fields');
        } else if(valid){
            helper.saveContract(component, event, JSON.stringify(FinContWrap)); 
        }
    },
    handlecheckBoxChange : function (component, event,helper) {
        var fchCheck = component.find("FCHCheckId").get("v.checked");
        component.set("v.fchCheck",fchCheck);
        if(fchCheck != null && fchCheck){
            helper.handlefinAccountchange(component,event);
        }
    },
    closeSelectionPopup: function(component, event, helper) {
        component.set("v.fchCheck",false);
        $A.util.removeClass(component.find("togglePopupId"), "slds-show");
        $A.util.addClass(component.find("togglePopupId"), "slds-hide");
    },
    proceedSelectionPopup: function(component, event, helper) {
        $A.util.removeClass(component.find("togglePopupId"), "slds-show");
        $A.util.addClass(component.find("togglePopupId"), "slds-hide");
        component.set("v.fchShowCls","slds-hide");
        component.set("v.fchHideCls","slds-show");
        var fchId = component.get("{!v.contlkp.FCH_Finance_contract_holder_Account__c}");
        helper.handleAccountChange(component,event,fchId);
    },
    handleComponentEvent : function(component, event, helper) {
        var message = event.getParam("message");
        var recordType = event.getParam("recordType");
        console.log('message -->  '+message);
        console.log('recordType -->  '+recordType);
        if(recordType != null && recordType == 'VehicleBrand' && message != null && message.Id != null){
            component.set("v.brandValue",message.Id);
            $A.util.removeClass(component.find("vehicleNameId"), "slds-hide");
            $A.util.addClass(component.find("vehicleNameId"), "slds-show");
        }else if(recordType != null && recordType == 'Clear_Vehicle'){
            component.set("v.brandValue","null");
            component.set("v.currentVehicleBrand",component.get("v.currVehicleVal"));
            component.set("v.currentVehicle",component.get("v.currVehicleVal"));
            $A.util.removeClass(component.find("vehicleNameId"), "slds-show");
            $A.util.addClass(component.find("vehicleNameId"), "slds-hide");
        }else if(recordType != null && recordType == 'Contact_Data'){
            console.log('message -->  '+message);
            console.log('recordType -->  '+recordType);
        }else  if(message == 'Open_Opportunity'){
            $A.get("e.force:closeQuickAction").fire();
            $A.get('e.force:refreshView').fire();
        }else  if(message == 'Open_Contract'){
            helper.navigateToRecord(component,event);
        }
    },
    handleDateChange : function(component, event, helper) {
        var ContractTerm = component.get("v.cont.ContractTerm");
        var StartDate = component.get("v.cont.StartDate");
        console.log('ContractTerm -->  '+ContractTerm);
        console.log('StartDate -->  '+StartDate);
        try{
            if(!$A.util.isEmpty(ContractTerm) && !$A.util.isEmpty(StartDate)){
                var endDate = new Date(StartDate);
                var StartDateValCust = new Date(StartDate);
                StartDateValCust.setMonth(endDate.getMonth() + +ContractTerm);
                endDate.setMonth(endDate.getMonth() + +ContractTerm);
                endDate = $A.localizationService.formatDate(endDate, "YYYY-MMM-DD");
                
                var dd = String(StartDateValCust.getDate()).padStart(2, '0');
                var mm = String(StartDateValCust.getMonth() + 1).padStart(2, '0'); //January is 0!
                var yyyy = StartDateValCust.getFullYear();
                
                var endDateValCust = yyyy + '-' + mm + '-' + dd;
                
                console.log('endDate -->  '+endDate);
                console.log('endDateValCust -->  '+endDateValCust);
                component.set("v.cont.EndDate",endDate);
                component.set("v.endDate",endDateValCust);
                console.log('endDate23 -->  '+component.get("v.cont.EndDate"));
                console.log('endDateValCust -->  '+component.get("v.endDate"));
            } 
        }catch(err) {
            console.log('err -->  '+JSON.stringify(err));
        }
    },
    handleChange: function (component, event) {
        var fchCheck = component.get("v.fchCheck");
        var nameVal = event.getSource().get("v.name");
        var fieldVal = event.getSource().get("v.value");
        console.log('nameVal -->  '+nameVal);
        console.log('fieldVal -->  '+fieldVal);
        if(fchCheck != null && !fchCheck && nameVal != null && nameVal != undefined && fieldVal != null && fieldVal != undefined){
            if(nameVal == 'firstName'){
                component.set("v.cont.FCH_First_Name__c",fieldVal);
                component.set("v.cont.First_Name__c",fieldVal);
            }else if(nameVal == 'lastName'){
                component.set("v.cont.FCH_Last_name__c",fieldVal);
                component.set("v.cont.Last_Name__c",fieldVal);
            }else if(nameVal == 'finEmail'){
                component.set("v.cont.FCH_Email__c",fieldVal);
                component.set("v.cont.Email__c",fieldVal);
            }else if(nameVal == 'finPhone'){
                component.set("v.cont.FCH_Phone__c",fieldVal);
                component.set("v.cont.Phone__c",fieldVal);
            }else if(nameVal == 'finMobile'){
                component.set("v.cont.FCH_Mobile__c",fieldVal);
                component.set("v.cont.Mobile__c",fieldVal);
            }else if(nameVal == 'Salutation'){
                component.set("v.cont.Salutation__c",fieldVal);
            }
        }
    }
})