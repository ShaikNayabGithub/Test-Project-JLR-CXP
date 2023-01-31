({
    doInit: function (component, event, helper) {
        let recordId=component.get("v.recordId");
        var urlString = window.location.href;
 		var baseURL = urlString.substring(0, urlString.indexOf("/s"));
        
          if(baseURL.includes('.force.com/CXP'))
        {
          component.set("v.isEnabled", true); 
            if(recordId===null || recordId==='')
            {
               var halfLink=urlString.substring(urlString.indexOf("/006")+1);
                if(halfLink!==null && halfLink !==undefined)
                 {
                  recordId=halfLink.substring(0, halfLink.indexOf("/"));
                 }
            }
        }else{
           var toastEvent = $A.get("e.force:showToast");
           toastEvent.setParams({"title":"Alert", "type":"error", "message":"This functionality is not Enabled for you. Ask your Administrator for help or to request access."});
           toastEvent.fire(); 
           $A.get("e.force:closeQuickAction").fire();
        }
        
        if(recordId.startsWith("006"))
        {
            component.set("v.opportunityId", recordId);
            component.set("v.QuoteId", null); 
        }else{
            component.set("v.opportunityId", null);
            component.set("v.QuoteId", recordId);  
        }
        helper.initQuoteJshelper(component, event, helper);
    },
    
    /*showSpinner:  function(component, event) {
        var spinner = component.find('Id_spinner');
        $A.util.removeClass(spinner, "slds-hide");
    },
    hideSpinner :  function(component, event) {
        var spinner = component.find('Id_spinner');
        $A.util.addClass(spinner, "slds-hide");
    },*/
    
    getNewVehVinJs : function (component, event, helper) {
        const searchString=component.get("v.searchVin");
        const objQuote=component.get("v.quoteInitWrap");
        if (searchString.length >= 3) {
            //Ensure that not many function execution happens if user keeps typing
            if (component.get("v.inputSearchNewVeh")) {
                clearTimeout(component.get("v.inputSearchNewVeh"));
            }
            
            var inputTimer = setTimeout($A.getCallback(function () {
                helper.searchNewVehVin(component, searchString, objQuote.brandId);
            }), 1000);
            component.set("v.inputSearchNewVeh", inputTimer);
        } else{
            component.set("v.newVehVinResults", []);
            component.set("v.openNewVehDropDown", false); 
        }
        
    },
    
    checkModels: function (component, event, helper) {
        const searchString=component.get("v.searchVin");
        let quoteInitWrap= component.get("v.quoteInitWrap");
        const isOpen= component.get("v.openNewVehDropDown");
        if(searchString !=quoteInitWrap.quoteObj.VIN__c && !isOpen)
        {
            quoteInitWrap.quoteObj.VIN__c=null;
            quoteInitWrap.Derivatives=[];
            quoteInitWrap.Models=[];
            quoteInitWrap.quoteObj.Model__c=null;
            quoteInitWrap.quoteObj.Derivative__c=null;
            quoteInitWrap.quoteObj.Exterior_Color__c=null;
            quoteInitWrap.quoteObj.Interior_color__c=null;
            component.set("v.searchVin","");
            component.set("v.quoteInitWrap",quoteInitWrap);
            helper.refreshModels(component, event, helper);
            component.set("v.newVehVinResults", []);
            component.set("v.openNewVehDropDown", false); 
        }
        
    },
    
    clearOption :function (component, event, helper) {
        let quoteInitWrap= component.get("v.quoteInitWrap");
        quoteInitWrap.quoteObj.VIN__c=null;
        quoteInitWrap.Derivatives=[];
        quoteInitWrap.Models=[];
        quoteInitWrap.quoteObj.Model__c=null;
        quoteInitWrap.ModelName=null;
        quoteInitWrap.quoteObj.Derivative__c=null;
        quoteInitWrap.quoteObj.Exterior_Color__c=null;
        quoteInitWrap.quoteObj.Interior_color__c=null;
        component.set("v.searchVin",null);
        component.set("v.quoteInitWrap",quoteInitWrap);
        helper.refreshModels(component, event, helper);
        component.set("v.newVehVinResults", []);
        component.set("v.openNewVehDropDown", false);
    },
    
    newVehOptionClickHandler : function (component, event, helper) {
        
        const selectedValue = event.target.closest('li').dataset.value;
        const selectedId = event.target.closest('li').dataset.id;
        const allVins=component.get("v.newVehVinResults");
        var models = [];
        var derivatives = [];
        let quoteInitWrap= component.get("v.quoteInitWrap");
        quoteInitWrap.quoteObj.VIN__c=selectedValue;
        quoteInitWrap.quoteObj.Model__c=allVins[selectedId].Model__c;
        models.push(allVins[selectedId].Model__r.Model_Alternative__c);
        quoteInitWrap.Models=models;
        derivatives.push({
            label: allVins[selectedId].Derivative__r.Name,
            value: allVins[selectedId].Derivative__c
        });
        quoteInitWrap.Derivatives=derivatives;
        quoteInitWrap.quoteObj.Derivative__c=allVins[selectedId].Derivative__c;
        quoteInitWrap.quoteObj.Exterior_Color__c=allVins[selectedId].Exterior_Colour__c;
        quoteInitWrap.quoteObj.Interior_color__c=allVins[selectedId].Interior_Color__c;
        
        var complementoryItems=quoteInitWrap.complementaryProdLst;
            
            if(complementoryItems[0].uniqueName=='servicePlan')
            {
                complementoryItems.splice(0,1); 
            }
        
        if(allVins[selectedId].Derivative__c !=null && allVins[selectedId].Derivative__r.Service_Plan__c !=null && allVins[selectedId].Derivative__r.Service_Plan__r.Service_Plan_Type__c=='Complimentary Service' && allVins[selectedId].Derivative__r.Service_Plan__r.IsActive)
        {
            let servicePlan='Servicing '+allVins[selectedId].Derivative__r.Service_Plan__r.Months__c/12 +' years or '+allVins[selectedId].Derivative__r.Service_Plan__r.Miles_Kilometers__c+'km';
        	
            
            complementoryItems.splice(0,0,{
                            productName: servicePlan,
                            isSelected: true,
                            inputPrice:0,
                            inputType:'Checkbox',
                            uniqueName:'servicePlan',
                            orderNo:0
                        });
            
        }
        quoteInitWrap.complementaryProdLst=complementoryItems;
        component.set("v.openNewVehDropDown", false);
        component.set("v.quoteInitWrap", quoteInitWrap);
        component.set("v.searchVin", selectedValue);
    },
    
    /*getTradeInVinJs : function (component, event, helper) {
        const objQuote=component.get("v.quoteInitWrap");
        const searchString =objQuote.quoteObj.Vehicle_No__c;
        if (searchString.length >= 3) {
            //Ensure that not many function execution happens if user keeps typing
            if (component.get("v.inputSearchTradeIn")) {
                clearTimeout(component.get("v.inputSearchTradeIn"));
            }
            
            var inputTimer = setTimeout($A.getCallback(function () {
                helper.searchTradeInVin(component, searchString, objQuote.brandId);
            }), 1000);
            component.set("v.inputSearchTradeIn", inputTimer);
        } else{
            component.set("v.trdeInVinResults", []);
            component.set("v.openTradeInDropDown", false);
        }
    },
    
    tradeInOptionClickHandler : function (component, event, helper) {
        const selectedValue = event.target.closest('li').dataset.value;
        let quoteInitWrap= component.get("v.quoteInitWrap");
        quoteInitWrap.quoteObj.Vehicle_No__c=selectedValue;
        component.set("v.openTradeInDropDown", false);
        component.set("v.quoteInitWrap", quoteInitWrap);
    },*/
    
    saveButton: function(component, event, helper) {
        //var whichOne = event.getSource().getLocalId();
        component.set("v.buttonClicked",'button1');
        document.getElementById('editForm').click();
    },
    
    saveAsButton: function(component, event, helper) {
        component.set("v.buttonClicked",'button2');
        document.getElementById('editForm').click();
    },
    
    handleSubmitJs : function (component, event, helper) {
        event.preventDefault();
        const quoId=component.get("v.QuoteId");
        const insComp1=component.get("v.otherInsuranceComp1");
        const insComp2=component.get("v.otherInsuranceComp2");
        const financeComp=component.get("v.otherFinanceComp");
        
        var fields = event.getParam('fields');
        const buttonClicked=component.get("v.buttonClicked");
        const QuoteWrap=component.get("v.quoteInitWrap");
        var quoteObj;
        if(quoId==null || quoId==''){
            quoteObj= fields;
        }
        else if(buttonClicked=='button2'){
            quoteObj=QuoteWrap.quoteObj;
            quoteObj.Id=null;
        }else {
            quoteObj=QuoteWrap.quoteObj; 
        }
        var spinner = component.find('Id_spinner');
        $A.util.removeClass(spinner, "slds-hide");
        
        if(quoteObj.Insurance_Company__c=='Other')
        {
            quoteObj.Insurance_Company__c=insComp1; 
        }
        
        if(quoteObj.Insurance_Company_2__c=='Other')
        {
            quoteObj.Insurance_Company_2__c=insComp2; 
        }
        
        if(quoteObj.Finance_Company__c=='Other')
        {
            quoteObj.Finance_Company__c=financeComp; 
        }
        
        let compLst=QuoteWrap.complementaryProdLst;
        let action= component.get("c.saveQuoteApex");
        action.setParams({"Quote": quoteObj,"complementaryProdStr":JSON.stringify(QuoteWrap.complementaryProdLst)});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                const result=response.getReturnValue();
                helper.generateDoc(component, event, helper,result);                
            }
            else if(state === "ERROR"){
                var errors = action.getError();
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
        });
        $A.enqueueAction(action);
    },
    
    refreshDerivative: function (component, event, helper) {
        let Alldetails=component.get("v.quoteInitWrap");
        const modelSelected=Alldetails.ModelName;
        
        if(modelSelected==null || modelSelected==''){
            Alldetails.quoteObj.Derivative__c='';
            Alldetails.Derivatives=[];
            component.set("v.quoteInitWrap",Alldetails);
        }else{
            var spinner = component.find('Id_spinner');
            $A.util.removeClass(spinner, "slds-hide"); 
            
            let action= component.get("c.getDerivatives");
            action.setParams({"Model": modelSelected, "CountryIsoCode":Alldetails.userDetail.countryIsoCode});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === 'SUCCESS') {
                    const result=response.getReturnValue();
                    Alldetails.Derivatives=result;
                    component.set("v.quoteInitWrap",Alldetails);
                    $A.util.addClass(spinner, "slds-hide"); 
                }
            });
            $A.enqueueAction(action); 
        }
    },
    
    refreshSP: function (component, event, helper) {
        let Alldetails=component.get("v.quoteInitWrap");
        const derivativeSelected=Alldetails.quoteObj.Derivative__c;
        var complementoryItems=Alldetails.complementaryProdLst;
        
        if(derivativeSelected==null || derivativeSelected==''){
            
            if(complementoryItems[0].uniqueName=='servicePlan')
            {
                complementoryItems.splice(0,1); 
            }
            Alldetails.complementaryProdLst=complementoryItems;
            component.set("v.quoteInitWrap",Alldetails);            
        }else{
            var spinner = component.find('Id_spinner');
            $A.util.removeClass(spinner, "slds-hide"); 
            
            let action= component.get("c.getSpDetails");
            action.setParams({"derivativeId": derivativeSelected});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === 'SUCCESS') {
                    const result=response.getReturnValue();
                    if(complementoryItems[0].uniqueName=='servicePlan')
                    {
                        complementoryItems.splice(0,1); 
                    }
                    if(result !=null && result!='')
                    {
                        complementoryItems.splice(0,0,{
                            productName: result,
                            isSelected: true,
                            inputPrice:0,
                            inputType:'Checkbox',
                            uniqueName:'servicePlan',
                            orderNo:0
                        });
                        
                    }
                    
                    Alldetails.complementaryProdLst=complementoryItems;
                    component.set("v.quoteInitWrap",Alldetails);
                    $A.util.addClass(spinner, "slds-hide"); 
                }
            });
            $A.enqueueAction(action); 
        }
    },
    
    resetCurrencyToZero: function (component, event, helper) {
        if(event.getSource().get("v.value")=='' || event.getSource().get("v.value").trim()=='')
            event.getSource().set('v.value',0);
    },
    
    resetModel : function(component, event, helper)
    {
      const selectedId = event.target.closest('li').dataset.id;
      let Alldetails=component.get("v.quoteInitWrap");
       Alldetails.quoteObj.Model__c=selectedId;
       component.set("v.quoteInitWrap",Alldetails); 
    },
    
    resetInsuranceFields: function (component, event, helper) {
        const wrapValues=component.get("v.quoteInitWrap");
        if(wrapValues.quoteObj.Loan_Amount__c=='' || wrapValues.quoteObj.Loan_Amount__c==0)
        {
            component.find("Loan_Amount__c").set("v.value", 0);
            component.find("Tenure__c").set("v.value", null);
            component.find("Interest_Rate__c").set("v.value", null);
        }
        
        if(wrapValues.quoteObj.Insurance_Company__c==='' || wrapValues.quoteObj.Insurance_Company__c===null)
        {
            component.find("Insurance_Premium__c").set("v.value", 0);
        }
        
        if(wrapValues.quoteObj.Insurance_Company_2__c==='' || wrapValues.quoteObj.Insurance_Company_2__c===null)
        {
            component.find("Insurance_Premium_2__c").set("v.value", 0);
        }
        
        if(wrapValues.quoteObj.Finance_Company__c==='' || wrapValues.quoteObj.Finance_Company__c===null)
        {
            component.find("Loan_Amount__c").set("v.value", 0);
            component.find("Tenure__c").set("v.value", null);
            component.find("Interest_Rate__c").set("v.value", null);
            component.find("Lease_Offer__c").set("v.value", 0);
        }
        
        /*if(ischanged)
        {
            //component.set("v.quoteInitWrap",wrapValues);
            //component.find("Insurance_Company__c").set("v.value", wrapValues.quoteObj.Insurance_Company__c);
            //component.find("Insurance_Company_2__c").set("v.value", wrapValues.quoteObj.Insurance_Company_2__c);
            //component.find("Finance_Company__c").set("v.value", wrapValues.quoteObj.Finance_Company__c);
        }*/
    }
})