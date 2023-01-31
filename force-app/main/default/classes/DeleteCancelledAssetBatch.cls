/*
* S.No.		Name		Date(DD/MM/YYYY)	Change 
* 1.0		Ashwin		31/05/2021			CXPD-1005: Delete all Assets When Vista Request with corresponding Order Number is returned with Status = Rejected
* 
*/
public class DeleteCancelledAssetBatch implements Database.Batchable<sObject>{
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        String vistaStatus = 'Order Cancelled';
        String query = 'SELECT Id FROM Asset WHERE Vista_Status__c = :vistaStatus';
        return Database.getQueryLocator(query);
    }
    
    // the execute method of the batch class which executes the delete  operations
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        Database.delete(scope, false);
    }
    
    public void finish(Database.BatchableContext BC){}
    
}