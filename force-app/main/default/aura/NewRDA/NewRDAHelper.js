/*
* S.No.		Name		Date(DD/MM/YYYY)	Change 
* 1.0		Ashwin 		05/08/2021			CXPD-1434: Prevent submit when Add Corporate SP
*											is selected and Corporate Account SP is not selected
* 
*/
({
    
    labelSetter : function(component, labelobject, labelmap) {
        var searchRdaAction = component.get("c.getFieldLabel");
        searchRdaAction.setParams({objectName : labelobject});
        searchRdaAction.setCallback(this, function(rdaFieldLabelMap) {
            var rdastate = rdaFieldLabelMap.getState();
            if(rdastate === 'SUCCESS'){
                component.set(labelmap, rdaFieldLabelMap.getReturnValue());                
            }
        });
        $A.enqueueAction(searchRdaAction);
    },
    
    getAffinityProgramStatusHelper : function(component) {
        var ProgramStatusAction = component.get("c.getAffinityProgramStatus");
        ProgramStatusAction.setCallback(this, function(retuVal) {
            var rdastate = retuVal.getState();
            if(rdastate === 'SUCCESS'){
                component.set("v.affinityProgramStatus", retuVal.getReturnValue());                
                console.log('affinityProgramStatus --> '+JSON.stringify(component.get("v.affinityProgramStatus")));
                var affinityProgramStatus = component.get("v.affinityProgramStatus");
                if(affinityProgramStatus != null)
                    if(!affinityProgramStatus.Affinity_Disabled__c){
                        component.set("v.showCorporatePlan",true);
                    }else if(affinityProgramStatus.Affinity_Disabled__c){
                        component.set("v.showCorporatePlan",false);
                    }
            }
        });
        $A.enqueueAction(ProgramStatusAction);
    },
    
    simulateServerRequest: function (component) {
        var searchValues = component.get("c.getDropdownCommonSaleType");
        searchValues.setCallback(this, function(commonTypeList) {
            var ctsState = commonTypeList.getState();
            var serverResponse;
            if(ctsState === 'SUCCESS' &&  commonTypeList.getReturnValue() != null){
                var asset =  component.get('v.asset');
                var i;
                var isSelected = false;
                var csts = [];
                for (i = 0; i < commonTypeList.getReturnValue().length; i++) {
                    if(asset != null && asset.Common_Sale_Type__c != null && asset.Common_Sale_Type__c == commonTypeList.getReturnValue()[i] ){
                        component.set('v.selectedValue',i);  
                        isSelected = true;
                        csts.push({
                            id: i, label: commonTypeList.getReturnValue()[i], selected: true  
                        }); 
                    }else{
                        csts.push({
                            id: i, label: commonTypeList.getReturnValue()[i]
                        });
                    }
                }
                if(!isSelected){
                    var asset =  component.get('v.asset');
                    asset.Common_Sale_Type__c = null;
                    component.set("v.asset",asset);
                    i++;
                    csts.push({
                        id: i, label: null, selected: true, value:null }); 
                }
                component.set('v.options', csts);
            }
        });
        $A.enqueueAction(searchValues);
    },
    
    setupServicePlan : function(component, passedOpportunityId,helper){    
        console.log('setupServicePlan --> ');
        var setupService = component.get("c.getServicePlan");
        setupService.setParams({opportunityId : passedOpportunityId});
        setupService.setCallback(this, function(opplineDetail) {
            console.log('setupServicePlan --> '+opplineDetail.getState());
            if(opplineDetail.getState() === 'SUCCESS'){
                component.set('v.opportunityLineItem', opplineDetail.getReturnValue()); 
                console.log('opportunityLineItem --> '+JSON.stringify(component.get('v.opportunityLineItem')));
                if(!$A.util.isUndefinedOrNull(opplineDetail.getReturnValue())){
                    component.find("Assignment_Type__c").set("v.value",opplineDetail.getReturnValue().Assignment_Type__c);
                    if(opplineDetail.getReturnValue().Assignment_Type__c == 'Retail'){
                        component.set("v.isRetailSP",true);
                        component.set("v.isCorporateSP",false);
                        if(!$A.util.isUndefinedOrNull(component.find("CorporateSP"))){
                            component.find("CorporateSP").set("v.checked",false); 
                        }
                        if(!$A.util.isUndefinedOrNull(component.find("retailSP"))){
                            component.find("retailSP").set("v.checked",true);
                        }
                        
                        helper.getAffinityProgramStatusHelper(component);
                        
                    }else if(opplineDetail.getReturnValue().Assignment_Type__c == 'Complimentary'){
                        component.set("v.isRetailSP",false);
                        component.set("v.isCompSP",true);
                        component.set("v.isCorporateSP",false);
                        if(!$A.util.isUndefinedOrNull(component.find("CorporateSP"))){
                            component.find("CorporateSP").set("v.checked",false); 
                        }
                        if(!$A.util.isUndefinedOrNull(component.find("retailSP"))){
                            component.find("retailSP").set("v.checked",false);
                        }
                        
                        helper.getAffinityProgramStatusHelper(component);
                    }else if(opplineDetail.getReturnValue().Assignment_Type__c == 'Corporate'){
                        component.set("v.isCorporateSP",true);
                        component.set("v.showCorporatePlan",true);
                        
                        if(!$A.util.isUndefinedOrNull(component.find("CorporateSP"))){
                            component.find("CorporateSP").set("v.checked",true); 
                        }
                        if(!$A.util.isUndefinedOrNull(component.find("retailSP"))){
                            component.find("retailSP").set("v.checked",false);
                        }
                        component.set("v.isRetailSP",false);
                        if(!$A.util.isUndefinedOrNull(opplineDetail.getReturnValue().Opportunity ) && !$A.util.isUndefinedOrNull(opplineDetail.getReturnValue().Opportunity.Corporate_Partner_Account__r ) ){
                            var a =    opplineDetail.getReturnValue().Opportunity.Corporate_Partner_Account__r.Name;
                            var servicePlanScheme =    opplineDetail.getReturnValue().Opportunity.Corporate_Partner_Account__c;
                            component.find("plan-record").set("v.inputValue",a); 
                            if(a){//1.0
                                component.set("v.showCorpAccSPErrorMsg", false);
                                component.set("v.servicePlanScheme", servicePlanScheme);
                                component.set("v.servicePlanSchemeName", a);
                                console.log('servicePlanScheme -->  '+component.get("v.servicePlanScheme"));
                                console.log('servicePlanSchemeName -->  '+component.get("v.servicePlanSchemeName"));
                            }
                        }
                    }else{
                        helper.getAffinityProgramStatusHelper(component);
                    }
                } 
            }
        });
        $A.enqueueAction(setupService);
    },
    
    helperRefreshServicePlan : function(component, passedProductId){
        console.log('entering helperRefreshServicePlan');
        var setupService = component.get("c.refreshServicePlan");
        var passedOppId =  component.get('v.oppid');
        var assetProductId;
        var passedIsRetailer =  component.get('v.isRetailSP');

        if(passedOppId == null && passedProductId == null) {
            var asset = component.get('v.asset');
            assetProductId = asset.Product2Id;
        }
        setupService.setParams({productId : passedProductId,opportunityId : passedOppId, assetProductId : assetProductId});
        setupService.setCallback(this, function(opplineDetail) {
            if(opplineDetail.getState() === 'SUCCESS'){
                component.set('v.opportunityLineItem', opplineDetail.getReturnValue()); 
                component.set("v.retailSP",opplineDetail.getReturnValue().Product2.Id);
                component.set('v.opportunityLineItem.Product2Id',opplineDetail.getReturnValue().Product2.Id);
                //component.find('ServicePlanID1').set('v.disabled', false); 
            }
        });
        $A.enqueueAction(setupService);
    },
    
    setupAsset : function(component, passedAssetId){
        var setupAsset = component.get("c.getAsset");
        setupAsset.setParams({assetId : passedAssetId});
        setupAsset.setCallback(this, function(assetDetail) {
            if(assetDetail.getState() === 'SUCCESS'){
                component.set('v.asset', assetDetail.getReturnValue()); 
                console.log('defafultAsset --->  '+JSON.stringify(assetDetail.getReturnValue()));
                if(!$A.util.isUndefinedOrNull(assetDetail.getReturnValue().Derivative__c) && !$A.util.isUndefinedOrNull(assetDetail.getReturnValue().Derivative__r.Service_Plan__c)  ){
                    component.set("v.retailSP", assetDetail.getReturnValue().Derivative__r.Service_Plan__c);
                }
            }
        });
        $A.enqueueAction(setupAsset);
    },
    
    setupExistingServicePlan : function(component, passedAssetId){
        var setupExistingSP = component.get("c.getExistingSP");
        setupExistingSP.setParams({assetId : passedAssetId});
        setupExistingSP.setCallback(this, function(esDetail) {
            if(esDetail.getState() === 'SUCCESS'){
                if(!$A.util.isUndefinedOrNull(esDetail.getReturnValue()) && !$A.util.isUndefinedOrNull(esDetail.getReturnValue().length) && esDetail.getReturnValue().length > 0 ){
                    component.set('v.servicePlanContracts',esDetail.getReturnValue());
                    component.set('v.opportunityLineItem',null);
                    component.find("Assignment_Type__c").set("v.value",""); 
                }
            }
        });
        $A.enqueueAction(setupExistingSP);
    },
    
    setupComplimentaryServicePlan : function(component, passedAssetId){
        var rdaType =  component.get('v.rdaType');
        if(rdaType != null && (rdaType == 'Dealer_Owned' || rdaType == 'OUV')){
            var setupCompSP = component.get("c.getComplimentaryOffer");
            setupCompSP.setParams({assetId : passedAssetId});
            setupCompSP.setCallback(this, function(compSDetail) {
                if(compSDetail.getState() === 'SUCCESS'){
                    if(!$A.util.isUndefinedOrNull(compSDetail.getReturnValue()) && !$A.util.isUndefinedOrNull(compSDetail.getReturnValue().Product2)){
                        component.set('v.opportunityLineItem', compSDetail.getReturnValue());   
                        component.set('v.opportunityLineItem.Product2Id',compSDetail.getReturnValue().Product2.Id);
                        component.find("Assignment_Type__c").set("v.value","Complimentary"); 
                        component.set("v.isCompSP",true);
                    }
                }
            });
            $A.enqueueAction(setupCompSP); 
        }
    },
    
    setupOpp : function(component, passedOppId){
        console.log(' Enter Default Opportunities--->  ');
        var setupOpp = component.get("c.getOpportunity");
        setupOpp.setParams({opportunityId : passedOppId});
        console.log('Default Opportunities ID--->  ' + passedOppId);
        setupOpp.setCallback(this, function(oppDetail) {
            if(oppDetail.getState() === 'SUCCESS'){
                component.set('v.opportunity', oppDetail.getReturnValue()); 
                console.log('Default Opportunities--->  '+JSON.stringify(oppDetail.getReturnValue()));
                if(oppDetail.getReturnValue().Primary_Contact__c != null){
                    component.set('v.contactid', oppDetail.getReturnValue().Primary_Contact__r.Id);
                }
                if(oppDetail.getReturnValue().Trade_In__c  != null && oppDetail.getReturnValue().Trade_In__c == true){
                    //  Trade_in_Mileage__c , Trade_In_Brand_Lookup__c ,  Revised_Trade_in_Model__c, Trade_in_Registration_Number__c, Model_Year__c, Revised_Trade_in_Value__c ,Service_History__c , JLR_Trade_In__c ,*/
                    component.set('v.isTradeIn', true);  
                    component.find("Service_History__c").set("v.value",oppDetail.getReturnValue().Service_History__c); 
                    component.find("Trade_in_JLR_Vehicle__c").set("v.value",oppDetail.getReturnValue().JLR_Trade_In__c); 
                    
                    if(oppDetail.getReturnValue().JLR_Trade_In__c){
                        component.set('v.isJLRTradeIn', true);
                        this.setupTradeInAsset(component,oppDetail.getReturnValue().Trade_in_Registration_Number__c);
                    }
                    if(!$A.util.isUndefinedOrNull( component.find("Trade_In_Make__c"))){
                        component.find("Trade_In_Make__c").set("v.value",oppDetail.getReturnValue().Trade_In_Brand_Lookup__c); 
                    }
                    if(!$A.util.isUndefinedOrNull(    component.find("Trade_In_Model__c"))){
                        component.find("Trade_In_Model__c").set("v.value",oppDetail.getReturnValue().Trade_In_Model_Lookup__c );
                    }
                    if(!$A.util.isUndefinedOrNull(component.find("vinENT"))){
                        component.find("vinENT").set("v.value",oppDetail.getReturnValue().Trade_in_Registration_Number__c);
                    }
                    if(!$A.util.isUndefinedOrNull( component.find("Trade_In_Value__c"))){
                        component.find("Trade_In_Value__c").set("v.value",oppDetail.getReturnValue().Revised_Trade_in_Value__c); 
                    }
                    if(!$A.util.isUndefinedOrNull( component.find("Kilometres_Mileage__c"))){
                        component.find("Kilometres_Mileage__c").set("v.value",oppDetail.getReturnValue().Trade_in_Mileage__c); 
                    }
                    component.find("Trade_in_Vehicle__c").set("v.value",true); 
                }
            }
        });
        $A.enqueueAction(setupOpp);
    },
    
    setupAccount : function(component, passedOppId){
        var setupAccount = component.get("c.getAccount");
        setupAccount.setParams({accountId : passedOppId});
        setupAccount.setCallback(this, function(oppDetail) {
            if(oppDetail.getState() === 'SUCCESS'){
                console.log('-->   '+JSON.stringify(setupAccount.getReturnValue()));
                component.set('v.account', setupAccount.getReturnValue()); 
                var personTile = component.get("v.account.PersonTitle");
                if(personTile){
                    component.set("v.defaultRDA.Title__c",personTile);  
                }
            }
        });
        $A.enqueueAction(setupAccount);
    }, 
    
    refreshLocalityC : function(component, passedpost){
        var   passedCity = component.find("cityIDC").get("v.value");
        var setupLocality = component.get("c.refreshLocations");
        setupLocality.setParams({billingPostalCode : passedpost,billingCity : passedCity });
        
        setupLocality.setCallback(this, function(localityDetail) {
            if(localityDetail.getState() === 'SUCCESS'){
                component.set('v.availableLocalities', localityDetail.getReturnValue());
                if(localityDetail.getReturnValue().length == 1){
                    var local = localityDetail.getReturnValue()[0];                   
                }
                
            }
        });
        $A.enqueueAction(setupLocality);
    },
    
    refreshLocalityA : function(component, passedpost){
        var   passedCity = component.find("cityIDA").get("v.value");
        var setupLocality = component.get("c.refreshLocations");
        setupLocality.setParams({billingPostalCode : passedpost,billingCity : passedCity });
        
        setupLocality.setCallback(this, function(localityDetail) {
            if(localityDetail.getState() === 'SUCCESS'){
                component.set('v.availableLocalities', localityDetail.getReturnValue());
                if(localityDetail.getReturnValue().length == 1){
                    var local = localityDetail.getReturnValue()[0];
                    
                }
                
            }
        });
        $A.enqueueAction(setupLocality);
    },
    
    setupLocality : function(component, passedAccountId){
        component.set('v.accountid', passedAccountId);
        var con = component.get('v.oppid');
        
        var setupLocality = component.get("c.getLocations");
        setupLocality.setParams({accountId : passedAccountId, oppId : con});
        setupLocality.setCallback(this, function(localityDetail) {
            if(localityDetail.getState() === 'SUCCESS'){
                component.set('v.availableLocalities', localityDetail.getReturnValue());
                if(localityDetail.getReturnValue().length == 1){
                    var local = localityDetail.getReturnValue()[0];                    
                    if(component.find("cityIDA") != null && component.find("stateIDA") != null){
                        component.find("cityIDA").set("v.value",local.Name);
                        component.find("stateIDA").set("v.value",local.State__c);
                    }
                    if(component.find("cityIDC") != null && component.find("stateIDC") != null){
                        component.find("cityIDC").set("v.value",local.Name);
                        component.find("stateIDC").set("v.value",local.State__c);
                    }
                }
            }
        });
        $A.enqueueAction(setupLocality);
    },
    
    setLoyaltyTransaction: function(component){
        var setupLoyalty = component.get("c.getLoyaltyTransaction");
        setupLoyalty.setParams({accountId : component.get("v.accountid"), assetId :component.get("v.assetid"), recordId :component.get("v.recordId") });
        setupLoyalty.setCallback(this, function(loyaltyDetail) {            
            if(loyaltyDetail.getState() === 'SUCCESS'){
                if(!$A.util.isUndefinedOrNull(loyaltyDetail.getReturnValue())){                    
                    component.set('v.loyaltyTransaction', loyaltyDetail.getReturnValue());
                }
            }
        });
        $A.enqueueAction(setupLoyalty);
    },
    
    getChangedContactLoyaltyStatusHelper: function(component){
        var spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
        var setupLoyalty = component.get("c.getChangedContactLoyaltyStatus");
        var lname =  component.find("LPT_Account_Name__c").get("v.value");
        var scheme = component.find("LPT_Loyalty_Scheme_Reference__c").get("v.value");//'4107132';
        if(scheme != null && scheme.length > 6 ){
            
            setupLoyalty.setParams({loyalty_Scheme_Reference : scheme, name : lname });
            setupLoyalty.setCallback(this, function(LPVS) {            
                if(LPVS.getState() === 'SUCCESS'){
                    if(!$A.util.isUndefinedOrNull(LPVS.getReturnValue().successMessage)){   
                        component.set('v.isAccountEdited',true);                    
                        component.find("LPT_Loyalty_Points_Validation_Status__c").set("v.value", LPVS.getReturnValue().successMessage);
                        component.find("Loyalty_Points_Validation_Status__c").set("v.value", LPVS.getReturnValue().successMessage);
                    }
                    if(!$A.util.isUndefinedOrNull(LPVS.getReturnValue().errormessage)){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({"title":"Error", "type":"error", "message":LPVS.getReturnValue().errormessage});
                        toastEvent.fire();
                    }
                }
                var spinner = component.find("mySpinner");
                $A.util.toggleClass(spinner, "slds-hide");
            });
            $A.enqueueAction(setupLoyalty);
        }
        var spinner = component.find("mySpinner");
        $A.util.toggleClass(spinner, "slds-hide");
    },
    
    getContactLoyaltyStatusHelper: function(component){
        var setupLoyalty = component.get("c.getContactLoyaltyStatus");
        setupLoyalty.setParams({accountId : component.get("v.accountid")});
        setupLoyalty.setCallback(this, function(LPVS) {            
            if(LPVS.getState() === 'SUCCESS'){
                if(!$A.util.isUndefinedOrNull(LPVS.getReturnValue().successMessage)){   
                    component.set('v.isAccountEdited',true);                    
                    component.find("LPT_Loyalty_Points_Validation_Status__c").set("v.value", LPVS.getReturnValue().successMessage);
                    component.find("Loyalty_Points_Validation_Status__c").set("v.value", LPVS.getReturnValue().successMessage);
                }
                if(!$A.util.isUndefinedOrNull(LPVS.getReturnValue().errormessage)){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({"title":"Error Validating Membership", "type":"error", "message":LPVS.getReturnValue().errormessage});
                    toastEvent.fire();
                }
            }
            var spinner = component.find("mySpinner");
            $A.util.toggleClass(spinner, "slds-hide");
        });
        $A.enqueueAction(setupLoyalty);
    },   
    
    setupTradeInAsset : function(component, passedString){
        if(passedString != null && passedString != '' && passedString.length > 4 ){            
            var TradeInAssets = component.get("c.getTradeInAssets");
            TradeInAssets.setParams({search : passedString});
            TradeInAssets.setCallback(this, function(assetDetails) {
                if(assetDetails.getState() === 'SUCCESS'){                    
                    if(assetDetails.getReturnValue() != null && assetDetails.getReturnValue().length == 1){
                        var ass = assetDetails.getReturnValue()[0];                        
                        if(!$A.util.isUndefinedOrNull( component.find("vinCXP")) ){ //&& !!$A.util.isUndefinedOrNull(component.get("v.tradeInAssetId"))&&!$A.util.isUndefinedOrNull(component.get("v.tradeIn"))
                            component.find("vinCXP").set("v.value",ass);
                            component.set('v.tradeInAssetId',ass.Id);                            
                            component.set('v.tradeIn', ass);                            
                        }                      
                    }else{
                        if(!$A.util.isUndefinedOrNull( component.find("vinCXP")) ){ //&& !!$A.util.isUndefinedOrNull(component.get("v.tradeInAssetId"))&&!$A.util.isUndefinedOrNull(component.get("v.tradeIn"))
                            component.find("vinCXP").set("v.value",null);
                            component.set('v.tradeInAssetId',null);                            
                            component.set('v.tradeIn', null);                            
                        }
                    }
                }
            });
            $A.enqueueAction(TradeInAssets); 
        }
    },
    
    setFMOType : function(component, event, helper) {
        component.set("v.isFMO",event.getSource().get("v.checked") );       
    },
    
    getFMOTrueValues : function(component) {
        var trueFMOList = component.get("c.getTrueFMOList");
        trueFMOList.setCallback(this, function(result) {
            if(result.getState() === 'SUCCESS'){
                component.set('v.fmoTrueList', result.getReturnValue()); 
            }
        });
        $A.enqueueAction(trueFMOList);
    },
    
    updateAccountTitileHelper : function(component,accountId,title) {
        var trueFMOList = component.get("c.updateAccountTitle");
        trueFMOList.setParams({
            accountId : accountId,
            title : title
        });
        trueFMOList.setCallback(this, function(result) {
            if(result.getState() === 'SUCCESS'){
                console.log('updateAccountTitileHelper--->  '+JSON.stringify(result.getReturnValue()));
            }
        });
        $A.enqueueAction(trueFMOList);
    }
    
})