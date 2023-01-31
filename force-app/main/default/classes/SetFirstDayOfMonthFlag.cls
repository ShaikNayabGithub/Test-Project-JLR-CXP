global class SetFirstDayOfMonthFlag implements Schedulable {
   global void execute(SchedulableContext SC) {
        List<Summarised_Pipeline_Performance_Metric__c> oldSnapshots = [Select Id, 
                                                                            Country_ISO_Code__c, 
                                                                            CreatedDate 
                                                                     from Summarised_Pipeline_Performance_Metric__c 
                                                                     where Year__c = null OR 
                                                                           Month__c = null OR 
                                                                           Day__c = null OR
                                                                           Reporting_Date__c = null];
       if ( oldSnapshots.size() != 0) {
           List<Summarised_Pipeline_Performance_Metric__c> updatedSnapshots = SummarizedPerformanceUtility.SetDateProperties(oldSnapshots);
           System.debug(Database.update(updatedSnapshots, false));
       } else {
           System.debug('Error: No snapshots to update. Please check that Reporting Snapshots are active within date.');
       }
        
   }
}