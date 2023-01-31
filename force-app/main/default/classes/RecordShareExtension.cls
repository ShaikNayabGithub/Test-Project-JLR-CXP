public class RecordShareExtension {
    
    public static integer CountSOQLLimit(String objectName, Record_Share__c shareSetting){
        String objectQuery = 'SELECT Count() from ' +objectName+'Share WHERE UserOrGroupId =\''+ shareSetting.User__c+'\'';
        Integer Rows =  database.countQuery(objectQuery);
        return Rows;
    }
    
    public static Record_Share__c createNewShareRecord(Record_Share__c shareSetting){
        
        Record_Share__c customRS = new Record_Share__c();
        
        customRS.Status__c = 'Pending';
        customRS.Account__c  = null;
        customRS.Account_Case__c = null;
        customRS.Account_Opportunity__c = null;
        customRS.Campaign__c = null;
        customRS.Lead__c = null;
        customRS.User__c = shareSetting.User__c;
        customRS.Retailer__c = shareSetting.Retailer__c;
        customRS.Delete__c = true;
        
        return customRS;
    }
}