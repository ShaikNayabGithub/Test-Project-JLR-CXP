public class ConnectedCarConsentCleanseBatch implements Database.Batchable<SObject>{
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        Integer ConnectedCarConsentCleanseMonths = Integer.valueOf(Label.ConnectedCarConsentCleanseMonths);
        Datetime dtTime=System.now();
        date dateTimeBefore= date.newinstance(dtTime.year(), dtTime.month(), dtTime.day()).addMonths(-ConnectedCarConsentCleanseMonths);
        String query = 'SELECT ID FROM Connected_Services_Consent__c WHERE createddate <= :dateTimeBefore';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        Database.DeleteResult[] drList = Database.delete(scope, false);
        for(Database.DeleteResult dr : drList) {
            if (dr.isSuccess()) {
                System.debug('Successfully deleted ID: ' + dr.getId());
            }
            else {
                for(Database.Error err : dr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug(' fields that affected this error: ' + err.getFields());
                }
            }
        }
    }
    
    public void finish(Database.BatchableContext BC){
    }
}