public class BRS_EnhancedUpserter {
    public void UpsertRecords(List<SObject> recordsToUpsert, List<BRS_Request__c> requests)//accepts lists and not a map as maps do not inherit from SObject colletion
    {
        Database.UpsertResult[] results = Database.Upsert(recordsToUpsert, false);
        
        for(Integer i = 0; i < results.Size(); i++){
            if(!results[i].isSuccess()) {
                String message = this.BuildMessage(results[i].getErrors());
                requests[i].Status__c = BRSRequestUtilities.FailureStatus;
                requests[i].Error_Message__c += (message + '; ');
            }
        }
    }

    public void UpsertRecords(List<SObject> recordsToUpsert, Map<Integer, List<BRS_Request__c>> requestsByIndex)//accepts lists and not a map as maps do not inherit from SObject colletion
    {
        Database.UpsertResult[] results = Database.Upsert(recordsToUpsert, false);
        
        for(Integer i = 0; i < results.Size(); i++){
            if(!results[i].isSuccess()) {
                List<BRS_Request__c> requests = requestsByIndex.get(i);
                String message = this.BuildMessage(results[i].getErrors());
                
                for(BRS_Request__c request : requests) {
                    request.Status__c = BRSRequestUtilities.FailureStatus;
                    request.Error_Message__c += (message + '; ');
                }
            }
        }
    }
    
    private String BuildMessage(Database.Error[] errors)
    {
        String message = '';
        for(Database.Error error : errors){
            String erroneousFields = StringExtensions.ConcatonateList(error.getFields(), ', ', System.Label.AndLabel + ' ').replace('\'','`').replace('"','`');
            String sStatusCode = String.ValueOf(error.getStatusCode()).replace('\'','`').replace('"','`');
            String sEmessage = error.getMessage().replace('\'','`').replace('"','`');
            message += String.Format(System.Label.DatabaseErrorException, new List<String>{ sStatusCode, erroneousFields, sEmessage, '; ' });
        }
        return message;
    }
}