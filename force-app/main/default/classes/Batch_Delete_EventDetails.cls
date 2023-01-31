global class Batch_Delete_EventDetails implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        Date todayDateMinus30 = Date.today().addDays(-30);
        
        String query =  'Select ID from Event_Details__c '
                        + ' where Error__c = true'
                        + ' and LastModifiedBy.Name != \'Data Loader User\' '
                        + ' and LastModifiedDate <: todayDateMinus30';
        
        return Database.getQueryLocator(query);
        
    }
    global void execute(Database.BatchableContext bc, List<Event_Details__c> listOfRoadsideEvents){
      
        Delete listOfRoadsideEvents;
    }    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }    
}