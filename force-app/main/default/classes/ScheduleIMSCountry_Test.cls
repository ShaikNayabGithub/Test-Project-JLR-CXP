@isTest 
public class ScheduleIMSCountry_Test  {

    public static testmethod void testScheduleSingapore() {
        Test.startTest();
        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        System.Schedule('TestSingaporeLoad', CRON_EXP, new ScheduleIMSLoadSingapore() );   
        Test.stopTest();
    } 

    public static testmethod void testScheduleJapan() {
        Test.startTest();
        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        System.Schedule('TestJapanLoad', CRON_EXP, new ScheduleIMSLoadJapan() );   
        Test.stopTest();
    }

    public static testmethod void testScheduleHongKong() {
        Test.startTest();
        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        System.Schedule('TestHongKongLoad', CRON_EXP, new ScheduleIMSLoadHongKong() );   
        Test.stopTest();
    }
    
    public static testmethod void testScheduleIMSLoadThailand() {
        Test.startTest();
        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        System.Schedule('TestThailandLoad', CRON_EXP, new ScheduleIMSLoadThailand() );   
        Test.stopTest();
    }

    public static testmethod void testScheduleIMSLoadKorea() {
        Test.startTest();
        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        System.Schedule('TestKoreaLoad', CRON_EXP, new ScheduleIMSLoadKorea() );   
        Test.stopTest();
    }
    
    

}