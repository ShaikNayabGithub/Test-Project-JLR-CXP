@istest
public class MembershipBatchCustomerOppSchedulerTest {
    public static testMethod void testschedule() {
		Test.StartTest();
		MembershipBatchCustomerOppScheduler testsche = new MembershipBatchCustomerOppScheduler();
		String sch = '0 0 9 * * ? *'; 
		system.schedule('Test status Check', sch, testsche );
		Test.stopTest();
	}

}