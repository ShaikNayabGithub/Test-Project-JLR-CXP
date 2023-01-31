public with sharing class CsvBulkUploadController {

    @AuraEnabled
    public static string importCsv(String jsonRecordData, String jsonConfigObject){
        System.debug('jsonRecordData');
        System.debug(jsonRecordData);
        System.debug('jsonConfigObject');
        System.debug(jsonConfigObject);
        
        ConfigObject loadConfig = (ConfigObject) JSON.deserialize(jsonConfigObject, ConfigObject.class);
        System.debug('loadConfig');
        System.debug(loadConfig);


        System.Type typeString = Type.forName('List<' + loadConfig.objectApiName + '>');
        System.debug('typeString');
        System.debug(typeString);

        List<SObject> objectsList = (List<SOBject>) JSON.deserialize(jsonRecordData, Type.forName('List<' + loadConfig.objectApiName + '>'));
        System.debug('objectsList');
        System.debug(objectsList);

        Database.DMLOptions dmlOptions = new Database.DMLOptions();
        dmlOptions.optAllOrNone = true;
        List<Database.SaveResult> saveResult;
        List<Database.UpsertResult> upsertResult;

       

        

        if(loadConfig.operation.trim().toLowerCase() == 'insert') {
            saveResult = Database.insert(objectsList, dmlOptions, AccessLevel.USER_MODE);

        } else if(loadConfig.operation.trim().toLowerCase() == 'upsert' || (loadConfig.operation.trim().toLowerCase() == 'update' && loadConfig.updateKey != 'Id')) {
            Schema.SObjectField upsertField = Schema.getGlobalDescribe().get(loadConfig.objectApiName).getDescribe().fields.getMap().get(loadConfig.updateKey);
            upsertResult = Database.upsert(objectsList, upsertField, true, AccessLevel.USER_MODE);
        } else if(loadConfig.operation.trim().toLowerCase() == 'update') {
            //Schema.SObjectField upsertField = Schema.getGlobalDescribe().get(loadConfig.objectApiName).getDescribe().fields.getMap().get(loadConfig.updateKey);
            saveResult = Database.update(objectsList, dmlOptions, AccessLevel.USER_MODE);
                
        } 
           
        if(saveResult != null) {
            return JSON.serialize(saveResult);
        } else {
            return JSON.serialize(upsertResult);
        }
        

    }

    private class ConfigObject {
        String objectApiName;
        String operation;
        String updateKey;
    }
}