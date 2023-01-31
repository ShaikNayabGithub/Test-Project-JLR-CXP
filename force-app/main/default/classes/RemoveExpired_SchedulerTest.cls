@isTest
public class RemoveExpired_SchedulerTest {

    static testMethod void testExecute() {
        CreateTestData tdata = new CreateTestData();
        
        RecordSharer.DisableRecordSharing = true; //DJB added
        OpportunityHandler.IgnoreMMIT = true; //DJB added
        AssetHandler.IgnoreMMIT = true; //DJB added
		
        JUDAAN_Date__c expiredDay = tdata.createExpireDay( 3 , 7 , 7 );
        List<Saved_Vehicle_for_Account__c> svfa = tdata.createSavedVehicle();
        List<Opportunity> opps = tdata.createOpportunities( Date.today().addDays( - Integer.valueOf( expiredDay.Reservation__c ) ) , RemoveExpiredSavedQuotesBatch.DELETE_STAGE_NAME );
        List<Saved_Vehicle_for_Lead__c> svfl = tdata.createSavedVehicleForLead(1);        
        
        Test.startTest();
        RemoveExpired_Scheduler scheduler = new RemoveExpired_Scheduler();
        String sch = '0 0 0 3 9 ? 2022';
        String jobId = system.schedule('Expire Activity', sch, scheduler);
        CronTrigger ct = [Select id , CronExpression, NextFireTime, TimesTriggered from CronTrigger where id = :jobId];
        System.assertEquals(sch, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime));
        Test.stopTest();
        
        // Check schedulable is in the job list
        List<AsyncApexJob> jobsScheduled = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'ScheduledApex'];
        System.assertEquals(1, jobsScheduled.size());
        System.assertEquals('RemoveExpired_Scheduler', jobsScheduled[0].ApexClass.Name);
    
        // check apex batch is in the job list
        List<AsyncApexJob> jobsApexBatch = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob where JobType = 'BatchApex'];
        System.assertEquals(4, jobsApexBatch.size());
        
    }
}