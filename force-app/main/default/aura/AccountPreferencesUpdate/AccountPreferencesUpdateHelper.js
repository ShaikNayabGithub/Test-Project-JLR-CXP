({
    getcurrentAccount : function(component, event, helper) {
        var action = component.get('c.getAccount');
        action.setParams({  accountId : component.get("v.recordId")  });
        action.setCallback(component, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS'){
                component.set("v.currentAccount",response.getReturnValue());
            } 
        });
        $A.enqueueAction(action);        
    },
     getcurrentAccountAccess : function(component, event, helper) {
        var action = component.get('c.getAccountAccess');
        action.setParams({  accountId : component.get("v.recordId")  });
        action.setCallback(component, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS'){
                component.set("v.currentAccountAccess",response.getReturnValue());
            } 
        });
        $A.enqueueAction(action);
    },
    getAccountLabels : function(component, event, helper) {
        var action = component.get('c.getAccountLabelMap');
        action.setParams({  objectName : 'Account'  });
        action.setCallback(component, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS'){
                console.log(response.getReturnValue());
                component.set("v.accountFieldLabelMap",response.getReturnValue());
            } 
        });
        $A.enqueueAction(action);
    },
    saveCurrentAccount: function(component, event, helper) {
        console.log('saveAccount');
        let button = event.getSource();
        var action = component.get('c.saveAccount');
        action.setParams({  account : component.get("v.currentAccount")  });
        action.setCallback(component, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS'){ 
                var saveResult = response.getReturnValue();  
                console.log(saveResult.errorMessage);
                var toastEvent = $A.get("e.force:showToast");
                if(saveResult.errorMessage == 'No Error'){
                component.set("v.currentAccount",response.getReturnValue().updatedAccount);
                toastEvent.setParams({
                    "title": $A.get("$Label.c.Success"),
                    "type" : "success",
                    "message": $A.get("$Label.c.Account_Updated_Success")
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
        });
        $A.enqueueAction(action);
    },
    mainOptOutHelper: function(component, event, helper, currentAccount) {
        var currentRecord = currentAccount;
        if(event.getSource().get("v.checked")){
            console.log();
            if(currentRecord.Direct_Mail_Opt_Out__pc){                 
                currentRecord.Land_Rover_Whitemail_Opt_Out__pc = true;
                currentRecord.Jaguar_Whitemail_Opt_Out__pc = true;                
            } 
            if(currentRecord.PersonHasOptedOutOfEmail){ 
                currentRecord.Land_Rover_Email_Opt_Out__pc = true;
                currentRecord.Jaguar_Email_Opt_Out__pc = true;
            }
            if(currentRecord.PersonDoNotCall){  
                currentRecord.Land_Rover_Phone_Opt_Out__pc = true;
                currentRecord.Jaguar_Phone_Opt_Out__pc = true;
            }
            if(currentRecord.et4ae5__HasOptedOutOfMobile__pc){  
                currentRecord.Land_Rover_SMS_Opt_Out__pc = true;
                currentRecord.Jaguar_SMS_Opt_Out__pc = true;
            }
            helper.channelOptOut(component, event, helper, currentRecord);
        }
        component.set("v.currentAccount",currentRecord);
    },
    allCommOptOut: function(component, event, helper, currentAccount) {
        var currentRecord = currentAccount;
        if(currentRecord.All_Communications_opt_out__pc){ 
            currentRecord.Land_Rover_Whitemail_Opt_Out__pc = true;
            currentRecord.Land_Rover_Email_Opt_Out__pc = true;
            currentRecord.Land_Rover_Phone_Opt_Out__pc = true;
            currentRecord.Land_Rover_SMS_Opt_Out__pc = true;
            currentRecord.Jaguar_Whitemail_Opt_Out__pc = true;
            currentRecord.Jaguar_Email_Opt_Out__pc = true;
            currentRecord.Jaguar_Phone_Opt_Out__pc = true;
            currentRecord.Jaguar_SMS_Opt_Out__pc = true;
            currentRecord.All_Topics_Opt_Out__pc = true;
            this.allTopsOptOut(component, event, helper, currentRecord); 
        } 
        component.set("v.currentAccount",currentRecord);
    },
    oneCommOptIn: function(component, event, helper, currentAccount) { 
        var currentRecord = currentAccount; 
        if(!currentRecord.Land_Rover_Whitemail_Opt_Out__pc || !currentRecord.Land_Rover_Email_Opt_Out__pc ||
           !currentRecord.Land_Rover_Phone_Opt_Out__pc || !currentRecord.Land_Rover_SMS_Opt_Out__pc || !currentRecord.Jaguar_Whitemail_Opt_Out__pc ||
           !currentRecord.Jaguar_Email_Opt_Out__pc || !currentRecord.Jaguar_Phone_Opt_Out__pc ||  !currentRecord.Jaguar_SMS_Opt_Out__pc ){
            currentRecord.All_Communications_opt_out__pc = false;
        } 
        helper.mainOptIn(component, event, helper, currentRecord);
        component.set("v.currentAccount",currentRecord);
    },
    mainOptIn: function(component, event, helper, currentAccount) { 
        var currentRecord = currentAccount; 
        if(!currentRecord.Land_Rover_Whitemail_Opt_Out__pc || !currentRecord.Jaguar_Whitemail_Opt_Out__pc)
            currentRecord.Direct_Mail_Opt_Out__pc= false;
        if( !currentRecord.Land_Rover_Email_Opt_Out__pc || !currentRecord.Jaguar_Email_Opt_Out__pc)
            currentRecord.PersonHasOptedOutOfEmail= false;
        if( !currentRecord.Land_Rover_SMS_Opt_Out__pc ||  !currentRecord.Jaguar_SMS_Opt_Out__pc)
            currentRecord.et4ae5__HasOptedOutOfMobile__pc = false;
        if( !currentRecord.Jaguar_Phone_Opt_Out__pc || !currentRecord.Land_Rover_Phone_Opt_Out__pc)
            currentRecord.PersonDoNotCall = false;
        component.set("v.currentAccount",currentRecord);
    },
    
    channelOptOut: function(component, event, helper, currentAccount) { 
        var currentRecord = currentAccount; 
        if(currentRecord.Land_Rover_Whitemail_Opt_Out__pc){
            currentRecord.LR_Eve_Exp_Direct_Mail__pc = true;
            currentRecord.LR_InCon_Conn_Direct_Mail__pc = true;
            currentRecord.LR_Own_Veh_Direct_Mail__pc = true;
            currentRecord.LR_Par_Spo_Direct_Mail__pc = true;
            currentRecord.LR_Pro_Off_Direct_Mail__pc = true;
            currentRecord.LR_Pro_Ser_Direct_Mail__pc = true;
            currentRecord.LR_Sur_Res_Direct_Mail__pc = true;
            
        }
        if(currentRecord.Land_Rover_Email_Opt_Out__pc){
            currentRecord.LR_Eve_Exp_Email__pc = true;
            currentRecord.LR_InCon_Conn_Email__pc = true;
            currentRecord.LR_Own_Veh_Email__pc = true;
            currentRecord.LR_Par_Spo_Email__pc = true;
            currentRecord.LR_Pro_Off_Email__pc = true;
            currentRecord.LR_Pro_Ser_Email__pc = true;
            currentRecord.LR_Sur_Res_Email__pc = true;
            
            
        }
        
        if(currentRecord.Land_Rover_Phone_Opt_Out__pc){
            currentRecord.LR_Eve_Exp_Phone__pc = true;
            currentRecord.LR_InCon_Conn_Phone__pc = true;
            currentRecord.LR_Own_Veh_Phone__pc = true;
            currentRecord.LR_Par_Spo_Phone__pc = true;
            currentRecord.LR_Pro_Off_Phone__pc = true;
            currentRecord.LR_Pro_Ser_Phone__pc = true;
            currentRecord.LR_Sur_Res_Phone__pc = true;
            
        }
        if(currentRecord.Land_Rover_SMS_Opt_Out__pc){
            currentRecord.LR_Eve_Exp_SMS__pc = true;
            currentRecord.LR_InCon_Conn_SMS__pc = true;
            currentRecord.LR_Own_Veh_SMS__pc = true;
            currentRecord.LR_Par_Spo_SMS__pc = true;
            currentRecord.LR_Pro_Off_SMS__pc = true;
            currentRecord.LR_Pro_Ser_SMS__pc = true;
            currentRecord.LR_Sur_Res_SMS__pc = true;
            
        }
        
        if(currentRecord.Jaguar_Whitemail_Opt_Out__pc){
            currentRecord.J_Eve_Exp_Direct_Mail__pc = true;
            currentRecord.J_InCon_Conn_Direct_Mail__pc = true;
            currentRecord.J_Own_Veh_Direct_Mail__pc = true;
            currentRecord.J_Par_Spo_Direct_Mail__pc = true;
            currentRecord.J_Pro_Off_Direct_Mail__pc = true;
            currentRecord.J_Pro_Ser_Direct_Mail__pc = true;
            currentRecord.J_Sur_Res_Direct_Mail__pc = true;
            
        }
        if(currentRecord.Jaguar_Email_Opt_Out__pc){
            currentRecord.J_Eve_Exp_Email__pc = true;
            currentRecord.J_InCon_Conn_Email__pc = true;
            currentRecord.J_Own_Veh_Email__pc = true;
            currentRecord.J_Par_Spo_Email__pc = true;
            currentRecord.J_Pro_Off_Email__pc = true;
            currentRecord.J_Pro_Ser_Email__pc = true;
            currentRecord.J_Sur_Res_Email__pc = true;
        }
        
        if(currentRecord.Jaguar_Phone_Opt_Out__pc){
            currentRecord.J_Eve_Exp_Phone__pc = true;
            currentRecord.J_InCon_Conn_Phone__pc = true;
            currentRecord.J_Own_Veh_Phone__pc = true;
            currentRecord.J_Par_Spo_Phone__pc = true;
            currentRecord.J_Pro_Off_Phone__pc = true;
            currentRecord.J_Pro_Ser_Phone__pc = true;
            currentRecord.J_Sur_Res_Phone__pc = true;
            
        }
        if(currentRecord.Jaguar_SMS_Opt_Out__pc){
            currentRecord.J_Eve_Exp_SMS__pc = true;
            currentRecord.J_InCon_Conn_SMS__pc = true;
            currentRecord.J_Own_Veh_SMS__pc = true;
            currentRecord.J_Par_Spo_SMS__pc = true;
            currentRecord.J_Pro_Off_SMS__pc = true;
            currentRecord.J_Pro_Ser_SMS__pc = true;
            currentRecord.J_Sur_Res_SMS__pc = true;
            
        } 
        component.set("v.currentAccount",currentRecord);
    },
    
    allTopsOptOut: function(component, event, helper, currentAccount) { 
        var currentRecord = currentAccount;
        if(currentRecord.All_Topics_Opt_Out__pc){
            currentRecord.Jaguar_Opt_out_all_Topics__pc = true;
            currentRecord.Land_Rover_Opt_out_all_Topics__pc = true;
            this.LRAllTopisOptOut(component, event, helper, currentRecord);
            this.JAllTopisOptOut(component, event, helper, currentRecord);            
        } 
        component.set("v.currentAccount",currentRecord);
    },
    JLRTopsOptIn: function(component, event, helper, currentAccount) { 
        var currentRecord = currentAccount;
        if( currentRecord.Jaguar_Opt_out_all_Topics__pc || currentRecord.Land_Rover_Opt_out_all_Topics__pc ){
            currentRecord.All_Topics_Opt_Out__pc =false;
            currentRecord.All_Communications_opt_out__pc =false;
        } 
        component.set("v.currentAccount",currentRecord);
    },
    LRAllTopisOptOut : function(component, event, helper, currentAccount) { 
        var currentRecord = currentAccount;
        if( currentRecord.Land_Rover_Opt_out_all_Topics__pc){
            currentRecord.Land_Rover_Event_Experiences_Opt_Out__pc = true;
            currentRecord.Land_Rover_In_Control_Connected_Opt_Out__pc = true;
            currentRecord.Land_Rover_Owner_Vehicle_Comm_Opt_Out__pc = true;
            currentRecord.Land_Rover_Partners_Sponsorship_Opt_Out__pc = true;
            currentRecord.Land_Rover_Products_Services_Opt_Out__pc = true;
            currentRecord.Land_Rover_Promotions_Offers_Opt_Out__pc = true;
            currentRecord.Land_Rover_Surveys_and_Research_Opt_Out__pc = true;
            this.LReventExperiencesOptOut(component, event, helper, currentRecord);
        } 
        component.set("v.currentAccount",currentRecord);
    },    
    JAllTopisOptOut : function(component, event, helper, currentAccount) { 
        var currentRecord = currentAccount;
        if( currentRecord.Jaguar_Opt_out_all_Topics__pc){
            currentRecord.Jaguar_Event_Experiences_Opt_Out__pc = true;
            currentRecord.Jaguar_In_Control_Connected_Opt_Out__pc = true;
            currentRecord.Jaguar_Owner_Vehicle_Comm_Opt_Out__pc = true;
            currentRecord.Jaguar_Partners_Sponsorship_Opt_Out__pc = true;
            currentRecord.Jaguar_Products_Services_Opt_Out__pc = true;
            currentRecord.Jaguar_Promotions_Offers_Opt_Out__pc = true;
            currentRecord.Jaguar_Surveys_and_Research_Opt_Out__pc = true; 
            this.JeventExperiencesOptOut(component, event, helper, currentRecord); 
        } 
        component.set("v.currentAccount",currentRecord);
    },
    LRAllTopisOptIn : function(component, event, helper, currentAccount) { 
        var currentRecord = currentAccount;
        if(  !currentRecord.Land_Rover_Event_Experiences_Opt_Out__pc || !currentRecord.Land_Rover_In_Control_Connected_Opt_Out__pc ||
           !currentRecord.Land_Rover_Owner_Vehicle_Comm_Opt_Out__pc || !currentRecord.Land_Rover_Partners_Sponsorship_Opt_Out__pc ||
           !currentRecord.Land_Rover_Products_Services_Opt_Out__pc || !currentRecord.Land_Rover_Promotions_Offers_Opt_Out__pc ||
           !currentRecord.Land_Rover_Surveys_and_Research_Opt_Out__pc ){
            currentRecord.Land_Rover_Opt_out_all_Topics__pc = false;
            this.JLRTopsOptIn(component, event, helper, currentRecord);
        } 
        component.set("v.currentAccount",currentRecord);
    },    
    JAllTopisOptIn : function(component, event, helper, currentAccount) { 
        var currentRecord = currentAccount;
        if( !currentRecord.Jaguar_Event_Experiences_Opt_Out__pc ||  !currentRecord.Jaguar_In_Control_Connected_Opt_Out__pc || 
           !currentRecord.Jaguar_Owner_Vehicle_Comm_Opt_Out__pc || !currentRecord.Jaguar_Partners_Sponsorship_Opt_Out__pc || 
           !currentRecord.Jaguar_Products_Services_Opt_Out__pc  ||   !currentRecord.Jaguar_Promotions_Offers_Opt_Out__pc  || 
           !currentRecord.Jaguar_Surveys_and_Research_Opt_Out__pc  ){
            currentRecord.Jaguar_Opt_out_all_Topics__pc = false;
            this.JLRTopsOptIn(component, event, helper, currentRecord); 
        } 
        component.set("v.currentAccount",currentRecord);
    },
    LReventExperiencesOptOut : function(component, event, helper, currentAccount) { 
        var currentRecord = currentAccount;
        if( currentRecord.Land_Rover_Event_Experiences_Opt_Out__pc){
            currentRecord.LR_Eve_Exp_Email__pc =true;
            currentRecord.LR_Eve_Exp_Phone__pc =true;
            currentRecord.LR_Eve_Exp_Direct_Mail__pc =true;
            currentRecord.LR_Eve_Exp_SMS__pc =true;
        } 
        if( currentRecord.Land_Rover_In_Control_Connected_Opt_Out__pc){
            currentRecord.LR_InCon_Conn_Email__pc =true;
            currentRecord.LR_InCon_Conn_Phone__pc =true;
            currentRecord.LR_InCon_Conn_Direct_Mail__pc =true;
            currentRecord.LR_InCon_Conn_SMS__pc =true;
        }
        if( currentRecord.Land_Rover_Owner_Vehicle_Comm_Opt_Out__pc){
            currentRecord.LR_Own_Veh_Email__pc =true;
            currentRecord.LR_Own_Veh_Phone__pc =true;
            currentRecord.LR_Own_Veh_Direct_Mail__pc =true;
            currentRecord.LR_Own_Veh_SMS__pc =true;
        }
        if( currentRecord.Land_Rover_Partners_Sponsorship_Opt_Out__pc){
            currentRecord.LR_Par_Spo_Email__pc =true;
            currentRecord.LR_Par_Spo_Phone__pc =true;
            currentRecord.LR_Par_Spo_Direct_Mail__pc =true;
            currentRecord.LR_Par_Spo_SMS__pc =true;
        }
        if( currentRecord.Land_Rover_Products_Services_Opt_Out__pc){
            currentRecord.LR_Pro_Ser_Email__pc =true;
            currentRecord.LR_Pro_Ser_Phone__pc =true;
            currentRecord.LR_Pro_Ser_Direct_Mail__pc =true;
            currentRecord.LR_Pro_Ser_SMS__pc =true;
        }
        if( currentRecord.Land_Rover_Promotions_Offers_Opt_Out__pc){
            currentRecord.LR_Pro_Off_Email__pc =true;
            currentRecord.LR_Pro_Off_Phone__pc =true;
            currentRecord.LR_Pro_Off_Direct_Mail__pc =true;
            currentRecord.LR_Pro_Off_SMS__pc =true;
        }
        if( currentRecord.Land_Rover_Surveys_and_Research_Opt_Out__pc){
            currentRecord.LR_Sur_Res_Email__pc =true;
            currentRecord.LR_Sur_Res_Phone__pc =true;
            currentRecord.LR_Sur_Res_Direct_Mail__pc =true;
            currentRecord.LR_Sur_Res_SMS__pc =true;
        }
        component.set("v.currentAccount",currentRecord);
        
    },
    JeventExperiencesOptOut : function(component, event, helper, currentAccount) { 
        var currentRecord = currentAccount;
        if( currentRecord.Jaguar_Event_Experiences_Opt_Out__pc){
            currentRecord.J_Eve_Exp_Email__pc =true;
            currentRecord.J_Eve_Exp_Phone__pc =true;
            currentRecord.J_Eve_Exp_Direct_Mail__pc =true;
            currentRecord.J_Eve_Exp_SMS__pc =true;
        }
        if( currentRecord.Jaguar_In_Control_Connected_Opt_Out__pc){
            currentRecord.J_InCon_Conn_Email__pc =true;
            currentRecord.J_InCon_Conn_Phone__pc =true;
            currentRecord.J_InCon_Conn_Direct_Mail__pc =true;
            currentRecord.J_InCon_Conn_SMS__pc =true;
        }
        if( currentRecord.Jaguar_Owner_Vehicle_Comm_Opt_Out__pc){
            currentRecord.J_Own_Veh_Email__pc =true;
            currentRecord.J_Own_Veh_Phone__pc =true;
            currentRecord.J_Own_Veh_Direct_Mail__pc =true;
            currentRecord.J_Own_Veh_SMS__pc =true;
        }
        if( currentRecord.Jaguar_Partners_Sponsorship_Opt_Out__pc){
            currentRecord.J_Par_Spo_Email__pc =true;
            currentRecord.J_Par_Spo_Phone__pc =true;
            currentRecord.J_Par_Spo_Direct_Mail__pc =true;
            currentRecord.J_Par_Spo_SMS__pc =true;
        }
        if( currentRecord.Jaguar_Products_Services_Opt_Out__pc){
            currentRecord.J_Pro_Ser_Email__pc =true;
            currentRecord.J_Pro_Ser_Phone__pc =true;
            currentRecord.J_Pro_Ser_Direct_Mail__pc =true;
            currentRecord.J_Pro_Ser_SMS__pc =true;
        }
        if( currentRecord.Jaguar_Promotions_Offers_Opt_Out__pc){
            currentRecord.J_Pro_Off_Email__pc =true;
            currentRecord.J_Pro_Off_Phone__pc =true;
            currentRecord.J_Pro_Off_Direct_Mail__pc =true;
            currentRecord.J_Pro_Off_SMS__pc =true;
        }
        if( currentRecord.Jaguar_Surveys_and_Research_Opt_Out__pc){
            currentRecord.J_Sur_Res_Email__pc =true;
            currentRecord.J_Sur_Res_Phone__pc =true;
            currentRecord.J_Sur_Res_Direct_Mail__pc =true;
            currentRecord.J_Sur_Res_SMS__pc =true;
        }
        
        component.set("v.currentAccount",currentRecord);
    },
    LReventExperiencesOptIn : function(component, event, helper, currentAccount) { 
        var currentRecord = currentAccount;
        if(!currentRecord.LR_Eve_Exp_Email__pc || !currentRecord.LR_Eve_Exp_Phone__pc || 
           !currentRecord.LR_Eve_Exp_Direct_Mail__pc ||  !currentRecord.LR_Eve_Exp_SMS__pc ){
            currentRecord.Land_Rover_Event_Experiences_Opt_Out__pc = false;
            this.LRAllTopisOptIn(component, event, helper, currentRecord); 
        } 
        if(!currentRecord.LR_InCon_Conn_Email__pc || !currentRecord.LR_InCon_Conn_Phone__pc 
           || !currentRecord.LR_InCon_Conn_Direct_Mail__pc || !currentRecord.LR_InCon_Conn_SMS__pc ){
            currentRecord.Land_Rover_In_Control_Connected_Opt_Out__pc = false;
            this.LRAllTopisOptIn(component, event, helper, currentRecord); 
            this.LRAllTopisOptIn(component, event, helper, currentRecord); 
        } 
        if( !currentRecord.LR_Own_Veh_Email__pc || !currentRecord.LR_Own_Veh_Phone__pc ||
           !currentRecord.LR_Own_Veh_Direct_Mail__pc ||  !currentRecord.LR_Own_Veh_SMS__pc ){
            currentRecord.Land_Rover_Owner_Vehicle_Comm_Opt_Out__pc =false;
            this.LRAllTopisOptIn(component, event, helper, currentRecord); 
        }
        if( !currentRecord.LR_Par_Spo_Email__pc || !currentRecord.LR_Par_Spo_Phone__pc ||
           !currentRecord.LR_Par_Spo_Direct_Mail__pc || !currentRecord.LR_Par_Spo_SMS__pc ){
            currentRecord.Land_Rover_Partners_Sponsorship_Opt_Out__pc =false;
            this.LRAllTopisOptIn(component, event, helper, currentRecord); 
        }
        if( !currentRecord.LR_Pro_Ser_Email__pc || !currentRecord.LR_Pro_Ser_Phone__pc ||
           !currentRecord.LR_Pro_Ser_Direct_Mail__pc || !currentRecord.LR_Pro_Ser_SMS__pc ){
            currentRecord.Land_Rover_Products_Services_Opt_Out__pc =false;
            this.LRAllTopisOptIn(component, event, helper, currentRecord); 
        }
        if( !currentRecord.LR_Pro_Off_Email__pc || !currentRecord.LR_Pro_Off_Phone__pc || 
           !currentRecord.LR_Pro_Off_Direct_Mail__pc || !currentRecord.LR_Pro_Off_SMS__pc){
            currentRecord.Land_Rover_Promotions_Offers_Opt_Out__pc =false;
            this.LRAllTopisOptIn(component, event, helper, currentRecord); 
        }
        if( !currentRecord.LR_Sur_Res_Email__pc || !currentRecord.LR_Sur_Res_Phone__pc ||
           !currentRecord.LR_Sur_Res_Direct_Mail__pc || !currentRecord.LR_Sur_Res_SMS__pc){
            currentRecord.Land_Rover_Surveys_and_Research_Opt_Out__pc =false;
            this.LRAllTopisOptIn(component, event, helper, currentRecord); 
        }
        if(!currentRecord.LR_Eve_Exp_Direct_Mail__pc || 
           !currentRecord.LR_InCon_Conn_Direct_Mail__pc || 
           !currentRecord.LR_Own_Veh_Direct_Mail__pc || 
           !currentRecord.LR_Par_Spo_Direct_Mail__pc || 
           !currentRecord.LR_Pro_Off_Direct_Mail__pc || 
           !currentRecord.LR_Pro_Ser_Direct_Mail__pc || 
           !currentRecord.LR_Sur_Res_Direct_Mail__pc ){
            currentRecord.Land_Rover_Whitemail_Opt_Out__pc = false;
        }
        if(!currentRecord.LR_Eve_Exp_Email__pc || 
           !currentRecord.LR_InCon_Conn_Email__pc || 
           !currentRecord.LR_Own_Veh_Email__pc || 
           !currentRecord.LR_Par_Spo_Email__pc || 
           !currentRecord.LR_Pro_Off_Email__pc || 
           !currentRecord.LR_Pro_Ser_Email__pc || 
           !currentRecord.LR_Sur_Res_Email__pc ){ 
            currentRecord.Land_Rover_Email_Opt_Out__pc = false;
            
        }
        
        if(!currentRecord.LR_Eve_Exp_Phone__pc || 
           !currentRecord.LR_InCon_Conn_Phone__pc || 
           !currentRecord.LR_Own_Veh_Phone__pc || 
           !currentRecord.LR_Par_Spo_Phone__pc || 
           !currentRecord.LR_Pro_Off_Phone__pc || 
           !currentRecord.LR_Pro_Ser_Phone__pc || 
           !currentRecord.LR_Sur_Res_Phone__pc ){
            currentRecord.Land_Rover_Phone_Opt_Out__pc = false;            
        }
        if(
            !currentRecord.LR_Eve_Exp_SMS__pc || 
            !currentRecord.LR_InCon_Conn_SMS__pc || 
            !currentRecord.LR_Own_Veh_SMS__pc || 
            !currentRecord.LR_Par_Spo_SMS__pc || 
            !currentRecord.LR_Pro_Off_SMS__pc || 
            !currentRecord.LR_Pro_Ser_SMS__pc || 
            !currentRecord.LR_Sur_Res_SMS__pc ){
            currentRecord.Land_Rover_SMS_Opt_Out__pc = false;
            
        }       
        helper.mainOptIn(component, event, helper, currentRecord);
        component.set("v.currentAccount",currentRecord);
    },
    JeventExperiencesOptIn : function(component, event, helper, currentAccount) { 
        var currentRecord = currentAccount;
        if(!currentRecord.J_Eve_Exp_Email__pc || !currentRecord.J_Eve_Exp_Phone__pc || !currentRecord.J_Eve_Exp_Direct_Mail__pc ||
           !currentRecord.J_Eve_Exp_SMS__pc ){
            currentRecord.Jaguar_Event_Experiences_Opt_Out__pc = false;
            this.JAllTopisOptIn(component, event, helper, currentRecord); 
        } 
        if(!currentRecord.J_InCon_Conn_Email__pc || !currentRecord.J_InCon_Conn_Phone__pc || !currentRecord.J_InCon_Conn_Direct_Mail__pc ||
           !currentRecord.J_InCon_Conn_SMS__pc ){
            currentRecord.Jaguar_In_Control_Connected_Opt_Out__pc = false;
            this.JAllTopisOptIn(component, event, helper, currentRecord); 
        } 
        if( !currentRecord.J_Own_Veh_Email__pc || !currentRecord.J_Own_Veh_Phone__pc ||
           !currentRecord.J_Own_Veh_Direct_Mail__pc ||  !currentRecord.J_Own_Veh_SMS__pc ){
            currentRecord.Jaguar_Owner_Vehicle_Comm_Opt_Out__pc =false;
            this.JAllTopisOptIn(component, event, helper, currentRecord);
        }
        if( !currentRecord.J_Par_Spo_Email__pc || !currentRecord.J_Par_Spo_Phone__pc ||
           !currentRecord.J_Par_Spo_Direct_Mail__pc || !currentRecord.J_Par_Spo_SMS__pc ){
            currentRecord.Jaguar_Partners_Sponsorship_Opt_Out__pc =false;
            this.JAllTopisOptIn(component, event, helper, currentRecord);
        }
        if( !currentRecord.J_Pro_Ser_Email__pc || !currentRecord.J_Pro_Ser_Phone__pc ||
           !currentRecord.J_Pro_Ser_Direct_Mail__pc || !currentRecord.J_Pro_Ser_SMS__pc ){
            currentRecord.Jaguar_Products_Services_Opt_Out__pc =false;
            this.JAllTopisOptIn(component, event, helper, currentRecord);
        }
        if( !currentRecord.J_Pro_Off_Email__pc || !currentRecord.J_Pro_Off_Phone__pc || 
           !currentRecord.J_Pro_Off_Direct_Mail__pc || !currentRecord.J_Pro_Off_SMS__pc){
            currentRecord.Jaguar_Promotions_Offers_Opt_Out__pc =false;
            this.JAllTopisOptIn(component, event, helper, currentRecord);
        }
        if( !currentRecord.J_Sur_Res_Email__pc || !currentRecord.J_Sur_Res_Phone__pc ||
           !currentRecord.J_Sur_Res_Direct_Mail__pc || !currentRecord.J_Sur_Res_SMS__pc){
            currentRecord.Jaguar_Surveys_and_Research_Opt_Out__pc =false;
            this.JAllTopisOptIn(component, event, helper, currentRecord);
        }
                
        if(!currentRecord.J_Eve_Exp_Direct_Mail__pc || 
           !currentRecord.J_InCon_Conn_Direct_Mail__pc || 
           !currentRecord.J_Own_Veh_Direct_Mail__pc || 
           !currentRecord.J_Par_Spo_Direct_Mail__pc || 
           !currentRecord.J_Pro_Off_Direct_Mail__pc || 
           !currentRecord.J_Pro_Ser_Direct_Mail__pc || 
           !currentRecord.J_Sur_Res_Direct_Mail__pc ){
            currentRecord.Jaguar_Whitemail_Opt_Out__pc = false;
        }
        if(!currentRecord.J_Eve_Exp_Email__pc || 
           !currentRecord.J_InCon_Conn_Email__pc || 
           !currentRecord.J_Own_Veh_Email__pc || 
           !currentRecord.J_Par_Spo_Email__pc || 
           !currentRecord.J_Pro_Off_Email__pc || 
           !currentRecord.J_Pro_Ser_Email__pc || 
           !currentRecord.J_Sur_Res_Email__pc ){
            currentRecord.Jaguar_Email_Opt_Out__pc =false;
        }
        if(!currentRecord.J_Eve_Exp_Phone__pc || 
            !currentRecord.J_InCon_Conn_Phone__pc || 
            !currentRecord.J_Own_Veh_Phone__pc || 
            !currentRecord.J_Par_Spo_Phone__pc || 
            !currentRecord.J_Pro_Off_Phone__pc || 
            !currentRecord.J_Pro_Ser_Phone__pc || 
            !currentRecord.J_Sur_Res_Phone__pc ){
            currentRecord.Jaguar_Phone_Opt_Out__pc = false;
        }
        if(!currentRecord.J_Eve_Exp_SMS__pc || 
           !currentRecord.J_InCon_Conn_SMS__pc || 
           !currentRecord.J_Own_Veh_SMS__pc || 
           !currentRecord.J_Par_Spo_SMS__pc || 
           !currentRecord.J_Pro_Off_SMS__pc || 
           !currentRecord.J_Pro_Ser_SMS__pc || 
           !currentRecord.J_Sur_Res_SMS__pc ){ 
            currentRecord.Jaguar_SMS_Opt_Out__pc =false;
        }
                helper.mainOptIn(component, event, helper, currentRecord);
        component.set("v.currentAccount",currentRecord);
    },
})