@isTest
public class Scheduled_EventDetails_Batch_TEST {
    
    @Istest
    public static void execute_Batch_TEST(){
        
        String CRON_EXP = '0 0 11 1 1/1 ? *';
        DateTime todayDate = date.today();
        Integer monthNumber = todayDate.month();
        Integer hoursToAddDailightSaving = 1;
        
        String nextRunDate = String.ValueOf(DateTime.newInstance(todayDate.year(), todayDate.month(),1, 12-hoursToAddDailightSaving ,
                                                                 todayDate.minute(), todayDate.second()).addMonths(1));
       
        //check if the list on AsyncApexJobs has no records for jobs
        List<AsyncApexJob> listApexJobs = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors, JobType, MethodName
                                            FROM AsyncApexJob ];
        
        System.assertEquals(0,listApexJobs.size());
        
        Test.startTest();
        
        String jobId = System.schedule('Scheduled Batch : Delete Service Data', CRON_EXP, new Scheduled_EventDetails_Batch());   
        

        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        
   
        // Verify the expressions are the same
        System.assertEquals(CRON_EXP,ct.CronExpression);

        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);

        // Verify the next time the job will run
        System.assertEquals(nextRunDate,String.valueOf(ct.NextFireTime));
        
        Test.stopTest();
        
        //check if the list if there is 1 asyncjob
        List<AsyncApexJob> listScheduledApexJob = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors, JobType, MethodName
                                                FROM AsyncApexJob where JobType = 'ScheduledApex'];
        
        List<AsyncApexJob> listBatchApexJob = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors, JobType, MethodName
                                                FROM AsyncApexJob where JobType = 'BatchApex'];
       
        //verify that there is 1 scheduled job
        System.assertEquals(1,listScheduledApexJob.size());
        System.assertEquals('Queued',listScheduledApexJob[0].Status);
        
        //verify that there is 1 apex job
        System.assertEquals(1,listBatchApexJob.size());
        System.assertEquals('Queued',listBatchApexJob[0].Status);
    }

}