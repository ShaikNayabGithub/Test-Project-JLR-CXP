global class GfKSalesBatchExport implements Schedulable, Database.Batchable<sObject>, Database.Stateful {
    global static String errors = '';
    
    global void execute(SchedulableContext SC) {
        Database.executeBatch(new GfKSalesBatchExport(), 200);
    }  
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        GfkSalesBatchData gfkData = new GfkSalesBatchData();
        String queryResult = gfkData.gfKRetrieveOppData();
        return Database.getQueryLocator(queryResult);
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> GfKOpportunities) {
        GfkSalesBatchData gfkDataProcess = new GfkSalesBatchData();
        try{
            List<cVoice_Survey__c> oppRecords = gfkDataProcess.gfkExecute(GfKOpportunities);
            system.debug('oppRecords @@@'+oppRecords);
            if(oppRecords != Null && !oppRecords.isEmpty()){
                insert oppRecords;
            }    
            
        } catch(Exception e){
            errors += e.getMessage() + ' -- ' + e.getStackTraceString() +'\n';
        }  
    }
    
    global void finish(Database.BatchableContext bc) {
        // send an email if there are any errors
        if (!String.isEmpty(errors))
            EmailUtility.SendEmail(Label.TEST_FAILURE_NOTIFICATION_EMAILS.split(','),'GfkBatchExport Daemon','GfkSalesBatchExport Errors','<pre>'+errors+'</pre>');
    }     
}