/*
* S.No.		Name		Date(DD/MM/YYYY)	Change 
* 1.0		Ashwin		03/06/2021			CXPD-1159: Update Error message
* 2.0		Ashwin 		05/08/2021			CXPD-1434: Prevent submit when Add Corporate SP
*											is selected and Corporate Account SP is not selected
* 
*/
({    
    
    handleUpdateExpense: function(component, event, helper) {
        var updatedExp = event.getParam("serviceplanid");
        /* var corpId = event.getParam("corpId");
        var corpName = event.getParam("corpName");
        console.log('corpName ---> '+corpName);
        console.log('corpId ---> '+corpId);
        if(corpId){
            component.set("v.showCorpAccSPErrorMsg", false);//2.0
        }
        component.set("v.servicePlanScheme", corpId);//2.0
        component.set("v.servicePlanSchemeName", corpName);//2.0
        component.set("v.serviceplanid", updatedExp);
        console.log('servicePlanScheme -->  '+component.get("v.servicePlanScheme"));
        console.log('servicePlanSchemeName -->  '+component.get("v.servicePlanSchemeName"));*/
        var offerId = event.getParam("offerId");
        var corpId = event.getParam("corpId");
        component.find("offer__c").set("v.value",offerId);
        helper.helperRefreshServicePlan(component, updatedExp); 
    },
    
    doInit : function(component, event, helper) {
        
        helper.labelSetter(component, 'RDA__c', 'v.rdaLabelMap');
        helper.labelSetter(component, 'Asset', 'v.assetLabelMap');
        var rdaid = component.get('v.recordId');
        if(rdaid != null && rdaid != ''){
            var setupRda = component.get("c.getRDA");
            setupRda.setParams({rdaId : rdaid});
            setupRda.setCallback(this, function(rdaDetail) {
                if(rdaDetail.getState() === 'SUCCESS'){
                    var defafultRDA = rdaDetail.getReturnValue().rdaInst;
                    //console.log('defafultRDA --->  '+JSON.stringify(defafultRDA));
                    component.set('v.fmoTrueList', rdaDetail.getReturnValue().fmoTrueList);
                    component.set('v.defaultRDA', defafultRDA);
                    component.set('v.rdaType', defafultRDA.RecordType.DeveloperName);
                    helper.setupAsset(component, component.get('v.defaultRDA').Asset__c);
                    helper.setupOpp(component, component.get('v.defaultRDA').Opportunity__c);                    
                    helper.setupServicePlan(component, component.get('v.defaultRDA').Opportunity__c,helper);
                    helper.setupAccount(component, component.get('v.accountid'));
                    component.set("v.istempFMOFlag",component.get("v.defaultRDA").Is_Fleet_Management_Organisation__c);					
                    
                    // helper.setupLocality(component, component.get('v.accountid'));
                    // helper.setLoyaltyTransaction(component);
                    // helper.getContactLoyaltyStatusHelper(component); //jp
                }
            });
            $A.enqueueAction(setupRda);    
            
        }
        else{
            helper.setupServicePlan(component, component.get('v.defaultRDA').Opportunity__c,helper);
            helper.setupAsset(component, component.get('v.assetid'));
            helper.setupOpp(component, component.get('v.oppid'));
            helper.setupAccount(component, component.get('v.accountid'));
            helper.setupComplimentaryServicePlan(component, component.get('v.assetid'));
            helper.getFMOTrueValues(component);
            //  helper.setLoyaltyTransaction(component);
            //   helper.getContactLoyaltyStatusHelper(component);
        }
        helper.setupLocality(component, component.get('v.accountid'));
        helper.setupExistingServicePlan(component, component.get('v.assetid'));
        
        //TEMO
        helper.simulateServerRequest( component);
        
        component.set("v.isFMO",component.find("isFMOid").get("v.value") );
        component.set('v.loaded', false);        
        //console.log('v.defaultRDA.Handover_Date__c: '+component.get('v.defaultRDA.Handover_Date__c'));
    },
    handleOnChangeEditCorpField: function(component, event, helper) {
        value = component.find("plan-record").get("v.value");
        component.find("CorpID").set("v.value",value);        
    },
    
    getTradeInAsset : function(component, event, helper) {
        var setupAsset = component.get("c.getTradeIn");
        setupAsset.setParams({assetId : component.get('v.assetid')});
        setupAsset.setCallback(this, function(assetDetail) {
            if(assetDetail.getState() === 'SUCCESS'){
                component.set('v.tradeIn', assetDetail.getReturnValue());                
            }
        });
        $A.enqueueAction(setupAsset);
    },
    
    toggleLoyalty : function(component, event, helper) {
        var toggle = component.get('v.isLoyaltyPointsEligible');
        component.set('v.isLoyaltyPointsEligible',toggle);
        if(toggle){
            helper.setLoyaltyTransaction(component);
            helper.getContactLoyaltyStatusHelper(component);
            var spinner = component.find("mySpinner");
            $A.util.toggleClass(spinner, "slds-show");
        }
    },
    
    toggleTradeIn : function(component, event, helper) {
        component.set('v.isTradeIn', event.getSource().get("v.value"));
    },
    
    toggleJLRTradeIn : function(component, event, helper) {
        component.set('v.isJLRTradeIn', event.getSource().get("v.value"));
        if(!$A.util.isUndefinedOrNull( component.find("vinENT")) ){
            var x = component.find("vinENT").get("v.value")
            
            helper.setupTradeInAsset(component,x);
        }
    },
    
    onChangeOfManuallyEnteredVin : function(component, event, helper) {
        
        var x = event.getSource().get("v.value");
        helper.setupTradeInAsset(component,x);
    },
    
    handleSuccess : function(component, event, helper) {
         
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": event.getParams().response.id,
        });
        navEvt.fire();
        
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({"title":"Success", "type":"success", "message":$A.get("$Label.c.RDA_successfully_created")});
        toastEvent.fire();
        component.set("v.recordId", event.getParams().response.id);
        var LPTEditForm = component.find("LPTeditForm");
        if(!$A.util.isUndefinedOrNull(component.get("v.recordId")) && !$A.util.isUndefinedOrNull(LPTEditForm )){
            debugger;
            component.find("LPTrda").set('v.value', event.getParams().response.id);
            LPTEditForm.submit();
        }
        component.set('v.loaded', false);
    },
    
    handleError : function(component, event, helper) {
        component.set('v.loaded', false);
        component.find('OppMessage').setError('Undefined error occured');
        var toastEvent = $A.get("e.force:showToast");
        var message = event.getParam('detail');
        toastEvent.setParams({"title":"Error", "type":"error", "message":message});
        toastEvent.fire();        
    },
    
    handleSuccess1 : function(component, event, helper) {
        
        helper.setupLocality(component, component.get('v.accountid'));
        component.set('v.isAccountEdited',false);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({"title":"Success", "type":"success", "message":$A.get("$Label.c.Customer_Details_successfully_Updated")});
        toastEvent.fire();        
    },
    
    handleOnChangeEditField : function(component, event, helper) {
        component.set('v.isAccountEdited',true);    
        if((!$A.util.isUndefinedOrNull(component.find("LPT_Account_Name__c")) && (!$A.util.isUndefinedOrNull(component.find("accountLastName"))))){
            component.find("LPT_Account_Name__c").set("v.value", component.find("accountLastName").get("v.value"));
        }
    },
    
    handleOnChangeLocalityFieldAccount : function(component, event, helper) {
        var localities = component.get("v.availableLocalities"), 
            value = component.find("localityA").get("v.value"),
            index = localities.findIndex(item => item.Id == value),
            idName = index >= 0? localities[index].Id: null,
            cityName = index >= 0? localities[index].Name: null,
            stateName = index >= 0? localities[index].State__c: null,
            postalName = index >= 0? localities[index].PMA_Postcode__r.Name: null;
        component.find("cityIDA").set("v.value",cityName);
        component.find("stateIDA").set("v.value",stateName);
        component.find("PostalIDA").set("v.value",postalName);
        component.set('v.selectedLocality',idName);
        component.set('v.isAccountEdited',true);
    },
    
    handleOnChangeLocalityFieldContact : function(component, event, helper) {
        var localities = component.get("v.availableLocalities"), 
            value = component.find("localityC").get("v.value"),
            index = localities.findIndex(item => item.Id == value),
            idName = index >= 0? localities[index].Id: null,
            cityName = index >= 0? localities[index].Name: null,
            stateName = index >= 0? localities[index].State__c: null,
            postalName = index >= 0? localities[index].PMA_Postcode__r.Name: null;
        component.find("cityIDC").set("v.value",cityName);
        component.find("stateIDC").set("v.value",stateName);
        component.find("PostalIDC").set("v.value",postalName);
        component.set('v.selectedLocality',idName);
        component.set('v.isAccountEdited',true);
    },
    
    handleOnChangeServicePlanField: function(component, event, helper) {
        if(  component.find("ServicePlanID1") != null && component.find("ServicePlanID1") != undefined &&  component.find("ServicePlanID1").get("v.value") != null &&  component.find("ServicePlanID1").get("v.value") != undefined){
            var   value = component.find("ServicePlanID1").get("v.value")[0];
            if(value != null && value != undefined){
                helper.helperRefreshServicePlan(component, value); 
            }
        }
    },
    
    handleOnChangeEditPostalFieldAccount : function(component, event, helper) {
        var   value = component.find("PostalIDA").get("v.value");
        helper.refreshLocalityA(component, value);
        component.set('v.isAccountEdited',true);
    },
    
    handleOnChangeEditPostalFieldContact : function(component, event, helper) {
        var   value = component.find("PostalIDC").get("v.value");
        helper.refreshLocalityC(component, value);
        component.set('v.isAccountEdited',true);
    },
    
    handleSubmit: function(component, event, helper) {
        console.log('Enter');
        var ass =  component.find("selectCommonSaleTypeId");
        var today = $A.localizationService.formatDate(new Date(), "yyyy-MM-dd");
        component.set('v.today', today);
        var last7Days = new Date();
        last7Days.setDate(last7Days.getDate() - 7);
        var minDate = $A.localizationService.formatDate(last7Days, "yyyy-MM-dd");
        component.set('v.minDate', minDate);
        console.log('MinDate' + minDate) ;
        var showValidationError = false;
        var eventFields = event.getParam("fields");
        console.log('EventFields' +eventFields);
        var vaildationFailReason = '';
        event.preventDefault();
        
        
        if (eventFields["Handover_Date__c"] < minDate) {
            showValidationError = true;
            vaildationFailReason = $A.get("$Label.c.RDA_HandoverDate_Cannot_Be_Prior_Than_Last_7_Days");
            console.log('close here'+vaildationFailReason);
        }  else if(eventFields["Handover_Date__c"] > today){
            showValidationError = true;
            vaildationFailReason = $A.get("$Label.c.RDA_HandoverDate_Cannot_Be_Future_Than_Today");
            console.log('close here'+vaildationFailReason);
        }        
        
        
        
        
        /*eventFields["Handover_Date__c"] = selectHandoverdate;
        console.log('selected Date: ' + eventFields["Handover_Date__c"]); */
        
        
        /*var isCorporateSP = component.get("v.isCorporateSP");
        var servicePlanScheme = component.get("v.servicePlanScheme");
        var selectedLocality = component.get("v.selectedLocality");
         var rdaType = component.get("v.rdaType");
        console.log('selectedLocality  '+selectedLocality);
        console.log('isCorporateSP  '+isCorporateSP);
        console.log('servicePlanScheme  '+servicePlanScheme);
        var rdafields = event.getParam('fields');   
        console.log('corp acc --->  '+JSON.stringify(rdafields));
        
        if(rdaType == 'New_Retail' && (selectedLocality == undefined || selectedLocality == null)){
            var isPersonAcc = component.get("v.account.IsPersonAccount");
            console.log('isPersonAcc --->  '+isPersonAcc);
            if(isPersonAcc == true){
                component.find('localityA').showHelpMessageIfInvalid();
                event.preventDefault();
                return false;
            }else if(isPersonAcc == false){
                component.find('localityC').showHelpMessageIfInvalid();
                event.preventDefault();
                return false;
            }
        }
        
        if(isCorporateSP && !component.get("v.servicePlanScheme")){
            //component.find('CorpAccSPErrorMessage').setError("Corporate Account Service Plan is required");
            component.set('v.showCorpAccSPErrorMsg', true);
            event.preventDefault();
            return false;
        }else{
            rdafields["Corporate_Account__c"] = servicePlanScheme;
            console.log('corp acc 11--->  '+JSON.stringify(rdafields));
        }
        
        if(rdafields.Assignment_Type__c == 'Retail'){
            rdafields.Corporate_Account__c = null;
        }
        console.log('corp acc22 --->  '+JSON.stringify(rdafields));*/
        if(ass != null && ass.get("v.value") == '' ){
            component.find('CstMessage').setError("Common Type of Sale is required");//1.0
            event.preventDefault();
            return false;
        }
        if(ass != null && ass.get("v.value") != '' ){
            component.find('CstMessage').setError(null);
        }
      /*  component.set('v.loaded', true);
        var saveAccount =  component.get('v.isAccountEdited');
        if(saveAccount){
            if( component.find("accountEditForm") != null){
                component.find("accountEditForm").submit();     
            }
            /*console.log('Account__c--->  '+rdafields.Account__c);
            console.log('Title__c--->  '+rdafields.Title__c);
            helper.updateAccountTitileHelper(component,rdafields.Account__c,rdafields.Title__c);
       } */
        if( component.find("contactEditForm1") != null){   
            component.find("contactEditForm1").submit();
        }
        if (!showValidationError) {
            component.set('v.loaded', true);
            console.log(' Last Enter');    
              var saveAccount =  component.get('v.isAccountEdited');
        if(saveAccount){
            if( component.find("accountEditForm") != null){
                component.find("accountEditForm").submit();     
            }       
       }
            component.find("editForm").submit(eventFields); 
        } else {
            component.set('v.loaded', false); 
            component.find('OppMessage').setError(vaildationFailReason);
            console.log('Close Here' + vaildationFailReason);
            
        }   
        
        
    },
    
    LPTSuccess: function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({"title":"Success", "type":"success", "message":$A.get("$Label.c.LPT_successfully_Updated")});
        toastEvent.fire();
    },
    
    handleError1 : function(component, event, helper) {
        var spinner = component.find("mySpinnerAll");
        $A.util.toggleClass(spinner, "slds-hide");
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({"title":"Error", "type":"error", "message":event.getParam('detail')});
        toastEvent.fire();
    },
    
    handleOnChangeLoyaltyInfo: function(component, event, helper) {
        component.set('v.isAccountEdited',true); 
        component.find("accountEditForm").submit(); 
        helper.setLoyaltyTransaction(component); 
        var LS = component.find("LPT_Loyalty_Scheme__c").get("v.value");
        var LSR = component.find("LPT_Loyalty_Scheme_Reference__c").get("v.value");
        component.find("Loyalty_Scheme__c").set("v.value", LS);
        component.find("Loyalty_Scheme_Reference__c").set("v.value", LSR);
        component.find("accountEditForm").submit();
        helper.getChangedContactLoyaltyStatusHelper(component);
    },
    
    setCommonSaleType   : function(component, event, helper) {        
        var ass =  component.find("selectCommonSaleTypeId").get("v.value");
        var asset =  component.get('v.asset');
        asset.Common_Sale_Type__c = ass;
        component.set("v.asset",asset);
        if(component.get('v.fmoTrueList').includes(ass)) {
            component.find("isFMOid").set("v.value",true);
            component.set("v.isFMO",true);  
        } else {
            component.find("isFMOid").set("v.value",false);
            component.set("v.isFMO",false);
        }
    },
    
    setAssignmentType : function(component, event, helper) {
        component.set("v.isCorporateSP",false);
        component.set("v.isRetailSP",false);
        
        
        if(event.getSource().get("v.checked")){
            if(event.getSource().getLocalId() == 'retailSP'){
                component.find("Assignment_Type__c").set("v.value","Retail");
                component.set("v.isRetailSP",true);
                //component.find("RemoveSP").set("v.checked",false); 
                var updatedExp = component.get("v.serviceplanid");
                helper.helperRefreshServicePlan(component, updatedExp); 
                //helper.helperRefreshServicePlan(component,'');
                component.find("CorporateSP").set("v.checked",false); 
                if(!$A.util.isUndefinedOrNull(component.find("ServicePlanID"))) component.find("ServicePlanID").set("v.value", component.get("v.retailSP"));
                else component.find("ServicePlanID1").set("v.value", component.get("v.retailSP"));
            }else if(event.getSource().getLocalId() == 'CorporateSP'){    
                component.find("Assignment_Type__c").set("v.value","Corporate"); 
                //component.find("RemoveSP").set("v.checked",false); 
                component.find("retailSP").set("v.checked",false);  
                component.set("v.isRetailSP",false);
                component.set("v.isCorporateSP",true);
                var updatedExp = component.get("v.serviceplanid");
                helper.helperRefreshServicePlan(component, updatedExp); 
                if(!$A.util.isUndefinedOrNull(component.find("ServicePlanID"))) component.find("ServicePlanID").set("v.value", "");
                else component.find("ServicePlanID1").set("v.value", "");                
                var servicePlanScheme = component.get("v.servicePlanScheme");
                var servicePlanSchemeName = component.get("v.servicePlanSchemeName");
                console.log('servicePlanScheme  '+servicePlanScheme);
                console.log('servicePlanSchemeName  '+servicePlanSchemeName);
                if(servicePlanSchemeName){
                    component.find("plan-record").set("v.inputValue",servicePlanSchemeName); 
                }
                
            }else if(event.getSource().getLocalId() == 'RemoveSP'){
                component.find("Assignment_Type__c").set("v.value",""); 
                component.find("retailSP").set("v.checked",false);  
                component.find("CorporateSP").set("v.checked",false); 
                component.set("v.isRetailSP",false);
                component.set("v.isCorporateSP",false);
                if(!$A.util.isUndefinedOrNull(component.find("ServicePlanID"))) component.find("ServicePlanID").set("v.value", "");
                else component.find("ServicePlanID1").set("v.value", "");
            }
        }else{
            if(event.getSource().getLocalId() == 'retailSP'){
                component.find("Assignment_Type__c").set("v.value","");
                component.find("ServicePlanID1").set("v.value", "");
                component.find('ServicePlanID1').set('v.disabled', true);
                component.set("v.opportunityLineItem",null); 
                
            }else if(event.getSource().getLocalId() == 'CorporateSP'){   
                component.find("Assignment_Type__c").set("v.value",""); 
                // component.set("v.servicePlanScheme",undefined);
            } 
        }
        
        if(!component.find("CorporateSP").get("v.checked") && !component.find("retailSP").get("v.checked") ){
            component.find("Assignment_Type__c").set("v.value","");
            component.set("v.opportunityLineItem",null); 
            if(!$A.util.isUndefinedOrNull(component.find("ServicePlanID"))) component.find("ServicePlanID").set("v.value", "");
            else component.find("ServicePlanID1").set("v.value", "");
        }
    },
    
    setFMOType : function(component, event, helper) {
        component.set("v.istempFMOFlag",!component.get("v.istempFMOFlag"));
        component.set("v.isFMO",component.get("v.istempFMOFlag"));        
    },
    handleOnLoad: function(component, event, helper) {
        helper.setupAsset(component, component.get('v.defaultRDA').Asset__c);
        //helper.setupOpp(component, component.get('v.defaultRDA').Opportunity__c);
        //helper.setupOpp(component, component.get('v.oppid'));
    }
})