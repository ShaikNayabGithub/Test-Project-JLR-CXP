public class Vista_RequestProcessor_Future {
    @future
    public static void ProcessRequests(Set<String> recordIds)
    {  
        Vista_BatchProcessor batchProcessor = Vista_BatchProcessor_F.Create();
        Vista_RequestToRequestCollection_Adapter requestToRequestCollectionAdapter = new Vista_RequestToRequestCollection_Adapter();

        List<Vista_Request__c> requests = [SELECT Id, Error_Log__c, Market_Description__c, Vehicle_Orders__c
                FROM Vista_Request__c WHERE Id IN: recordIds];

        Vista_RequestCollection requestCollection = requestToRequestCollectionAdapter.Adapt(requests);
        try
        {
            batchProcessor.ProcessRequestCollection(requestCollection);
        }
        catch(exception e)
        {
            for(Vista_Request__c request : requests) {
                request.Error_Log__c = request.Error_Log__c + '\nError processing at ' + DateTime.now() + ' ' + e.getMessage() +'\n' +e.getStackTraceString();
                request.Status__c = 'Error';
            }
        }
        update requests;
    }
}