public class customLookUpController {
    @AuraEnabled
    public static List <sObject> fetchLookUpValues(String searchKeyWord, String ObjectName,String fieldName,String region) {
        system.debug('ObjectName-->' + ObjectName);
        String searchKey = '%'+searchKeyWord + '%';
        List<sObject> returnList = new List<sObject>();
        String sQuery =  'select id, Name,'+fieldName+' from ' +ObjectName + ' where '+fieldName+' LIKE: searchKey and Region__c =:region order by createdDate DESC limit 5';
        List <sObject> lstOfRecords = Database.query(sQuery);
        for (sObject obj: lstOfRecords) {
            returnList.add(obj); 
        }
        return returnList;
    }
    
    @AuraEnabled
    public static List <sObject> fetchVehicleValues(String searchKeyWord, String ObjectName,String brandValue) {
        Id makeRecordTypeId = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByName().get('Make').getRecordTypeId();
        Id modelRecordTypeId = Schema.SObjectType.Vehicle_Specification__c.getRecordTypeInfosByName().get('Model').getRecordTypeId();
        
        system.debug('ObjectName-->' + ObjectName);
        String searchKey = '%'+searchKeyWord +'%';
        system.debug('searchKey --> '+searchKey);
        List<sObject> returnList = new List<sObject>();
        String sQuery;
        if(brandValue != null && brandValue != 'null'){
            sQuery =  'select id, Name from ' +ObjectName + ' where Make__c = \''+brandValue+'\' AND recordtypeId = \''+modelRecordTypeId+'\' AND Name LIKE: searchKey order by createdDate DESC limit 5';
        }else{
            sQuery =  'select id, Name from ' +ObjectName + ' where recordtypeId = \''+makeRecordTypeId+'\' AND Name LIKE: searchKey order by createdDate DESC limit 5';
        }
        system.debug('sQuery --> '+sQuery);
        List <sObject> lstOfRecords = Database.query(sQuery);
        for (sObject obj: lstOfRecords) {
            returnList.add(obj); 
        }
        return returnList;
    }
    
    @AuraEnabled
    public static List <sObject> fetchContactDataValues(String searchKeyWord, String ObjectName,String countryCode,String fieldType) {
        system.debug('ObjectName-->' + ObjectName);
        String sQuery;
        String searchKey = '%'+searchKeyWord + '%';
        List<sObject> returnList = new List<sObject>();
        countryCode = '(\''+countryCode+'\')';
        sQuery =  'select id, Name from ' +ObjectName + ' where Country_ISO_Code__c includes '+countryCode+' AND Contract_Field__c =: fieldType AND Name LIKE: searchKey order by Name limit 5';
        system.debug('sQuery --> '+sQuery);
        List <sObject> lstOfRecords = Database.query(sQuery);
        for (sObject obj: lstOfRecords) {
            returnList.add(obj); 
        }
        return returnList;
    }
}