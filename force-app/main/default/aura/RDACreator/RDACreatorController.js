({
    performSearch : function(component, event, helper) {
        helper.initialiseSearch(component);
    },
    quatosValidation : function(component, event, helper) {        
        var buttonName = event.getSource().get("v.name").split('-');
       var userbool = component.get("v.userperset");
        console.log('new user value:' + userbool);
        component.set("v.buttonInfo",event.getSource().get("v.name"));
        if(userbool == false){
        if('Dealer_Owned'.toLowerCase() == buttonName[buttonName.length-1].toLowerCase()){
           console.log('quatos' );
            helper.quatosValidationHelper(component,event);  
        }else {
            
             helper.newRDAHelper(component, event, component.get("v.buttonInfo"));
            console.log('newone' );
        }
       }else {
            
             helper.newRDAHelper(component, event, component.get("v.buttonInfo"));
            console.log('newone123' );
        } 
    },
	accountModal:function(component,event,helper){    
        component.set("v.showModal",false);    
        component.set("v.showRDAModal", false);
        component.set("v.showAccountModal", true);
    },
    closeModal:function(component,event,helper){    
        component.set("v.showModal",false);    
        component.set("v.showRDAModal", false);
        component.set("v.showAccountModal", false);
    },
    newRDA : function(component, event, helper) {   
        component.set("v.showModal",false);    
        component.set("v.showRDAModal", false); 
        component.set("v.showAccountModal", false);
        helper.newRDAHelper(component, event, component.get("v.buttonInfo"));
    },
    setFilterToAll : function(component, event, helper) {
        component.set("v.rdaFilter", "");
    },
    setFilterToNewRetail : function(component, event, helper) {
        component.set("v.rdaFilter", "New_Retail");
    },
    setFilterToDealerOwned : function(component, event, helper) {
        component.set("v.rdaFilter", "Dealer_Owned");
    },
    setFilterToOnSell : function(component, event, helper) {
        component.set("v.rdaFilter", "On_Sell");
    },
    setFilterToOUV : function(component, event, helper) {
        component.set("v.rdaFilter", "OUV");
    },
    setFilterToTradeIn : function(component, event, helper) {
        component.set("v.rdaFilter", "Trade_In");
    },
    tradeIn : function(component, event, helper) {
        var action = component.get("c.tradeInAsset");
        var tradeInVin = component.get("v.tradeInVin");
        action.setParams({"assetVin": tradeInVin});
        action.setCallback(this, function(response) {
			var state = response.getState();
            if(state === 'SUCCESS'){
                if(response.getReturnValue() == 'Success'){
                    component.set("v.tradeInVin", "");
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({"title":"Success", "type":"info", "message":"Traded In " + tradeInVin});
                    toastEvent.fire();
                    helper.initialiseSearch(component);
                }
                else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({"title":"Error", "type":"error", "message":response.getReturnValue()});
                    toastEvent.fire();
                }
            }
        });
        $A.enqueueAction(action);
    }
})