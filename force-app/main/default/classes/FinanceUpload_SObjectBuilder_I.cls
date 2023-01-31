public interface FinanceUpload_SObjectBuilder_I {
    SObject Build(Integer csvRowIndex, FinanceUpload_RecordCollection recordCollection,Map<String,Id>mapIdAccountToIdUser,Map<String,account> mapPhoneToIdAccount,Map<String,Service_Data__c> mapStringToService);
}