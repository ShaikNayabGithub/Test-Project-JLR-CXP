@isTest
public without sharing class TestClass_PdiRequestBuilder {
    
    public static PDI_Request__c buildPdiRequest(String assetId) {
        PDI_Request__c req = new PDI_Request__c();
        req.Vehicle__c = assetId;
        req.Requested_Completion_Date__c = System.today();

        return req;
    }

    public static PDI_Request__c buildAndInsertPdiRequest(String assetId) {
        PDI_Request__c req = buildPdiRequest(assetId);
        insert req;
        return req;
    }


}