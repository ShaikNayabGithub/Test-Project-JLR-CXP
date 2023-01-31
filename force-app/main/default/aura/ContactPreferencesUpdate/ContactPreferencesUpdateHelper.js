({
    getcurrentContact : function(component, event, helper) {
        var action = component.get('c.getContact');
        var contactID = component.get("v.recordId");
        
        action.setParams({
            "conId" : component.get("v.recordId")
        });
        
        action.setCallback(component, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS'){
                component.set("v.currentContact",response.getReturnValue());
                console.log(response.getReturnValue());
            } 
            else {
                alert('Error');
            }
        });
        
        $A.enqueueAction(action);        
    },
    getcurrentContactAccess : function(component, event, helper) {
        var action = component.get('c.getContactAccess');
        action.setParams({
            "contId" : component.get("v.recordId")
        });
        
        action.setCallback(component, function(response) {
            var state = response.getState();
            if (state == 'SUCCESS'){
                component.set("v.currentContactAccess",response.getReturnValue());
                console.log('Contact Access: ' + response.getReturnValue());
            }
            else {
                console.log("Error getting access");
            }
        });
        
        $A.enqueueAction(action);
    },
    getContactLabels : function(component, event, helper) {
        var action = component.get('c.getContactLabelMap');
        action.setParams({  objectName : 'Contact'  });
        action.setCallback(component, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS'){
                component.set("v.contactFieldLabelMap",response.getReturnValue());
            }
            else {
                alert("Error getting contact labels");
            }
        });
        $A.enqueueAction(action);
    },
    saveCurrentContact: function(component, event, helper) {
        console.log('saveContact');
        let button = event.getSource();
        var action = component.get('c.saveContact');
        action.setParams({
            "contact" : component.get("v.currentContact")
        });
        action.setCallback(component, function(response) {
            var state = response.getState();
            if (state == 'SUCCESS'){ 
                var saveResult = response.getReturnValue();  
                console.log(saveResult.errorMessage);
                var toastEvent = $A.get("e.force:showToast");
                if(saveResult.errorMessage == 'No Error'){
                    component.set("v.currentContact",response.getReturnValue().updatedContact);
                    toastEvent.setParams({
                        "title": $A.get("$Label.c.Success"),
                        "type" : "success",
                        "message": $A.get("$Label.c.Contact_Updated_Success")
                    }); 
                    toastEvent.fire();
                    button.set('v.disabled',false);
                }else{
                    toastEvent.setParams({
                        "title": "Error!",
                        "type" : "error",
                        "message": saveResult.errorMessage
                    });
                    toastEvent.fire();
                    button.set('v.disabled',false);
                }
            }
            else {
                console.log("error");
            }
        });
        $A.enqueueAction(action);
    },
    allCommOptOut: function(component, event, helper, currentContact) {
        var currentRecord = currentContact;
        if(currentRecord.All_Communications_opt_out__c){ 
            currentRecord.Land_Rover_Whitemail_Opt_Out__c = true;
            currentRecord.Land_Rover_Email_Opt_Out__c = true;
            currentRecord.Land_Rover_Phone_Opt_Out__c = true;
            currentRecord.Land_Rover_SMS_Opt_Out__c = true;
            currentRecord.Jaguar_Whitemail_Opt_Out__c = true;
            currentRecord.Jaguar_Email_Opt_Out__c = true;
            currentRecord.Jaguar_Phone_Opt_Out__c = true;
            currentRecord.Jaguar_SMS_Opt_Out__c = true;
            currentRecord.All_Topics_Opt_Out__c = true;
            this.allTopsOptOut(component, event, helper, currentRecord); 
        } 
        component.set("v.currentContact",currentRecord);
    },
    oneCommOptIn: function(component, event, helper, currentContact) { 
        var currentRecord = currentContact; 
        if(!currentRecord.Land_Rover_Whitemail_Opt_Out__c || !currentRecord.Land_Rover_Whitemail_Opt_Out__c || !currentRecord.Land_Rover_Email_Opt_Out__c ||
           !currentRecord.Land_Rover_Phone_Opt_Out__c || !currentRecord.Land_Rover_SMS_Opt_Out__c || !currentRecord.Jaguar_Whitemail_Opt_Out__c ||
           !currentRecord.Jaguar_Email_Opt_Out__c || !currentRecord.Jaguar_Phone_Opt_Out__c ||  !currentRecord.Jaguar_SMS_Opt_Out__c ){
            currentRecord.All_Communications_opt_out__c = false;
        } 
        component.set("v.currentContact",currentRecord);
    },
    
    channelOptOut: function(component, event, helper, currentContact) { 
        var currentRecord = currentContact; 
        if(currentRecord.Land_Rover_Whitemail_Opt_Out__c){
            currentRecord.LR_Eve_Exp_Direct_Mail__c = true;
            currentRecord.LR_InCon_Conn_Direct_Mail__c = true;
            currentRecord.LR_Own_Veh_Direct_Mail__c = true;
            currentRecord.LR_Par_Spo_Direct_Mail__c = true;
            currentRecord.LR_Pro_Off_Direct_Mail__c = true;
            currentRecord.LR_Pro_Ser_Direct_Mail__c = true;
            currentRecord.LR_Sur_Res_Direct_Mail__c = true;
            
        }
        if(currentRecord.Land_Rover_Email_Opt_Out__c){
            currentRecord.LR_Eve_Exp_Email__c = true;
            currentRecord.LR_InCon_Conn_Email__c = true;
            currentRecord.LR_Own_Veh_Email__c = true;
            currentRecord.LR_Par_Spo_Email__c = true;
            currentRecord.LR_Pro_Off_Email__c = true;
            currentRecord.LR_Pro_Ser_Email__c = true;
            currentRecord.LR_Sur_Res_Email__c = true;
            
            
        }
        
        if(currentRecord.Land_Rover_Phone_Opt_Out__c){
            currentRecord.LR_Eve_Exp_Phone__c = true;
            currentRecord.LR_InCon_Conn_Phone__c = true;
            currentRecord.LR_Own_Veh_Phone__c = true;
            currentRecord.LR_Par_Spo_Phone__c = true;
            currentRecord.LR_Pro_Off_Phone__c = true;
            currentRecord.LR_Pro_Ser_Phone__c = true;
            currentRecord.LR_Sur_Res_Phone__c = true;
            
        }
        if(currentRecord.Land_Rover_SMS_Opt_Out__c){
            currentRecord.LR_Eve_Exp_SMS__c = true;
            currentRecord.LR_InCon_Conn_SMS__c = true;
            currentRecord.LR_Own_Veh_SMS__c = true;
            currentRecord.LR_Par_Spo_SMS__c = true;
            currentRecord.LR_Pro_Off_SMS__c = true;
            currentRecord.LR_Pro_Ser_SMS__c = true;
            currentRecord.LR_Sur_Res_SMS__c = true;
            
        }
        
        if(currentRecord.Jaguar_Whitemail_Opt_Out__c){
            currentRecord.J_Eve_Exp_Direct_Mail__c = true;
            currentRecord.J_InCon_Conn_Direct_Mail__c = true;
            currentRecord.J_Own_Veh_Direct_Mail__c = true;
            currentRecord.J_Par_Spo_Direct_Mail__c = true;
            currentRecord.J_Pro_Off_Direct_Mail__c = true;
            currentRecord.J_Pro_Ser_Direct_Mail__c = true;
            currentRecord.J_Sur_Res_Direct_Mail__c = true;
            
        }
        if(currentRecord.Jaguar_Email_Opt_Out__c){
            currentRecord.J_Eve_Exp_Email__c = true;
            currentRecord.J_InCon_Conn_Email__c = true;
            currentRecord.J_Own_Veh_Email__c = true;
            currentRecord.J_Par_Spo_Email__c = true;
            currentRecord.J_Pro_Off_Email__c = true;
            currentRecord.J_Pro_Ser_Email__c = true;
            currentRecord.J_Sur_Res_Email__c = true;
        }
        
        if(currentRecord.Jaguar_Phone_Opt_Out__c){
            currentRecord.J_Eve_Exp_Phone__c = true;
            currentRecord.J_InCon_Conn_Phone__c = true;
            currentRecord.J_Own_Veh_Phone__c = true;
            currentRecord.J_Par_Spo_Phone__c = true;
            currentRecord.J_Pro_Off_Phone__c = true;
            currentRecord.J_Pro_Ser_Phone__c = true;
            currentRecord.J_Sur_Res_Phone__c = true;
            
        }
        if(currentRecord.Jaguar_SMS_Opt_Out__c){
            currentRecord.J_Eve_Exp_SMS__c = true;
            currentRecord.J_InCon_Conn_SMS__c = true;
            currentRecord.J_Own_Veh_SMS__c = true;
            currentRecord.J_Par_Spo_SMS__c = true;
            currentRecord.J_Pro_Off_SMS__c = true;
            currentRecord.J_Pro_Ser_SMS__c = true;
            currentRecord.J_Sur_Res_SMS__c = true;
            
        } 
        component.set("v.currentContact",currentRecord);
    },
    
    allTopsOptOut: function(component, event, helper, currentContact) { 
        var currentRecord = currentContact;
        if(currentRecord.All_Topics_Opt_Out__c){
            currentRecord.Jaguar_Opt_out_all_Topics__c = true;
            currentRecord.Land_Rover_Opt_out_all_Topics__c = true;
            this.LRAllTopisOptOut(component, event, helper, currentRecord);
            this.JAllTopisOptOut(component, event, helper, currentRecord);            
        } 
        component.set("v.currentContact",currentRecord);
    },
    JLRTopsOptIn: function(component, event, helper, currentContact) { 
        var currentRecord = currentContact;
        if( currentRecord.Jaguar_Opt_out_all_Topics__c || currentRecord.Land_Rover_Opt_out_all_Topics__c ){
            currentRecord.All_Topics_Opt_Out__c =false;
            currentRecord.All_Communications_opt_out__c =false;
        } 
        component.set("v.currentContact",currentRecord);
    },
    LRAllTopisOptOut : function(component, event, helper, currentContact) { 
        var currentRecord = currentContact;
        if( currentRecord.Land_Rover_Opt_out_all_Topics__c){
            currentRecord.Land_Rover_Event_Experiences_Opt_Out__c = true;
            currentRecord.Land_Rover_In_Control_Connected_Opt_Out__c = true;
            currentRecord.Land_Rover_Owner_Vehicle_Comm_Opt_Out__c = true;
            currentRecord.Land_Rover_Partners_Sponsorship_Opt_Out__c = true;
            currentRecord.Land_Rover_Products_Services_Opt_Out__c = true;
            currentRecord.Land_Rover_Promotions_Offers_Opt_Out__c = true;
            currentRecord.Land_Rover_Surveys_and_Research_Opt_Out__c = true;
            this.LReventExperiencesOptOut(component, event, helper, currentRecord);
        } 
        component.set("v.currentContact",currentRecord);
    },    
    JAllTopisOptOut : function(component, event, helper, currentContact) { 
        var currentRecord = currentContact;
        if( currentRecord.Jaguar_Opt_out_all_Topics__c){
            currentRecord.Jaguar_Event_Experiences_Opt_Out__c = true;
            currentRecord.Jaguar_In_Control_Connected_Opt_Out__c = true;
            currentRecord.Jaguar_Owner_Vehicle_Comm_Opt_Out__c = true;
            currentRecord.Jaguar_Partners_Sponsorship_Opt_Out__c = true;
            currentRecord.Jaguar_Products_Services_Opt_Out__c = true;
            currentRecord.Jaguar_Promotions_Offers_Opt_Out__c = true;
            currentRecord.Jaguar_Surveys_and_Research_Opt_Out__c = true; 
            this.JeventExperiencesOptOut(component, event, helper, currentRecord); 
        } 
        component.set("v.currentContact",currentRecord);
    },
    LRAllTopisOptIn : function(component, event, helper, currentContact) { 
        var currentRecord = currentContact;
        if(  !currentRecord.Land_Rover_Event_Experiences_Opt_Out__c || !currentRecord.Land_Rover_In_Control_Connected_Opt_Out__c ||
           !currentRecord.Land_Rover_Owner_Vehicle_Comm_Opt_Out__c || !currentRecord.Land_Rover_Partners_Sponsorship_Opt_Out__c ||
           !currentRecord.Land_Rover_Products_Services_Opt_Out__c || !currentRecord.Land_Rover_Promotions_Offers_Opt_Out__c ||
           !currentRecord.Land_Rover_Surveys_and_Research_Opt_Out__c ){
            currentRecord.Land_Rover_Opt_out_all_Topics__c = false;
            this.JLRTopsOptIn(component, event, helper, currentRecord);
        } 
        component.set("v.currentContact",currentRecord);
    },    
    JAllTopisOptIn : function(component, event, helper, currentContact) { 
        var currentRecord = currentContact;
        if( !currentRecord.Jaguar_Event_Experiences_Opt_Out__c ||  !currentRecord.Jaguar_In_Control_Connected_Opt_Out__c || 
           !currentRecord.Jaguar_Owner_Vehicle_Comm_Opt_Out__c || !currentRecord.Jaguar_Partners_Sponsorship_Opt_Out__c || 
           !currentRecord.Jaguar_Products_Services_Opt_Out__c  ||   !currentRecord.Jaguar_Promotions_Offers_Opt_Out__c  || 
           !currentRecord.Jaguar_Surveys_and_Research_Opt_Out__c  ){
            currentRecord.Jaguar_Opt_out_all_Topics__c = false;
            this.JLRTopsOptIn(component, event, helper, currentRecord); 
        } 
        component.set("v.currentContact",currentRecord);
    },
    LReventExperiencesOptOut : function(component, event, helper, currentContact) { 
        var currentRecord = currentContact;
        if( currentRecord.Land_Rover_Event_Experiences_Opt_Out__c){
            currentRecord.LR_Eve_Exp_Email__c =true;
            currentRecord.LR_Eve_Exp_Phone__c =true;
            currentRecord.LR_Eve_Exp_Direct_Mail__c =true;
            currentRecord.LR_Eve_Exp_SMS__c =true;
        } 
        if( currentRecord.Land_Rover_In_Control_Connected_Opt_Out__c){
            currentRecord.LR_InCon_Conn_Email__c =true;
            currentRecord.LR_InCon_Conn_Phone__c =true;
            currentRecord.LR_InCon_Conn_Direct_Mail__c =true;
            currentRecord.LR_InCon_Conn_SMS__c =true;
        }
        if( currentRecord.Land_Rover_Owner_Vehicle_Comm_Opt_Out__c){
            currentRecord.LR_Own_Veh_Email__c =true;
            currentRecord.LR_Own_Veh_Phone__c =true;
            currentRecord.LR_Own_Veh_Direct_Mail__c =true;
            currentRecord.LR_Own_Veh_SMS__c =true;
        }
        if( currentRecord.Land_Rover_Partners_Sponsorship_Opt_Out__c){
            currentRecord.LR_Par_Spo_Email__c =true;
            currentRecord.LR_Par_Spo_Phone__c =true;
            currentRecord.LR_Par_Spo_Direct_Mail__c =true;
            currentRecord.LR_Par_Spo_SMS__c =true;
        }
        if( currentRecord.Land_Rover_Products_Services_Opt_Out__c){
            currentRecord.LR_Pro_Ser_Email__c =true;
            currentRecord.LR_Pro_Ser_Phone__c =true;
            currentRecord.LR_Pro_Ser_Direct_Mail__c =true;
            currentRecord.LR_Pro_Ser_SMS__c =true;
        }
        if( currentRecord.Land_Rover_Promotions_Offers_Opt_Out__c){
            currentRecord.LR_Pro_Off_Email__c =true;
            currentRecord.LR_Pro_Off_Phone__c =true;
            currentRecord.LR_Pro_Off_Direct_Mail__c =true;
            currentRecord.LR_Pro_Off_SMS__c =true;
        }
        if( currentRecord.Land_Rover_Surveys_and_Research_Opt_Out__c){
            currentRecord.LR_Sur_Res_Email__c =true;
            currentRecord.LR_Sur_Res_Phone__c =true;
            currentRecord.LR_Sur_Res_Direct_Mail__c =true;
            currentRecord.LR_Sur_Res_SMS__c =true;
        }
        component.set("v.currentContact",currentRecord);
        
    },
    JeventExperiencesOptOut : function(component, event, helper, currentContact) { 
        var currentRecord = currentContact;
        if( currentRecord.Jaguar_Event_Experiences_Opt_Out__c){
            currentRecord.J_Eve_Exp_Email__c =true;
            currentRecord.J_Eve_Exp_Phone__c =true;
            currentRecord.J_Eve_Exp_Direct_Mail__c =true;
            currentRecord.J_Eve_Exp_SMS__c =true;
        }
        if( currentRecord.Jaguar_In_Control_Connected_Opt_Out__c){
            currentRecord.J_InCon_Conn_Email__c =true;
            currentRecord.J_InCon_Conn_Phone__c =true;
            currentRecord.J_InCon_Conn_Direct_Mail__c =true;
            currentRecord.J_InCon_Conn_SMS__c =true;
        }
        if( currentRecord.Jaguar_Owner_Vehicle_Comm_Opt_Out__c){
            currentRecord.J_Own_Veh_Email__c =true;
            currentRecord.J_Own_Veh_Phone__c =true;
            currentRecord.J_Own_Veh_Direct_Mail__c =true;
            currentRecord.J_Own_Veh_SMS__c =true;
        }
        if( currentRecord.Jaguar_Partners_Sponsorship_Opt_Out__c){
            currentRecord.J_Par_Spo_Email__c =true;
            currentRecord.J_Par_Spo_Phone__c =true;
            currentRecord.J_Par_Spo_Direct_Mail__c =true;
            currentRecord.J_Par_Spo_SMS__c =true;
        }
        if( currentRecord.Jaguar_Products_Services_Opt_Out__c){
            currentRecord.J_Pro_Ser_Email__c =true;
            currentRecord.J_Pro_Ser_Phone__c =true;
            currentRecord.J_Pro_Ser_Direct_Mail__c =true;
            currentRecord.J_Pro_Ser_SMS__c =true;
        }
        if( currentRecord.Jaguar_Promotions_Offers_Opt_Out__c){
            currentRecord.J_Pro_Off_Email__c =true;
            currentRecord.J_Pro_Off_Phone__c =true;
            currentRecord.J_Pro_Off_Direct_Mail__c =true;
            currentRecord.J_Pro_Off_SMS__c =true;
        }
        if( currentRecord.Jaguar_Surveys_and_Research_Opt_Out__c){
            currentRecord.J_Sur_Res_Email__c =true;
            currentRecord.J_Sur_Res_Phone__c =true;
            currentRecord.J_Sur_Res_Direct_Mail__c =true;
            currentRecord.J_Sur_Res_SMS__c =true;
        }
        
        component.set("v.currentContact",currentRecord);
    },
    LReventExperiencesOptIn : function(component, event, helper, currentContact) { 
        var currentRecord = currentContact;
        if(!currentRecord.LR_Eve_Exp_Email__c || !currentRecord.LR_Eve_Exp_Phone__c || 
           !currentRecord.LR_Eve_Exp_Direct_Mail__c ||  !currentRecord.LR_Eve_Exp_SMS__c ){
            currentRecord.Land_Rover_Event_Experiences_Opt_Out__c = false;
            this.LRAllTopisOptIn(component, event, helper, currentRecord); 
        } 
        if(!currentRecord.LR_InCon_Conn_Email__c || !currentRecord.LR_InCon_Conn_Phone__c 
           || !currentRecord.LR_InCon_Conn_Direct_Mail__c || !currentRecord.LR_InCon_Conn_SMS__c ){
            currentRecord.Land_Rover_In_Control_Connected_Opt_Out__c = false;
            this.LRAllTopisOptIn(component, event, helper, currentRecord); 
            this.LRAllTopisOptIn(component, event, helper, currentRecord); 
        } 
        if( !currentRecord.LR_Own_Veh_Email__c || !currentRecord.LR_Own_Veh_Phone__c ||
           !currentRecord.LR_Own_Veh_Direct_Mail__c ||  !currentRecord.LR_Own_Veh_SMS__c ){
            currentRecord.Land_Rover_Owner_Vehicle_Comm_Opt_Out__c =false;
            this.LRAllTopisOptIn(component, event, helper, currentRecord); 
        }
        if( !currentRecord.LR_Par_Spo_Email__c || !currentRecord.LR_Par_Spo_Phone__c ||
           !currentRecord.LR_Par_Spo_Direct_Mail__c || !currentRecord.LR_Par_Spo_SMS__c ){
            currentRecord.Land_Rover_Partners_Sponsorship_Opt_Out__c =false;
            this.LRAllTopisOptIn(component, event, helper, currentRecord); 
        }
        if( !currentRecord.LR_Pro_Ser_Email__c || !currentRecord.LR_Pro_Ser_Phone__c ||
           !currentRecord.LR_Pro_Ser_Direct_Mail__c || !currentRecord.LR_Pro_Ser_SMS__c ){
            currentRecord.Land_Rover_Products_Services_Opt_Out__c =false;
            this.LRAllTopisOptIn(component, event, helper, currentRecord); 
        }
        if( !currentRecord.LR_Pro_Off_Email__c || !currentRecord.LR_Pro_Off_Phone__c || 
           !currentRecord.LR_Pro_Off_Direct_Mail__c || !currentRecord.LR_Pro_Off_SMS__c){
            currentRecord.Land_Rover_Promotions_Offers_Opt_Out__c =false;
            this.LRAllTopisOptIn(component, event, helper, currentRecord); 
        }
        if( !currentRecord.LR_Sur_Res_Email__c || !currentRecord.LR_Sur_Res_Phone__c ||
           !currentRecord.LR_Sur_Res_Direct_Mail__c || !currentRecord.LR_Sur_Res_SMS__c){
            currentRecord.Land_Rover_Surveys_and_Research_Opt_Out__c =false;
            this.LRAllTopisOptIn(component, event, helper, currentRecord); 
        }
        if(!currentRecord.LR_Eve_Exp_Direct_Mail__c || 
           !currentRecord.LR_InCon_Conn_Direct_Mail__c || 
           !currentRecord.LR_Own_Veh_Direct_Mail__c || 
           !currentRecord.LR_Par_Spo_Direct_Mail__c || 
           !currentRecord.LR_Pro_Off_Direct_Mail__c || 
           !currentRecord.LR_Pro_Ser_Direct_Mail__c || 
           !currentRecord.LR_Sur_Res_Direct_Mail__c ){
            currentRecord.Land_Rover_Whitemail_Opt_Out__c = false;
        }
        if(!currentRecord.LR_Eve_Exp_Email__c || 
           !currentRecord.LR_InCon_Conn_Email__c || 
           !currentRecord.LR_Own_Veh_Email__c || 
           !currentRecord.LR_Par_Spo_Email__c || 
           !currentRecord.LR_Pro_Off_Email__c || 
           !currentRecord.LR_Pro_Ser_Email__c || 
           !currentRecord.LR_Sur_Res_Email__c ){ 
            currentRecord.Land_Rover_Email_Opt_Out__c = false;
            
        }
        
        if(!currentRecord.LR_Eve_Exp_Phone__c || 
           !currentRecord.LR_InCon_Conn_Phone__c || 
           !currentRecord.LR_Own_Veh_Phone__c || 
           !currentRecord.LR_Par_Spo_Phone__c || 
           !currentRecord.LR_Pro_Off_Phone__c || 
           !currentRecord.LR_Pro_Ser_Phone__c || 
           !currentRecord.LR_Sur_Res_Phone__c ){
            currentRecord.Land_Rover_Phone_Opt_Out__c = false;            
        }
        if(
            !currentRecord.LR_Eve_Exp_SMS__c || 
            !currentRecord.LR_InCon_Conn_SMS__c || 
            !currentRecord.LR_Own_Veh_SMS__c || 
            !currentRecord.LR_Par_Spo_SMS__c || 
            !currentRecord.LR_Pro_Off_SMS__c || 
            !currentRecord.LR_Pro_Ser_SMS__c || 
            !currentRecord.LR_Sur_Res_SMS__c ){
            currentRecord.Land_Rover_SMS_Opt_Out__c = false;
            
        }
        
        component.set("v.currentContact",currentRecord);
    },
    JeventExperiencesOptIn : function(component, event, helper, currentContact) { 
        var currentRecord = currentContact;
        if(!currentRecord.J_Eve_Exp_Email__c || !currentRecord.J_Eve_Exp_Phone__c || !currentRecord.J_Eve_Exp_Direct_Mail__c ||
           !currentRecord.J_Eve_Exp_SMS__c ){
            currentRecord.Jaguar_Event_Experiences_Opt_Out__c = false;
            this.JAllTopisOptIn(component, event, helper, currentRecord); 
        } 
        if(!currentRecord.J_InCon_Conn_Email__c || !currentRecord.J_InCon_Conn_Phone__c || !currentRecord.J_InCon_Conn_Direct_Mail__c ||
           !currentRecord.J_InCon_Conn_SMS__c ){
            currentRecord.Jaguar_In_Control_Connected_Opt_Out__c = false;
            this.JAllTopisOptIn(component, event, helper, currentRecord); 
        } 
        if( !currentRecord.J_Own_Veh_Email__c || !currentRecord.J_Own_Veh_Phone__c ||
           !currentRecord.J_Own_Veh_Direct_Mail__c ||  !currentRecord.J_Own_Veh_SMS__c ){
            currentRecord.Jaguar_Owner_Vehicle_Comm_Opt_Out__c =false;
            this.JAllTopisOptIn(component, event, helper, currentRecord);
        }
        if( !currentRecord.J_Par_Spo_Email__c || !currentRecord.J_Par_Spo_Phone__c ||
           !currentRecord.J_Par_Spo_Direct_Mail__c || !currentRecord.J_Par_Spo_SMS__c ){
            currentRecord.Jaguar_Partners_Sponsorship_Opt_Out__c =false;
            this.JAllTopisOptIn(component, event, helper, currentRecord);
        }
        if( !currentRecord.J_Pro_Ser_Email__c || !currentRecord.J_Pro_Ser_Phone__c ||
           !currentRecord.J_Pro_Ser_Direct_Mail__c || !currentRecord.J_Pro_Ser_SMS__c ){
            currentRecord.Jaguar_Products_Services_Opt_Out__c =false;
            this.JAllTopisOptIn(component, event, helper, currentRecord);
        }
        if( !currentRecord.J_Pro_Off_Email__c || !currentRecord.J_Pro_Off_Phone__c || 
           !currentRecord.J_Pro_Off_Direct_Mail__c || !currentRecord.J_Pro_Off_SMS__c){
            currentRecord.Jaguar_Promotions_Offers_Opt_Out__c =false;
            this.JAllTopisOptIn(component, event, helper, currentRecord);
        }
        if( !currentRecord.J_Sur_Res_Email__c || !currentRecord.J_Sur_Res_Phone__c ||
           !currentRecord.J_Sur_Res_Direct_Mail__c || !currentRecord.J_Sur_Res_SMS__c){
            currentRecord.Jaguar_Surveys_and_Research_Opt_Out__c =false;
            this.JAllTopisOptIn(component, event, helper, currentRecord);
        }
        
        if(!currentRecord.J_Eve_Exp_Direct_Mail__c || 
           !currentRecord.J_InCon_Conn_Direct_Mail__c || 
           !currentRecord.J_Own_Veh_Direct_Mail__c || 
           !currentRecord.J_Par_Spo_Direct_Mail__c || 
           !currentRecord.J_Pro_Off_Direct_Mail__c || 
           !currentRecord.J_Pro_Ser_Direct_Mail__c || 
           !currentRecord.J_Sur_Res_Direct_Mail__c ){
            currentRecord.Jaguar_Whitemail_Opt_Out__c = false;
        }
        if(!currentRecord.J_Eve_Exp_Email__c || 
           !currentRecord.J_InCon_Conn_Email__c || 
           !currentRecord.J_Own_Veh_Email__c || 
           !currentRecord.J_Par_Spo_Email__c || 
           !currentRecord.J_Pro_Off_Email__c || 
           !currentRecord.J_Pro_Ser_Email__c || 
           !currentRecord.J_Sur_Res_Email__c ){
            currentRecord.Jaguar_Email_Opt_Out__c =false;
        }
        if(!currentRecord.J_Eve_Exp_Phone__c || 
           !currentRecord.J_InCon_Conn_Phone__c || 
           !currentRecord.J_Own_Veh_Phone__c || 
           !currentRecord.J_Par_Spo_Phone__c || 
           !currentRecord.J_Pro_Off_Phone__c || 
           !currentRecord.J_Pro_Ser_Phone__c || 
           !currentRecord.J_Sur_Res_Phone__c ){
            currentRecord.Jaguar_Phone_Opt_Out__c = false;
        }
        if(!currentRecord.J_Eve_Exp_SMS__c || 
           !currentRecord.J_InCon_Conn_SMS__c || 
           !currentRecord.J_Own_Veh_SMS__c || 
           !currentRecord.J_Par_Spo_SMS__c || 
           !currentRecord.J_Pro_Off_SMS__c || 
           !currentRecord.J_Pro_Ser_SMS__c || 
           !currentRecord.J_Sur_Res_SMS__c ){ 
            currentRecord.Jaguar_SMS_Opt_Out__c =false;
        }
        component.set("v.currentContact",currentRecord);
    },
})