public interface Service_I {
    void createServiceDataItems(FinanceUpload_SObjectCreator serviceItemsCreator,FinanceUpload_RecordCollection recordCollection,Map<String,Id> mapIdAccountToIdUser,Map<String,account> mapPhoneToIdAccount,
    Map<string,service_data__c> serviceDataByRepairOrder,Set<String> repairOrders,Map<Id,service_data__c> mapIdToService);
}