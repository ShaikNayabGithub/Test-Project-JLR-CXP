@istest
public class MemebrshipSalesConsultantSchedulerTest {
    public static testMethod void testschedule() {
		Test.StartTest();
		MemebrshipBatchSalesConsultantScheduler testsche = new MemebrshipBatchSalesConsultantScheduler();
		String sch = '0 0 9 * * ? *'; 
		system.schedule('Test status Check', sch, testsche );
		Test.stopTest();
	}

}