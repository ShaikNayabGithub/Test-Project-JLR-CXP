public class AccountPreferencesUpdateController {
    @AuraEnabled
    public static Account getAccount(String accountId) {
        
        return [SELECT Id,IsPersonAccount, Jaguar_SMS_Opt_Out__pc,Jaguar_Opt_Out__pc,Jaguar_Phone_Opt_Out__pc,Jaguar_Email_Opt_Out__pc,Jaguar_Whitemail_Opt_Out__pc, 
                All_Communications_opt_out__pc,Land_Rover_SMS_Opt_Out__pc,Land_Rover_Opt_Out__pc,Land_Rover_Phone_Opt_Out__pc,Land_Rover_Email_Opt_Out__pc,
                Land_Rover_Whitemail_Opt_Out__pc,LR_Own_Veh_Direct_Mail__pc, J_Own_Veh_Direct_Mail__pc,Land_Rover_Event_Experiences_Opt_Out__pc,
                Land_Rover_In_Control_Connected_Opt_Out__pc,Land_Rover_Opt_out_all_Topics__pc,Land_Rover_Owner_Vehicle_Comm_Opt_Out__pc,Land_Rover_Partners_Sponsorship_Opt_Out__pc,
                Land_Rover_Products_Services_Opt_Out__pc,Land_Rover_Promotions_Offers_Opt_Out__pc,Land_Rover_Surveys_and_Research_Opt_Out__pc,Jaguar_Event_Experiences_Opt_Out__pc,
                Jaguar_In_Control_Connected_Opt_Out__pc,Jaguar_Opt_out_all_Topics__pc,Jaguar_Owner_Vehicle_Comm_Opt_Out__pc,Jaguar_Partners_Sponsorship_Opt_Out__pc,
                Jaguar_Products_Services_Opt_Out__pc,Jaguar_Promotions_Offers_Opt_Out__pc,Jaguar_Surveys_and_Research_Opt_Out__pc,All_Topics_Opt_Out__pc,LR_Own_Veh_Phone__pc, 
                J_Own_Veh_Phone__pc,LR_Own_Veh_Email__pc,J_Own_Veh_Email__pc,LR_Own_Veh_SMS__pc,J_Own_Veh_SMS__pc,LR_InCon_Conn_Direct_Mail__pc,J_InCon_Conn_Direct_Mail__pc,
                LR_InCon_Conn_Phone__pc,J_InCon_Conn_Phone__pc,LR_InCon_Conn_Email__pc,J_InCon_Conn_Email__pc,LR_InCon_Conn_SMS__pc,J_InCon_Conn_SMS__pc,LR_Eve_Exp_Direct_Mail__pc,
                J_Eve_Exp_Direct_Mail__pc,LR_Eve_Exp_Phone__pc,J_Eve_Exp_Phone__pc,LR_Eve_Exp_Email__pc,J_Eve_Exp_Email__pc,LR_Eve_Exp_SMS__pc,J_Eve_Exp_SMS__pc,
                LR_Par_Spo_Direct_Mail__pc,J_Par_Spo_Direct_Mail__pc,LR_Par_Spo_Phone__pc,J_Par_Spo_Phone__pc,LR_Par_Spo_Email__pc,J_Par_Spo_Email__pc, LR_Par_Spo_SMS__pc,
                J_Par_Spo_SMS__pc,LR_Pro_Ser_Direct_Mail__pc,J_Pro_Ser_Direct_Mail__pc,LR_Pro_Ser_Phone__pc,J_Pro_Ser_Phone__pc,LR_Pro_Ser_Email__pc,J_Pro_Ser_Email__pc,
                LR_Pro_Ser_SMS__pc,J_Pro_Ser_SMS__pc,LR_Pro_Off_Direct_Mail__pc,J_Pro_Off_Direct_Mail__pc,LR_Pro_Off_Phone__pc,J_Pro_Off_Phone__pc,LR_Pro_Off_Email__pc, 
                J_Pro_Off_Email__pc, LR_Pro_Off_SMS__pc,J_Pro_Off_SMS__pc, LR_Sur_Res_Direct_Mail__pc,J_Sur_Res_Direct_Mail__pc, LR_Sur_Res_Phone__pc,J_Sur_Res_Phone__pc,
                PersonDoNotCall,et4ae5__HasOptedOutOfMobile__pc,Direct_Mail_Opt_Out__pc,PersonHasOptedOutOfEmail,
                LR_Sur_Res_Email__pc,J_Sur_Res_Email__pc,LR_Sur_Res_SMS__pc,J_Sur_Res_SMS__pc FROM Account WHERE Id =:accountId];      
    }
    @AuraEnabled
    public static Boolean getAccountAccess(String accountId) {
        return  [SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId = :userinfo.getUserId() AND RecordId = :accountId].HasEditAccess;   
    } 
    @AuraEnabled
    public static Map<String,String> getAccountLabelMap(String objectName) {       
        return SchemaUtility.getObjectLabelMap(objectName);
    }
    @AuraEnabled
    public static AccountSaveResult saveAccount(Account account) {
        AccountSaveResult saveResult = new AccountSaveResult();
        try {
            update account; 
            saveResult.updatedAccount = account;
        }catch(System.DmlException e){
            system.debug('error Message'+e.getDmlMessage(0));
            saveResult.errorMessage = ''+e.getDmlMessage(0);
        }
        
        return saveResult;      
    }
    
    public class AccountSaveResult {
        @AuraEnabled
        public Account updatedAccount = new Account();
        @AuraEnabled
        public String errorMessage = 'No Error';
    }
}