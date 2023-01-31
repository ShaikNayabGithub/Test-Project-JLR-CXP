global class ScheduleMonitorTriggerFrameworkChanges implements Schedulable {

    private final integer hoursBack = 1;

    private class TriggerFramework {

        boolean isBatch;
        boolean isFuture;
        boolean isQueueable;
        string profile_name;
        datetime modified_on;
        string modified_by;
        string name; 
        string id;

    }

     
    global void execute(SchedulableContext sc) {

        String startDate = String.valueOf(System.now().addHours( (-1 * hoursBack) ).format('yyyy-MM-dd HH:mm:ss') + '.000z').replace(' ','T'); 
        
        List<TriggerFramework__c> lstTFs = Database.query('select id, name, setupowner.name, lastmodifiedby.name, lastmodifieddate from triggerframework__c where systemmodstamp >= ' + startDate);

        if (!lstTFs.isEmpty()) {

            List<TriggerFramework> tfs = new List<TriggerFramework>();
            TriggerFramework tfr;

            for (TriggerFramework__c tf : lstTFs) {
                tfr = new TriggerFramework();
                tfr.isBatch = System.isBatch();
                tfr.isFuture = System.isFuture();
                tfr.isQueueable = System.isQueueable();
                tfr.profile_name = tf.SetupOwner.Name;
                tfr.modified_by = tf.LastModifiedBy.name;
                tfr.modified_on = tf.LastModifiedDate;
                tfr.name = tf.Name;
                tfr.id = tf.Id;
                tfs.add(tfr);
            }

            String EmailContent='<h3>Running user: '+UserInfo.getUsername()+'</h3>';
            EmailContent+='<h3>The following changes were made to the TriggerFramework custom setting in the last '+hoursBack+' hours:</h3>';
            EmailContent+='<hr/>';              
            EmailContent+='<PRE>'+JSON.serializePretty(tfs)+'</PRE>'; 
            EmailContent+='<hr/>';
            EmailUtility.SendEmail(Label.IMS_BATCH_NOTIFICATION_EMAILS.split(','), 'ScheduleMonitorTriggerFrameworkChanges Sender', 'ScheduleMonitorTriggerFrameworkChanges Status - ' + system.now(),EmailContent); 

        }   
    }

}