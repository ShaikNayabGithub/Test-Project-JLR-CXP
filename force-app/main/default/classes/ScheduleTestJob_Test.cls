@isTest
public class ScheduleTestJob_Test {

    public static testmethod void TestSchedule_Queuer() {
        Test.startTest();
        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        System.Schedule('TestSchedule_Queuer', CRON_EXP, new ScheduleTestJobQueuer() );   
        Test.stopTest();
    } 
    
    public static testmethod void TestSchedule_NotifyFailures() {
        Test.startTest();
        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        System.Schedule('TestSchedule_NotifyFailures', CRON_EXP, new ScheduleTestJobNotifyFailures () );   
        Test.stopTest();
    }

    public static testmethod void TestDoExecute_Queuer() {
        Test.startTest();
        ScheduleTestJobQueuer.doExecute();
        Test.stopTest();
    } 
    
    public static testmethod void TestDoExecute_NotifyFailures() {
        Test.startTest();
        ScheduleTestJobNotifyFailures.doExecute();
        Test.stopTest();
    } 
    
}