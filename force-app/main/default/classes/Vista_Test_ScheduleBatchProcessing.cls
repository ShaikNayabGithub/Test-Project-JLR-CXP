@isTest
public class Vista_Test_ScheduleBatchProcessing {
	public static string CRON_EXP = '0 0 0 15 3 ? 2022';
    static testMethod void TestScheduleEmailsSchedulesBatchJob() {
        Test.startTest();
        String jobId = System.Schedule('ScheduledClassTest', CRON_EXP, new Vista_ScheduleBatchProcessing());
        
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
        					FROM CronTrigger WHERE Id =: jobId];
        					
        System.assertEquals(CRON_EXP, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        
        Test.stopTest();
    }

}