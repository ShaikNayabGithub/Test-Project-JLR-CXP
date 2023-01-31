({
    init : function(component, event, helper) {
        const assetFound = component.get('v.assetFound');
        const currentUser= component.get("v.currentUser");
        if(currentUser.Market__c=='APIO'){
            if(assetFound!=null && assetFound.Derivative__r.Service_Plan__c!=null) {
                if(assetFound.Derivative__r.Service_Plan__r.Service_Plan_Type__c=='Paid For')
                    component.set("v.isRetailSP",true);
                else
                    component.set("v.isCompSP",true);
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({"title":"Error", "type":"error", "message":"Valid service plan does not exists."});
                toastEvent.fire(); 
            }
        }else if(currentUser.Market__c=='JP'){
            component.set("v.isCompSP",true);
            component.set("v.isJpSP",true);
            helper.getServicePlansHelper(component, event, helper);
        }
        
    }, 
    
    addSPC : function (component, event, helper) {
        
        var isRetail =  component.get('v.isRetailSP');
        var isCorp =  component.get('v.isCorporateSP');
        var isComp =  component.get('v.isCompSP');
        var inputAssetId = component.get('v.assetInputId');
        let startDate= component.get("v.StartDate");
        let isValid= true;
        const currentUser=component.get("v.currentUser");
        var offer = null;
        if(!$A.util.isUndefinedOrNull( isCorp) && !$A.util.isUndefinedOrNull( component.find("offer__c"))  ){
            offer =  component.find("offer__c").get("v.value");
            
        }
        if(!$A.util.isUndefinedOrNull( isCorp) && isCorp == true && (offer == null || offer == "") ){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({"title":"Error", "type":"error", "message":"Please Add Corporate Account For Corporate Service Plans"});
            toastEvent.fire();
            
        }else{
            if(currentUser.Market__c=='APIO' && isRetail)
            {
                var validity = component.find("dateField").get("v.validity");
                isValid=validity.valid;
            }
            if(isValid)
            {
                let spinner = component.find('Id_spinner');
                $A.util.removeClass(spinner,'slds-hide');
                var actionfunction = component.get('c.addForServicePlanContract');
                actionfunction.setParams({isRetailer: isRetail, isCorporate:isCorp , offerId:offer, assetId:inputAssetId, startDate:startDate, isCompSp:isComp });
                
                actionfunction.setCallback(this, function(response) {
                    var state = response.getState();
                    //debugger;
                    if (state === 'SUCCESS') {
                        if(response.getReturnValue() != null ){
                            
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({"title":"Success", "type":"success", "message":"Service Plan Contract Successfully created"});
                            toastEvent.fire();
                            
                            var actionEvt =component.getEvent("Actionname");
                            actionEvt.setParams({
                                "actionname": 'Close'
                            });
                            actionEvt.fire();
                            var resp = response.getReturnValue();
                            console.log('resp --> '+JSON.stringify(resp));
                            debugger;
                            if(resp != null && resp.autoAddExtService){
                                var extendedEvt =component.getEvent("Actionname");
                                extendedEvt.setParams({
                                    "actionname": 'ExtendedAdded'
                                });
                                extendedEvt.fire(); 
                            }
                            
                            
                        }else{
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({"title":"Error", "type":"error", "message":"An Error Occured Please contact your Administrator"});
                            toastEvent.fire();
                        }
                        
                    }else if(state === "ERROR"){
                        var errors = actionfunction.getError();
                        if (errors) {
                            $A.util.addClass(spinner, "slds-hide");
                            if (errors[0] && errors[0].message) {
                                $A.util.addClass(spinner, "slds-hide");
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({"title":"Error", "type":"error", "message":errors[0].message});
                                toastEvent.fire();
                            }
                        }
                    }
                    $A.util.addClass(spinner,'slds-hide');
                });
                $A.enqueueAction(actionfunction);
                
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({"title":"Error", "type":"Error", "message":"Please select start date."});
                toastEvent.fire();
            }
        }
        
        
    },
    handleUpdateExpense: function(component, event, helper) {
        var updatedExp = event.getParam("serviceplanid");
        var offerId = event.getParam("offerId");
        var corpId = event.getParam("corpId");
        console.log('offerId'+offerId);
        component.find("offer__c").set("v.value",offerId);
        
    },
    setAssignmentType : function(component, event, helper) {
        component.set("v.isCorporateSP",false);
        component.set("v.isRetailSP",false);
        if(event.getSource().get("v.checked")){
            if(event.getSource().getLocalId() == 'retailSP'){
                component.find("Assignment_Type__c").set("v.value","Retail");
                component.set("v.isRetailSP",true);
                //component.find("CorporateSP").set("v.checked",false); 	//Removed based on CXPD-1220
                
            }/*else if(event.getSource().getLocalId() == 'CorporateSP'){    //Removed based on CXPD-1220           
                    component.find("Assignment_Type__c").set("v.value","Corporate"); 
                    component.find("retailSP").set("v.checked",false);  
                    component.set("v.isRetailSP",false);
                    component.set("v.isCorporateSP",true);
                    
                }*/
        }else{
            if(event.getSource().getLocalId() == 'retailSP'){
                component.find("Assignment_Type__c").set("v.value","");
                
            }/*else if(event.getSource().getLocalId() == 'CorporateSP'){       //Removed based on CXPD-1220       
                    component.find("Assignment_Type__c").set("v.value",""); 
                }*/
        }  
    }
})