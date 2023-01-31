@isTest
public class BRS_RequestPostProcessor_Test {
    static testmethod void UpdateRequests_DoesNothing_GivenEmptyList()
    {
    	BRS_RequestPostProcessor requestPostProcessor = new BRS_RequestPostProcessor(BRSRequestUtilities.SuccessStatus);
    	
    	List<BRS_Request__c> requests = new List<BRS_Request__c>();
    	
    	requestPostProcessor.UpdateRequests(requests);
    	
    	Boolean isExceptionThrown = false;
    	System.Assert(!isExceptionThrown);
    }
    
    static testmethod void UpdateRequests_DoesNotChangeStatus_GivenRequestStatusFailed()
    {
    	BRS_RequestPostProcessor requestPostProcessor = new BRS_RequestPostProcessor(BRSRequestUtilities.SuccessStatus);
    	
    	List<BRS_Request__c> requests = new List<BRS_Request__c>();
    	BRS_Request__c request1 = new BRS_Request__c(Name='test1',Status__c=BRSRequestUtilities.FailureStatus);
    	requests.Add(request1);
    	
    	insert requests;
    	
    	requestPostProcessor.UpdateRequests(requests);
    	
    	request1 = [Select Status__c From BRS_Request__c Where Id =: request1.Id];
    	System.AssertEquals(BRSRequestUtilities.FailureStatus, request1.Status__c);
    }
    
    static testmethod void UpdateRequests_ChangesStatusToSuccess_GivenRequestStatusUnprocessed()
    {
    	BRS_RequestPostProcessor requestPostProcessor = new BRS_RequestPostProcessor(BRSRequestUtilities.SuccessStatus);
    	
    	List<BRS_Request__c> requests = new List<BRS_Request__c>();
    	BRS_Request__c request1 = new BRS_Request__c(Name='test1',Status__c=BRSRequestUtilities.UnprocessedStatus);
    	requests.Add(request1);
    	
    	insert requests;
    	
    	requestPostProcessor.UpdateRequests(requests);
    	
    	request1 = [Select Status__c From BRS_Request__c Where Id =: request1.Id];
    	System.AssertEquals(BRSRequestUtilities.SuccessStatus, request1.Status__c);
    }
}