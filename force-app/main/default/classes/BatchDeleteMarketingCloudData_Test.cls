@isTest
public class BatchDeleteMarketingCloudData_Test {

    public static testmethod void testScheduler() {
        Test.startTest();
        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        System.Schedule('TestSchedule', CRON_EXP, new BatchDeleteMarketingCloudData() );   
        Test.stopTest();
    }  
    
    public static testMethod void testBatch() {
        
        et4ae5__SendDefinition__c sd = new et4ae5__SendDefinition__c();
        insert sd;
        
        et4ae5__IndividualEmailResult__c ier = new et4ae5__IndividualEmailResult__c(et4ae5__SendDefinition__c=sd.id);
        insert ier;
        
        system.assertEquals(1,[select id from et4ae5__IndividualEmailResult__c].size(),'Unexpected number of rows found');
        
        Test.startTest();
        DataBase.executeBatch(new BatchDeleteMarketingCloudData(), 1); 
        Test.stopTest();
        
        system.assertEquals(0,[select id from et4ae5__IndividualEmailResult__c].size(),'Data was not deleted');
        
    }

}