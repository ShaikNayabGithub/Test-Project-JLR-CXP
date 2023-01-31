global class BatchIMSRequestCleanup implements Database.Batchable<SObject>, Database.Stateful, Schedulable {

    Integer MAX_IMS_ROWS_TO_KEEP; 
    Static final List<String> NOTIFICATION_EMAILS = Label.IMS_BATCH_NOTIFICATION_EMAILS.split(','); 
    String errorMsg;
    String query;
    
    global void execute(SchedulableContext SC) {
        Database.executebatch(new BatchIMSRequestCleanup(), 50);
    } 

    global BatchIMSRequestCleanup() {
        MAX_IMS_ROWS_TO_KEEP = (Integer) Integer.ValueOf(Label.IMS_BATCH_ROWS_TO_KEEP_HISTORY);
        errorMsg = '';
        if (Test.isRunningTest()) MAX_IMS_ROWS_TO_KEEP = 1;
        query = 'select id from asset where apo__c = true order by createddate asc';
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext context, List<Asset> scope) {

        if (scope.isEmpty()) return;

        for (Asset a : scope) { 

            List<IMS_request__c> recordsForDeletion = [select id from ims_request__c where asset__c = : a.id and processed_status__c = 'Processed' order by createddate desc]; //un-f**ing believable that SOQL OFFSET clause is not supported in Batch Apex 

            if (recordsForDeletion.isEmpty()) continue;
            if ( recordsForDeletion.size()<=MAX_IMS_ROWS_TO_KEEP && !Test.isRunningTest()) continue;
            for (Integer i = 1; i <= MAX_IMS_ROWS_TO_KEEP; i++) {
                if (recordsForDeletion.size()>=i) recordsForDeletion.remove(0); //have to remove elements from the list due to OFFSET clause in SOQL prohibited in Batch Apex
            }

            try {
                if (!recordsForDeletion.isEmpty()) delete recordsForDeletion;
            } catch (Exception e) {
                errorMsg += e.getMessage() + ' -- ' + e.getStackTraceString() + '\n';
            } 

         }

    }

    global void finish(Database.BatchableContext context) {
        if (String.isNotEmpty(errorMsg) || Test.isRunningTest()) 
            EmailUtility.SendEmail(NOTIFICATION_EMAILS, 'BatchIMSRequestCleanup Daemon', 'BatchIMSRequestCleanup errors','<pre>'+errorMsg+'</pre>');
    }
}

/* (C) X-Cloud 2018-2021 */