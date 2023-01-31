@isTest
public class BatchCountOpenCasesPerObject_Test
{
    public static testmethod void testAccountScheduler() {
        Test.startTest();
        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        System.Schedule('TestSchedule', CRON_EXP, new BatchCountOpenCasesPerAccount() ); 
        Test.stopTest();
    }  
    
    public static testmethod void testContactScheduler() {
        Test.startTest();
        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        System.Schedule('TestSchedule', CRON_EXP, new BatchCountOpenCasesPerContact() ); 
        Test.stopTest();
    }  
    
    public static testMethod void testBatchOnContact() {
        
        Account a = TestClass_AccountCreator.GenerateCorporateAccount();
        Case c = TestClass_CaseCreator.Create('Phone');  
        Contact p = new Contact(Lastname='testBatchOnContact',Firstname='test',Email='test123@test.com', AccountId=a.Id);
        insert p;
        c.ContactId = p.id;
        update c;
        
        system.assertEquals(0,[select number_of_open_cases__c from contact where lastname='testBatchOnContact' limit 1].number_of_open_cases__c,'Unexpected number of open cases found before batch');
        
        Test.startTest();
        DataBase.executeBatch(new BatchCountOpenCasesPerObject('Contact'), 1); 
        Test.stopTest();
        
        system.assertEquals(1,[select number_of_open_cases__c from contact where lastname='testBatchOnContact' limit 1].number_of_open_cases__c,'Unexpected number of open cases found after batch');
        
    }
    
    public static testMethod void testBatchOnAccount() {
        
        Account a = TestClass_AccountCreator.CreatePersonAccount();
        Case c = TestClass_CaseCreator.Create('Phone');        
        c.AccountId = a.id;
        update c;
        
        system.assertEquals(0,[select number_of_open_cases__c from account limit 1].number_of_open_cases__c,'Unexpected number of open cases found before batch');
        
        Test.startTest();
        DataBase.executeBatch(new BatchCountOpenCasesPerObject('Account'), 1); 
        Test.stopTest();
        
        system.assertEquals(0,[select number_of_open_cases__c from account limit 1].number_of_open_cases__c,'Unexpected number of open cases found after batch');
        
    }
}