public class LeadPreferencesUpdateController {
    @AuraEnabled
    public static Lead getLead(String leadId) {
        
        return [SELECT Id,HasOptedOutOfEmail,SMS_Opt_Out__c,et4ae5__HasOptedOutOfMobile__c,DoNotCall,Whitemail_Opt_Out__c 
        		FROM Lead WHERE Id =:leadId];      
    }
    @AuraEnabled
    public static Boolean getLeadAccess(String leadId) {
        return  [SELECT RecordId, HasEditAccess 
                 FROM UserRecordAccess 
                 WHERE UserId = :userinfo.getUserId() AND RecordId = :leadId].HasEditAccess;   
    } 
    @AuraEnabled
    public static Map<String,String> getLeadLabelMap(String objectName) {       
        return SchemaUtility.getObjectLabelMap(objectName);
    }
    @AuraEnabled
    public static LeadSaveResult saveLead(Lead leadtobeupdated) {
        system.debug('leadtobeupdated-do not call-'+leadtobeupdated.DoNotCall);
        LeadSaveResult saveResult = new LeadSaveResult();
        try {
            update leadtobeupdated; 
            saveResult.updatedLead = leadtobeupdated;
        }catch(System.DmlException e){
            system.debug('error Message'+e.getDmlMessage(0));
            saveResult.errorMessage = ''+e.getDmlMessage(0);
        }
        
        return saveResult;      
    }
    
    public class LeadSaveResult {
        @AuraEnabled
        public Lead updatedLead = new Lead();
        @AuraEnabled
        public String errorMessage = 'No Error';
    }
}