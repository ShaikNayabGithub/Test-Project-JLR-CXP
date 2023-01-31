public class ContactPreferencesUpdateController {
    @AuraEnabled
    public static Contact getContact(String conId) {
        system.debug('Contact'+conId);
        return [SELECT Id, Jaguar_SMS_Opt_Out__c,Jaguar_Opt_Out__c,Jaguar_Phone_Opt_Out__c,Jaguar_Email_Opt_Out__c,Jaguar_Whitemail_Opt_Out__c, 
                All_Communications_opt_out__c,Land_Rover_SMS_Opt_Out__c,Land_Rover_Opt_Out__c,Land_Rover_Phone_Opt_Out__c,Land_Rover_Email_Opt_Out__c,
                Land_Rover_Whitemail_Opt_Out__c,LR_Own_Veh_Direct_Mail__c, J_Own_Veh_Direct_Mail__c,Land_Rover_Event_Experiences_Opt_Out__c,
                Land_Rover_In_Control_Connected_Opt_Out__c,Land_Rover_Opt_out_all_Topics__c,Land_Rover_Owner_Vehicle_Comm_Opt_Out__c,Land_Rover_Partners_Sponsorship_Opt_Out__c,
                Land_Rover_Products_Services_Opt_Out__c,Land_Rover_Promotions_Offers_Opt_Out__c,Land_Rover_Surveys_and_Research_Opt_Out__c,Jaguar_Event_Experiences_Opt_Out__c,
                Jaguar_In_Control_Connected_Opt_Out__c,Jaguar_Opt_out_all_Topics__c,Jaguar_Owner_Vehicle_Comm_Opt_Out__c,Jaguar_Partners_Sponsorship_Opt_Out__c,
                Jaguar_Products_Services_Opt_Out__c,Jaguar_Promotions_Offers_Opt_Out__c,Jaguar_Surveys_and_Research_Opt_Out__c,All_Topics_Opt_Out__c,LR_Own_Veh_Phone__c, 
                J_Own_Veh_Phone__c,LR_Own_Veh_Email__c,J_Own_Veh_Email__c,LR_Own_Veh_SMS__c,J_Own_Veh_SMS__c,LR_InCon_Conn_Direct_Mail__c,J_InCon_Conn_Direct_Mail__c,
                LR_InCon_Conn_Phone__c,J_InCon_Conn_Phone__c,LR_InCon_Conn_Email__c,J_InCon_Conn_Email__c,LR_InCon_Conn_SMS__c,J_InCon_Conn_SMS__c,LR_Eve_Exp_Direct_Mail__c,
                J_Eve_Exp_Direct_Mail__c,LR_Eve_Exp_Phone__c,J_Eve_Exp_Phone__c,LR_Eve_Exp_Email__c,J_Eve_Exp_Email__c,LR_Eve_Exp_SMS__c,J_Eve_Exp_SMS__c,
                LR_Par_Spo_Direct_Mail__c,J_Par_Spo_Direct_Mail__c,LR_Par_Spo_Phone__c,J_Par_Spo_Phone__c,LR_Par_Spo_Email__c,J_Par_Spo_Email__c, LR_Par_Spo_SMS__c,
                J_Par_Spo_SMS__c,LR_Pro_Ser_Direct_Mail__c,J_Pro_Ser_Direct_Mail__c,LR_Pro_Ser_Phone__c,J_Pro_Ser_Phone__c,LR_Pro_Ser_Email__c,J_Pro_Ser_Email__c,
                LR_Pro_Ser_SMS__c,J_Pro_Ser_SMS__c,LR_Pro_Off_Direct_Mail__c,J_Pro_Off_Direct_Mail__c,LR_Pro_Off_Phone__c,J_Pro_Off_Phone__c,LR_Pro_Off_Email__c, 
                J_Pro_Off_Email__c, LR_Pro_Off_SMS__c,J_Pro_Off_SMS__c, LR_Sur_Res_Direct_Mail__c,J_Sur_Res_Direct_Mail__c, LR_Sur_Res_Phone__c,J_Sur_Res_Phone__c,
                LR_Sur_Res_Email__c,J_Sur_Res_Email__c,LR_Sur_Res_SMS__c,J_Sur_Res_SMS__c FROM Contact WHERE Id =:conId];      
    }
    @AuraEnabled
    public static Boolean getContactAccess(String contId) {
        system.debug('Contact'+contId);
        system.debug('User'+userinfo.getUserId());
        return  [SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId = :userinfo.getUserId() AND RecordId = :contId].HasEditAccess;
        
    } 
    @AuraEnabled
    public static Map<String,String> getContactLabelMap(String objectName) {       
        return SchemaUtility.getObjectLabelMap(objectName);
    }
    @AuraEnabled
    public static ContactSaveResult saveContact(Contact contact) {
        ContactSaveResult saveResult = new ContactSaveResult();
        try {
            update contact; 
            saveResult.updatedContact = contact;
        }catch(System.DmlException e){
            system.debug('error Message'+e.getDmlMessage(0));
            saveResult.errorMessage = ''+e.getDmlMessage(0);
        }
        
        return saveResult;      
    }
    
    public class ContactSaveResult {
        @AuraEnabled
        public Contact updatedContact = new Contact();
        @AuraEnabled
        public String errorMessage = 'No Error';
    }
}