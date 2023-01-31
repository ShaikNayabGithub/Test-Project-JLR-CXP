public class ConnectedCarAlertCleanseBatch implements Database.Batchable<SObject>{
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        Integer ConnectedCarAlertCleanseMonths = Integer.valueOf(Label.ConnectedCarAlertCleanseMonths);
        Datetime dtTime=System.now();
        date dateTimeBefore = date.newinstance(dtTime.year(), dtTime.month(), dtTime.day()).addMonths(-ConnectedCarAlertCleanseMonths);
        String query = 'SELECT ID FROM Connected_Services_Alert__c WHERE createddate <=:dateTimeBefore';
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