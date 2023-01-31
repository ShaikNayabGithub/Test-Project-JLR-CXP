public class LookupSearchComponentController {
    
    @AuraEnabled
    public static List<SObJectResult> getResults(String ObjectName, String fieldName, String value) {
        List<SObJectResult> sObjectResultList = new List<SObJectResult>();
        String soqlQuery;
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Retailer').getRecordTypeId();
        
        
        if(value != null){
            soqlQuery = 'Select Id,'+fieldName+' FROM '+ObjectName+' WHERE recordtypeid =: devRecordTypeId AND '+fieldName+' LIKE \'%' + value + '%\' order by createddate desc limit 5';
        }else{
            soqlQuery = 'Select Id,'+fieldName+' FROM '+ObjectName+' WHERE recordtypeid =: devRecordTypeId order by createddate desc limit 5';
        }
        
        for(sObject so : Database.Query(soqlQuery)) {
            String fieldvalue = (String)so.get(fieldName);
            sObjectResultList.add(new SObjectResult(fieldvalue, so.Id));
        }
        
        return sObjectResultList;
    }
    
    public class SObJectResult {
        @AuraEnabled
        public String recName;
        @AuraEnabled
        public Id recId;
        
        public SObJectResult(String recNameTemp, Id recIdTemp) {
            recName = recNameTemp;
            recId = recIdTemp;
        }
    }
}