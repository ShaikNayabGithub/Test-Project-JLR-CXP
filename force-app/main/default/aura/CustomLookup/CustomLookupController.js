({
    onfocus : function(component,event,helper){
        $A.util.addClass(component.find("mySpinner"), "slds-show");
        var forOpen = component.find("searchRes");
        $A.util.addClass(forOpen, 'slds-is-open');
        $A.util.removeClass(forOpen, 'slds-is-close');
        var getInputkeyWord = '';
        
        var searchtype = component.get("v.searchtype");
        var brandValue = component.get("v.brandValue");
        console.log('searchtype --> '+searchtype);
        console.log('brandValue --> '+brandValue);
        if(searchtype == 'Partner'){
            helper.searchHelper(component,event,getInputkeyWord);
        }else  if(searchtype == 'Vehicle' || searchtype == 'VehicleBrand'){
            helper.searchVehicleHelper(component,event,getInputkeyWord);
        } if(searchtype == 'Contact_Data'){
            helper.searchContactData(component,event,getInputkeyWord);
        }
    },
    onblur : function(component,event,helper){       
        component.set("v.listOfSearchRecords", null );
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
    keyPressController : function(component, event, helper) {
        var getInputkeyWord = component.get("v.SearchKeyWord");
        if( getInputkeyWord.length > 0 ){
            var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
            
            var searchtype = component.get("v.searchtype");
            console.log('searchtype --> '+searchtype);
            
            var brandValue = component.get("v.brandValue");
            console.log('brandValue --> '+brandValue);
            
            if(searchtype == 'Partner'){
                helper.searchHelper(component,event,getInputkeyWord);
            }else  if(searchtype == 'Vehicle' || searchtype == 'VehicleBrand'){
                helper.searchVehicleHelper(component,event,getInputkeyWord);
            }if(searchtype == 'Contact_Data'){
                helper.searchContactData(component,event,getInputkeyWord);
            }
        }
        else{  
            component.set("v.listOfSearchRecords", null ); 
            var forclose = component.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
        }
    },
    clear :function(component,event,heplper){
        var pillTarget = component.find("lookup-pill");
        var lookUpTarget = component.find("lookupField"); 
        
        $A.util.addClass(pillTarget, 'slds-hide');
        $A.util.removeClass(pillTarget, 'slds-show');
        
        $A.util.addClass(lookUpTarget, 'slds-show');
        $A.util.removeClass(lookUpTarget, 'slds-hide');
        
        component.set("v.SearchKeyWord",null);
        component.set("v.listOfSearchRecords", null );
        component.set("v.selectedRecord", {} );  
        
        var searchtype = component.get("v.searchtype");
        if(searchtype != null && searchtype == 'VehicleBrand'){
            var cmpEvent = component.getEvent("FinanceContractEvent");
            cmpEvent.setParams({
                "message" : "Clear",
                "recordType" : "Clear_Vehicle" 
            });
            cmpEvent.fire();
        }
    },
    
    handleComponentEvent : function(component, event, helper) {
        var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        component.set("v.selectedRecord" , selectedAccountGetFromEvent); 
        
        var forclose = component.find("lookup-pill");
        $A.util.addClass(forclose, 'slds-show');
        $A.util.removeClass(forclose, 'slds-hide');
        
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
        
        var lookUpTarget = component.find("lookupField");
        $A.util.addClass(lookUpTarget, 'slds-hide');
        $A.util.removeClass(lookUpTarget, 'slds-show');  
        
    }
})