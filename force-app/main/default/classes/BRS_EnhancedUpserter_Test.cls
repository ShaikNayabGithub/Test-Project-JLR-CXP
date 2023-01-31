@isTest
public class BRS_EnhancedUpserter_Test {
    static testmethod void UpsertRecords_DoesNotThrowException_GivenEmptyLists()
    {
        BRS_EnhancedUpserter enhancedUpserter = new BRS_EnhancedUpserter();
        
        List<SObject> recordsToUpsert = new List<Product2>();
        List<BRS_Request__c> requests = new List<BRS_Request__c>();
        
        enhancedUpserter.UpsertRecords(recordsToUpsert, requests);
        
        System.Assert(true);
    }

    static testmethod void UpsertRecords_ThrowsException_GivenNonEmptyMaps()
    {
        BRS_EnhancedUpserter enhancedUpserter = new BRS_EnhancedUpserter();
        
        List<SObject> recordsToUpsert = new List<Product2>();
        recordsToUpsert.Add(new Product2());
        Map<Integer, List<BRS_Request__c>> requestsByIndex = new Map<Integer, List<BRS_Request__c>>();
        requestsByIndex.put(0,new List<BRS_Request__c>{new BRS_Request__c()});
        
        enhancedUpserter.UpsertRecords(recordsToUpsert, requestsByIndex);
        
        System.Assert(true);
    }
    
    static testmethod void UpsertRecords_SetsRequestStatusToFailed_GivenInvalidProduct()
    {
        BRS_EnhancedUpserter enhancedUpserter = new BRS_EnhancedUpserter();
        
        List<SObject> recordsToUpsert = new List<Product2>();
        recordsToUpsert.Add(new Product2());
        List<BRS_Request__c> requests = new List<BRS_Request__c>();
        requests.Add(new BRS_Request__c());
        
        enhancedUpserter.UpsertRecords(recordsToUpsert, requests);
        
        System.AssertEquals(BRSRequestUtilities.FailureStatus, requests[0].Status__c);
    }
    
    static testmethod void UpsertRecords_DoesNotSetRequestStatus_GivenValidSObject()
    {
        BRS_EnhancedUpserter enhancedUpserter = new BRS_EnhancedUpserter();
        
        List<SObject> recordsToUpsert = new List<BRS_Request__c>();
        recordsToUpsert.Add(new BRS_Request__c(Name='1'));
        List<BRS_Request__c> requests = new List<BRS_Request__c>();
        requests.Add(new BRS_Request__c());
        
        enhancedUpserter.UpsertRecords(recordsToUpsert, requests);
        
        System.Assert(String.IsEmpty(requests[0].Status__c));
    }
}