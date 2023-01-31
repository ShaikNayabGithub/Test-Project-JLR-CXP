public class BRS_RequestPostProcessor {
    private final String nextStatus;
    
    
    public BRS_RequestPostProcessor(String nextStatus)
    {
        this.nextStatus = nextStatus;
    }
    
    
    public void UpdateRequests(List<BRS_Request__c> requests)
    {
        for(BRS_Request__c request : requests) {
            if(request.Status__c != BRSRequestUtilities.FailureStatus){
                request.Status__c = this.nextStatus;
                request.Error_Message__c = '';
            }
            
            if(request.Error_Message__c != null
               && (request.Error_Message__c.contains('unable to obtain exclusive access to this record')
                   || request.Error_Message__c.contains('IO Exception: Read timed out'))){
                       request.Status__c = 'Unprocessed';
                   }
        }	
        system.debug('err1 requests --> '+json.serializePretty(requests));
        Database.update(requests, false);
    }
}