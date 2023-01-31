@isTest
public class ScheduleIMSLoadMenaMarket_Test {
    public static testmethod void testScheduleLiveCountry() {
        Test.startTest();
        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        System.Schedule('TestAllCOuntryLoad', CRON_EXP, new ScheduleIMSLoadMenaMarket() );   
        Test.stopTest();
    } 
}