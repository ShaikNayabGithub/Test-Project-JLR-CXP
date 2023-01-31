@isTest(SeeAlldata=true)
public class SharePersonAccount_SchedulerTest {

    static testMethod void testExecute() {
        CreateTestData tdata = new CreateTestData();
        Opportunity opps = tdata.createOpportunityForVisibility( );
        Test.startTest();
        SharePersonAccount_Scheduler scheduler = new SharePersonAccount_Scheduler();
        String sch = '0 0 0 3 9 ? 2022';
        String jobId = system.schedule('Share Activity', sch, scheduler);
        CronTrigger ct = [Select id , CronExpression, NextFireTime, TimesTriggered from CronTrigger where id = :jobId];
        System.assertEquals(sch, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime));
        Test.stopTest();
        
        
    }
}