({
    doInit : function(component, event, helper) {  
         helper.getContactFieldLabelHelper(component, event, helper);
         helper.getAccountFieldLabelHelper(component, event, helper);
        helper.getModelList(component, event, helper);
         helper.getPriceBookListHelper(component, event, helper); 
        helper.getPurchaseTypeValues(component, event, helper);
        helper.getStageTypeValues(component, event, helper);
        helper.getRecordTypesHelper(component, event, helper);
        helper.getLanguageValuesHelper(component, event, helper);
       
        var todayDate = new Date();        
        todayDate.setMinutes(todayDate.getMinutes()+10);
        var newOpportunity = component.get("v.newOpportunity");
        newOpportunity.Test_Drive_Preferred_Date_Time__c = todayDate.toISOString();
        component.set("v.newOpportunity",newOpportunity);
        setTimeout(function(){
            var inputSearch= component.find("searchInput");
            inputSearch.focus();
        }, 10);  
    },
    handleClick : function(component, event, helper) {
        
        var searchText = component.get('v.searchText');
        var newButton = component.find('createButton');
        if(searchText.length > 2 ){            
            if(component.get("v.chosenOption") == 'customer') $A.util.removeClass(newButton, "slds-hide"); else $A.util.addClass(newButton, "slds-hide");
            helper.getAccountList(component, event, helper);
        }else if(searchText.length < 3){
            $A.util.addClass(newButton, "slds-hide"); 
            component.set("v.AccountList",null );
            component.set("v.contactList",null ); 
            component.set("v.assestList",null );
        }
        var opportunityDiv = component.find('opportunityDiv');
        $A.util.addClass(opportunityDiv, "slds-hide");
        var accountDiv = component.find('accountDiv');
        $A.util.addClass(accountDiv, "slds-hide");
    },
    onSelectAccount : function(component, event, helper) {
        helper.getNavigateId(component, event, helper);       
    },
    handleCreateButton : function(component, event, helper) {
        component.set("v.AccountList",null );
        component.set("v.contactList",null );
        var newAccount = component.get('v.newAccount'); 
        var searchText = component.get('v.searchText');        
        var newButton = component.find('createButton');
        $A.util.addClass(newButton, "slds-hide"); 
        console.log(searchText.trim());
        var searchSubStrings = searchText.trim().split(" ");
        console.log(searchSubStrings);
        var phonePattern = /^[0-9]/;
        var emailPattern = /\S+@\S+/;
        newAccount.FirstName = '';
        newAccount.Phone  = '';
        newAccount.PersonEmail = '';
        newAccount.LastName = '';
        component.set("v.selectedModal",'none');
        //component.set("v.nextAction",'none');
         helper.getStageTypeValues(component, event, helper);
        var todayDate = new Date();        
        todayDate.setMinutes(todayDate.getMinutes()+10);
        var newOpportunity = component.get("v.newOpportunity");
        newOpportunity.Test_Drive_Preferred_Date_Time__c = todayDate.toISOString();
        component.set("v.newOpportunity",newOpportunity);
        
        for (var i = 0; i < searchSubStrings.length; i++) {  
            if(searchSubStrings[i].match(phonePattern) || emailPattern.test(searchSubStrings[i])){
                searchText = searchText.replace(searchSubStrings[i]," ");                  
            }else{                
                var lowerCamelCase = searchSubStrings[i].toLowerCase();
                var upperCamelCase = lowerCamelCase.replace(lowerCamelCase[0], lowerCamelCase[0].toUpperCase());
                searchText = searchText.replace(searchSubStrings[i],upperCamelCase);
            }
            
            if(searchSubStrings[i].match(phonePattern) && !newAccount.Phone.match(phonePattern)){
                newAccount.Phone = searchSubStrings[i];
            }
            if(emailPattern.test(searchSubStrings[i]) && !emailPattern.test(newAccount.PersonEmail) ){
                newAccount.PersonEmail = searchSubStrings[i];  
            }
        }
        searchText= searchText.replace(/\s+/g,' ').trim();
        var nameSubStrings = searchText.split(" ");
        if(nameSubStrings.length >0){
            newAccount.LastName = nameSubStrings[nameSubStrings.length-1];
            console.log(searchText.length - newAccount.LastName.length);
            newAccount.FirstName = searchText.substring(0,searchText.length - newAccount.LastName.length);
        }
        
        component.set("v.newAccount",newAccount );
        var newButton = component.find('accountDiv');
        $A.util.removeClass(newButton, "slds-hide");
    },
    createOpportunity : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast"); 
        console.log(component.get("v.selectedModal"));
        if(component.get("v.selectedModal") =='none'){ // || component.get("v.nextAction") =='none'){             
            toastEvent.setParams({
                "title": "error!",
                "type":"error",
                "message": "Enter Mandatory Fields."
            });
            toastEvent.fire();
        }else{
            let button = event.getSource();
            button.set('v.disabled',true);
            helper.savenewOpportunity(component, event, helper);
        }
    },
    onSelectContact : function(component, event, helper) {
        var selected = event.getSource().get("v.text");
        console.log(selected);
    },
    createAccount : function(component, event, helper) {
        let button = event.getSource();         
        console.log(component.get("v.selectedModal"));
        var newAccount=  component.get("v.newAccount");
        var emailPattern = /\S+@\S+/;
        var toastEvent = $A.get("e.force:showToast");
        if(newAccount.LastName == '' || component.get("v.selectedModal") =='none'){ // || component.get("v.nextAction") =='none'){             
            toastEvent.setParams({
                "title": "error!",
                "type":"error",
                "message": "Enter Mandatory Fields."
            });
            toastEvent.fire();
        }else if(newAccount.Phone == '' && newAccount.PersonEmail == ''){
            toastEvent.setParams({
                "title": "error!",
                "type":"error",
                "message": "One of Phone or Email must be entered."
            });
            toastEvent.fire();
        }else if(newAccount.PersonEmail != '' && !emailPattern.test(newAccount.PersonEmail)){
            toastEvent.setParams({
                "title": "error!",
                "type":"error",
                "message": "You have entered an invalid format."
            });
            toastEvent.fire();
        }else{
            button.set('v.disabled',true);
            helper.createNewAccount(component, event, helper);
        }
    },
    cancelhandling : function(component, event, helper) {
        var handleClick=  component.get("c.handleClick");
        $A.enqueueAction(handleClick);
    },
    onSelectAsset : function(component, event, helper) {
        var getNavigationId = event.currentTarget.id;
        
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": getNavigationId
        });
        navEvt.fire();
    },
    refreshSearchResults : function(component, event, helper) {
        component.set("v.AccountList",null );
        component.set("v.contactList",null ); 
        component.set("v.assestList",null );
        component.set('v.searchText','');         
        var newButton = component.find('createButton');
        $A.util.addClass(newButton, "slds-hide");
        component.set("v.selectedModal",'none');
       // component.set("v.nextAction",'none');
         helper.getStageTypeValues(component, event, helper);
        var accountDiv = component.find('accountDiv');
        $A.util.addClass(accountDiv, "slds-hide");
        var opportunityDiv = component.find('opportunityDiv');
        $A.util.addClass(opportunityDiv, "slds-hide");
        component.set("v.selectedAccountId",'');
        
    },
       navgiateToOpportunity: function (component, event, helper){
          var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": component.get("v.opportunityId")
                    });
                    navEvt.fire();
    },
})