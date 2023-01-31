public class RequestTriggerHandler {
    private RecordType avokaRecordType = [Select Id From RecordType Where SObjectType = 'Request__c' And DeveloperName = 'Avoka_Request' And IsActive = true Limit 1];
    
    public void PreCreate(List<Request__c> newRequests)
    {
        RequestObjectLookupSetter_Factory requestObjectLookupSetterFactory = new RequestObjectLookupSetter_Factory();
        RequestObjectLookupSetter requestObjectLookupSetter = requestObjectLookupSetterFactory.Create();
        
        RequestToLeadHandler_Factory requestToLeadHandlerFactory = new RequestToLeadHandler_Factory();
        RequestToLeadHandler requestToLeadHandler = requestToLeadHandlerFactory.Create();
        
        for(Request__c requestRecord : newRequests)
        {
            if(requestRecord.RecordTypeId == avokaRecordType.Id)
            {
                requestObjectLookupSetter.SetLookups(requestRecord);
                requestToLeadHandler.HandleRequest(requestRecord);
            }
        }
    }
}