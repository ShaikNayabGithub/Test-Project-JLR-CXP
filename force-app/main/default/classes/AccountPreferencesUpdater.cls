public class AccountPreferencesUpdater {
    
    public static void preferencesUpdateOnPreInsert(List<Account> triggerNewList) {        
        for(Account newAccount: triggerNewList){
            if(newAccount.IsPersonAccount){
                if(newAccount.All_Communications_opt_out__pc){                
                    newAccount.PersonDoNotCall =true;
                    newAccount.PersonHasOptedOutOfEmail = true;
                    newAccount.Direct_Mail_Opt_Out__pc = true;
                    newAccount.et4ae5__HasOptedOutOfMobile__pc = true;
                }
                
                if(newAccount.PersonDoNotCall){
                    phonePreferencesSet(newAccount,true);
                }
                if(newAccount.PersonHasOptedOutOfEmail){
                    emailPreferencesSet(newAccount,true);
                }
                if(newAccount.Direct_Mail_Opt_Out__pc){
                    directMailPreferencesSet(newAccount,true);
                }
                if(newAccount.et4ae5__HasOptedOutOfMobile__pc){
                    SMSPreferencesSet(newAccount,true);
                }
                if(newAccount.Deceased_Date__pc != null){
                    setAllPreferences(newAccount,true);
                }
            }
        }        
    }
    public static void preferencesUpdateOnPreUpdate(List<Account> triggerNewList, Map<id,Account> triggerOldMap) {        
        for(Account newAccount: triggerNewList){
            if(newAccount.IsPersonAccount){
                if(newAccount.All_Communications_opt_out__pc != triggerOldMap.get(newAccount.Id).All_Communications_opt_out__pc  && newAccount.All_Communications_opt_out__pc ){                
                    newAccount.PersonDoNotCall =true;
                    newAccount.PersonHasOptedOutOfEmail = true;
                    newAccount.Direct_Mail_Opt_Out__pc = true;
                    newAccount.et4ae5__HasOptedOutOfMobile__pc = true;
                }
                if(newAccount.PersonDoNotCall != triggerOldMap.get(newAccount.Id).PersonDoNotCall  && newAccount.PersonDoNotCall){
                    phonePreferencesSet(newAccount,true);
                }
                if(newAccount.PersonHasOptedOutOfEmail != triggerOldMap.get(newAccount.Id).PersonHasOptedOutOfEmail && newAccount.PersonHasOptedOutOfEmail){
                    emailPreferencesSet(newAccount,true);
                }
                if(newAccount.Direct_Mail_Opt_Out__pc != triggerOldMap.get(newAccount.Id).Direct_Mail_Opt_Out__pc && newAccount.Direct_Mail_Opt_Out__pc){
                    directMailPreferencesSet(newAccount,true);
                }
                if(newAccount.et4ae5__HasOptedOutOfMobile__pc != triggerOldMap.get(newAccount.Id).et4ae5__HasOptedOutOfMobile__pc && newAccount.et4ae5__HasOptedOutOfMobile__pc){
                    SMSPreferencesSet(newAccount,true);
                }
                
                if((newAccount.Jaguar_Phone_Opt_Out__pc != triggerOldMap.get(newAccount.Id).Jaguar_Phone_Opt_Out__pc && !newAccount.Jaguar_Phone_Opt_Out__pc) ||
                   (newAccount.Land_Rover_Phone_Opt_Out__pc != triggerOldMap.get(newAccount.Id).Land_Rover_Phone_Opt_Out__pc && !newAccount.Land_Rover_Phone_Opt_Out__pc)){
                       newAccount.PersonDoNotCall = false; 
                   }
                if((newAccount.Jaguar_Email_Opt_Out__pc != triggerOldMap.get(newAccount.Id).Jaguar_Email_Opt_Out__pc && !newAccount.Jaguar_Email_Opt_Out__pc) ||
                   (newAccount.Land_Rover_Email_Opt_Out__pc != triggerOldMap.get(newAccount.Id).Land_Rover_Email_Opt_Out__pc && !newAccount.Land_Rover_Email_Opt_Out__pc)){
                       newAccount.PersonHasOptedOutOfEmail = false; 
                   }
                if((newAccount.Jaguar_Whitemail_Opt_Out__pc != triggerOldMap.get(newAccount.Id).Jaguar_Whitemail_Opt_Out__pc && !newAccount.Jaguar_Whitemail_Opt_Out__pc) ||
                   (newAccount.Land_Rover_Whitemail_Opt_Out__pc != triggerOldMap.get(newAccount.Id).Land_Rover_Whitemail_Opt_Out__pc && !newAccount.Land_Rover_Whitemail_Opt_Out__pc)){
                       newAccount.Direct_Mail_Opt_Out__pc = false; 
                   }
                if((newAccount.Jaguar_SMS_Opt_Out__pc != triggerOldMap.get(newAccount.Id).Jaguar_SMS_Opt_Out__pc && !newAccount.Jaguar_SMS_Opt_Out__pc) ||
                   (newAccount.Land_Rover_SMS_Opt_Out__pc != triggerOldMap.get(newAccount.Id).Land_Rover_SMS_Opt_Out__pc && !newAccount.Land_Rover_SMS_Opt_Out__pc)){
                       newAccount.et4ae5__HasOptedOutOfMobile__pc = false; 
                   }
                if(newAccount.Deceased_Date__pc != triggerOldMap.get(newAccount.Id).Deceased_Date__pc && newAccount.Deceased_Date__pc != null){
                    setAllPreferences(newAccount,true);
                }else if(newAccount.Deceased_Date__pc != triggerOldMap.get(newAccount.Id).Deceased_Date__pc && newAccount.Deceased_Date__pc == null){
                    setAllPreferences(newAccount,false);
                }
            }
        }        
    }
    
    public static void phonePreferencesSet(Account newAccount, Boolean valueSet){
        newAccount.Jaguar_Phone_Opt_Out__pc = valueSet;                    
        newAccount.J_Eve_Exp_Phone__pc = valueSet;
        newAccount.J_InCon_Conn_Phone__pc = valueSet;
        newAccount.J_Own_Veh_Phone__pc = valueSet;
        newAccount.J_Par_Spo_Phone__pc = valueSet;
        newAccount.J_Pro_Off_Phone__pc = valueSet;
        newAccount.J_Pro_Ser_Phone__pc = valueSet;
        newAccount.J_Sur_Res_Phone__pc = valueSet;
        newAccount.Land_Rover_Phone_Opt_Out__pc = valueSet;
        newAccount.LR_Eve_Exp_Phone__pc = valueSet;
        newAccount.LR_InCon_Conn_Phone__pc = valueSet;
        newAccount.LR_Own_Veh_Phone__pc = valueSet;
        newAccount.LR_Par_Spo_Phone__pc = valueSet;
        newAccount.LR_Pro_Off_Phone__pc = valueSet;
        newAccount.LR_Pro_Ser_Phone__pc = valueSet;
        newAccount.LR_Sur_Res_Phone__pc = valueSet;
        
    }
    public static void emailPreferencesSet(Account newAccount, Boolean valueSet){
        newAccount.Jaguar_Email_Opt_Out__pc = valueSet;                    
        newAccount.J_Eve_Exp_Email__pc = valueSet;
        newAccount.J_InCon_Conn_Email__pc = valueSet;
        newAccount.J_Own_Veh_Email__pc = valueSet;
        newAccount.J_Par_Spo_Email__pc = valueSet;
        newAccount.J_Pro_Off_Email__pc = valueSet;
        newAccount.J_Pro_Ser_Email__pc = valueSet;
        newAccount.J_Sur_Res_Email__pc = valueSet;
        newAccount.Land_Rover_Email_Opt_Out__pc = valueSet;
        newAccount.LR_Eve_Exp_Email__pc = valueSet;
        newAccount.LR_InCon_Conn_Email__pc = valueSet;
        newAccount.LR_Own_Veh_Email__pc = valueSet;
        newAccount.LR_Par_Spo_Email__pc = valueSet;
        newAccount.LR_Pro_Off_Email__pc = valueSet;
        newAccount.LR_Pro_Ser_Email__pc = valueSet;
        newAccount.LR_Sur_Res_Email__pc = valueSet;
        
    }
    public static void directMailPreferencesSet(Account newAccount, Boolean valueSet){
        newAccount.Jaguar_Whitemail_Opt_Out__pc = valueSet;                    
        newAccount.J_Eve_Exp_Direct_Mail__pc = valueSet;
        newAccount.J_InCon_Conn_Direct_Mail__pc = valueSet;
        newAccount.J_Own_Veh_Direct_Mail__pc = valueSet;
        newAccount.J_Par_Spo_Direct_Mail__pc = valueSet;
        newAccount.J_Pro_Off_Direct_Mail__pc = valueSet;
        newAccount.J_Pro_Ser_Direct_Mail__pc = valueSet;
        newAccount.J_Sur_Res_Direct_Mail__pc = valueSet;
        newAccount.Land_Rover_Whitemail_Opt_Out__pc = valueSet;
        newAccount.LR_Eve_Exp_Direct_Mail__pc = valueSet;
        newAccount.LR_InCon_Conn_Direct_Mail__pc = valueSet;
        newAccount.LR_Own_Veh_Direct_Mail__pc = valueSet;
        newAccount.LR_Par_Spo_Direct_Mail__pc = valueSet;
        newAccount.LR_Pro_Off_Direct_Mail__pc = valueSet;
        newAccount.LR_Pro_Ser_Direct_Mail__pc = valueSet;
        newAccount.LR_Sur_Res_Direct_Mail__pc = valueSet;
        
    }
    public static void SMSPreferencesSet(Account newAccount, Boolean valueSet){
        newAccount.Jaguar_SMS_Opt_Out__pc = valueSet;                    
        newAccount.J_Eve_Exp_SMS__pc = valueSet;
        newAccount.J_InCon_Conn_SMS__pc = valueSet;
        newAccount.J_Own_Veh_SMS__pc = valueSet;
        newAccount.J_Par_Spo_SMS__pc = valueSet;
        newAccount.J_Pro_Off_SMS__pc = valueSet;
        newAccount.J_Pro_Ser_SMS__pc = valueSet;
        newAccount.J_Sur_Res_SMS__pc = valueSet;
        newAccount.Land_Rover_SMS_Opt_Out__pc = valueSet;
        newAccount.LR_Eve_Exp_SMS__pc = valueSet;
        newAccount.LR_InCon_Conn_SMS__pc = valueSet;
        newAccount.LR_Own_Veh_SMS__pc = valueSet;
        newAccount.LR_Par_Spo_SMS__pc = valueSet;
        newAccount.LR_Pro_Off_SMS__pc = valueSet;
        newAccount.LR_Pro_Ser_SMS__pc = valueSet;
        newAccount.LR_Sur_Res_SMS__pc = valueSet;
    }
    public static void setAllPreferences(Account newAccount, Boolean valueSet){
        newAccount.PersonDoNotCall = valueSet;
        newAccount.PersonHasOptedOutOfEmail = valueSet;
        newAccount.Direct_Mail_Opt_Out__pc = valueSet;
        newAccount.et4ae5__HasOptedOutOfMobile__pc = valueSet;
        newAccount.All_Communications_opt_out__pc = valueSet;
        newAccount.All_Topics_Opt_Out__pc = valueSet;
        newAccount.Jaguar_Opt_out_all_Topics__pc = valueSet;
        newAccount.Land_Rover_Opt_out_all_Topics__pc = valueSet;
        newAccount.Jaguar_Event_Experiences_Opt_Out__pc = valueSet;
        newAccount.Jaguar_In_Control_Connected_Opt_Out__pc = valueSet;
        newAccount.Jaguar_Owner_Vehicle_Comm_Opt_Out__pc = valueSet;
        newAccount.Jaguar_Partners_Sponsorship_Opt_Out__pc = valueSet;
        newAccount.Jaguar_Products_Services_Opt_Out__pc = valueSet;
        newAccount.Jaguar_Promotions_Offers_Opt_Out__pc = valueSet;
        newAccount.Jaguar_Surveys_and_Research_Opt_Out__pc = valueSet;
        newAccount.Land_Rover_Event_Experiences_Opt_Out__pc = valueSet;
        newAccount.Land_Rover_In_Control_Connected_Opt_Out__pc = valueSet;
        newAccount.Land_Rover_Owner_Vehicle_Comm_Opt_Out__pc = valueSet;
        newAccount.Land_Rover_Partners_Sponsorship_Opt_Out__pc = valueSet;
        newAccount.Land_Rover_Products_Services_Opt_Out__pc = valueSet;
        newAccount.Land_Rover_Promotions_Offers_Opt_Out__pc = valueSet;
        newAccount.Land_Rover_Surveys_and_Research_Opt_Out__pc = valueSet;
        phonePreferencesSet(newAccount,valueSet);
        emailPreferencesSet(newAccount,valueSet);
        directMailPreferencesSet(newAccount,valueSet);
        SMSPreferencesSet(newAccount,valueSet);
    }
    
    
}