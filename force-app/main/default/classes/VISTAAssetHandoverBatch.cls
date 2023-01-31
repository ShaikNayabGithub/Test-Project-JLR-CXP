global class VISTAAssetHandoverBatch implements Database.Batchable<SObject>, Database.Stateful, Schedulable, Database.AllowsCallouts {
    String query;
    
    global void execute(SchedulableContext SC) {
        Database.executebatch(new VISTAAssetHandoverBatch(), 1);
    } 
    
    global VISTAAssetHandoverBatch() {
        query = 'SELECT Id,Asset__c,Handover_Date__c,VISTA_Response__c, Asset__r.Brand__r.Name,Asset__r.VIN__c,'+
            'Asset__r.Order_Number__c, Submitted_Status__c FROM RDA__c WHERE Submitted_Status__c=\'Submitted\'';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext context, List<RDA__c> scope) {
        if(!Test.isRunningTest()) VISTAAssetHandoverHandler.VISTARequestSender(scope[0].Id);
    }
    
    global void finish(Database.BatchableContext context) {
    }
}