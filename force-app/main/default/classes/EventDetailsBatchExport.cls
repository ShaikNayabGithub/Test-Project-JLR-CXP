global class EventDetailsBatchExport implements Schedulable, Database.Batchable<sObject>, Database.Stateful {
    global static String errors = '';
    
    global void execute(SchedulableContext SC) {
        Database.executeBatch(new EventDetailsBatchExport(), 200);
    } 
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        EventDetailsBatchData eventDetailsData = new EventDetailsBatchData();
        String queryResult = eventDetailsData.eventDetailsRetrieveData();
        return Database.getQueryLocator(queryResult);
    }
    
    global void execute(Database.BatchableContext BC, List<Event_Details__c> EventDetailsList) {
        
        EventDetailsBatchData eventDetailsData = new EventDetailsBatchData();
        //system.debug('--eventDetailsData size : ' + EventDetailsList.size());
        
        try{
            List<GfK_Roadside_Event_Export__c> eventRecords = eventDetailsData.getEventList(EventDetailsList);
            if(eventRecords != Null && eventRecords.size() > 0){
                insert eventRecords;
            }    
            
        } catch(Exception e){
            errors += e.getMessage() + ' -- ' + e.getStackTraceString() +'\n';
            //system.debug('-- My error : ' + e.getMessage());
        }  
    }
    
    global void finish(Database.BatchableContext bc) {
        // send an email if there are any errors
        if (!String.isEmpty(errors))
            EmailUtility.SendEmail(Label.TEST_FAILURE_NOTIFICATION_EMAILS.split(','),'EventDetailsBatchExport Daemon','EventDetailsBatchExport Errors','<pre>'+errors+'</pre>');
    }

}