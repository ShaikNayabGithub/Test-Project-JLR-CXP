public class VistaRequest_TriggerHandler {
    private static final String ID_FIELD_NAME = Schema.Vista_Request__c.Id.getDescribe().getName();


    public void PostInsert(List<Vista_Request__c> requests) 
    {
        Set<String> recordIds = SObjectUtilities.GetFieldValues(requests, ID_FIELD_NAME);
        Vista_RequestProcessor_Future.ProcessRequests(recordIds);
    }
}