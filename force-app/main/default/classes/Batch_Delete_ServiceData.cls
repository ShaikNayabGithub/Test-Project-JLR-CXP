global class Batch_Delete_ServiceData implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        Date todayDateMinus30 = Date.today().addDays(-30);
       
        
        String query =  'Select ID from Service_Data__c '
         				+ ' where Error__c = true'
         				+ ' and LastModifiedBy.Name != \'Data Loader User\' '
         				+ ' and LastModifiedDate <: todayDateMinus30';
        
        return Database.getQueryLocator(query);
        
    }
    global void execute(Database.BatchableContext bc, List<Service_Data__c> listOfServiceData){
      
        Delete listOfServiceData;
    }    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }    
}