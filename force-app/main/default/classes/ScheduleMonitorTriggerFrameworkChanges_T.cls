@isTest
public class ScheduleMonitorTriggerFrameworkChanges_T {

    public static testmethod void TestSchedule_Queuer() {
    
        TriggerFramework__c tf = new TriggerFramework__c(SetupOwnerId = UserInfo.getProfileId());
        insert tf;
    
        Test.startTest();
        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        System.Schedule('ScheduleMonitorTriggerFrameworkChanges_T', CRON_EXP, new ScheduleMonitorTriggerFrameworkChanges() );   
        Test.stopTest();
    } 

}