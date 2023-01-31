@isTest
public class GfkBatchExport_Test {  
    
    @testSetup static void setup() {
        CaseTriggerHandler.IgnoreCaseLinker = true;   
        Account acc = new Account();        
        acc.RecordTypeId = AccountUtilities.RecordTypes.get('Individual').Id;      
        String chars = 'abcdefghijklmnopqrstuvwxyz123';
        acc.LastName = '';
        for(Integer i=0; i<10; i++){
            Integer randomNum = (Integer)(Math.random() * 26);
            acc.LastName += chars.substring(randomNum, randomNum+1);
        }
        acc.FirstName = 'Valid Firstname';
        acc.PersonMailingStreet = 'Valid Street';
        acc.PersonMailingPostalCode = 'Valid PostalCode';
        acc.PersonMailingState = 'Valid State';
        acc.PersonMailingCity = 'Valid City';        
        acc.PersonEmail = 'test123@test.com';
        acc.Owner_Retailer__c = '1234567';
        acc.Is_Primary__c = false;
        insert acc;  
        Case caseRecord = new Case();
        caseRecord.Next_Follow_up_Date__c = System.today();
        caseRecord.Priority='Low';
        caseRecord.Status = 'Open';
        caseRecord.Origin = 'Email';        
        caseRecord.Subject = 'Subject 1';
        caseRecord.Country_ISO_Code__c = 'AU';        
        caseRecord.Solved_Date__c = Date.today().addDays(-3);
        caseRecord.AccountId=acc.Id;
        caseRecord.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('CRC').getRecordTypeId();
        insert caseRecord;
    }
    
    public static testmethod void testScheduler() {
        Test.startTest();
        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        System.schedule('TestSchedule', CRON_EXP, new GfkBatchExport() );
        Test.stopTest();
    }  
    
    public static testMethod void testBatch() {
        Test.startTest();      
        Account acc = [Select id from account limit 1];
        Asset ass = TestClass_AssetBuilder.BuildVehicle(true);
        ass.AccountId = acc.Id;
        insert ass; 
        Case ca = [select AssetId from Case limit 1];
        ca.AssetId=ass.Id;
        update ca; 
        Database.executeBatch(new GfkBatchExport(), 200);
        Test.stopTest();
    }
    
    public static testMethod void testBatchMENA() {
        Test.startTest();
        Account acc = [Select id from account limit 1];
        Asset ass = TestClass_AssetBuilder.BuildVehicle(true);
        ass.AccountId = acc.Id;
        insert ass; 
        Case ca = [select AssetId from Case limit 1];
        ca.AssetId=ass.Id;       
        update ca; 
        Database.executeBatch(new GfkBatchExport(), 200);
        Test.stopTest();
    }
    
    /*public static testMethod void testBatchContact() {
        Test.startTest();
        Account acc = [Select id from account limit 1];
        Asset ass = TestClass_AssetBuilder.BuildVehicle(true);
        ass.AccountId = acc.Id;
        insert ass; 
        Case ca = [select AssetId from Case limit 1];
        ca.AssetId=ass.Id;
        update ca;

        Contact caseContact = new Contact(FirstName = 'Test',
                                          LastName = 'Test',
                                          accountId=acc.Id,
                                          Email = 'test@test.com',
                                          MailingStreet = 'Valid Street',
                                          MailingPostalCode = 'Valid PostalCode',
                                          MailingState = 'Valid State',
                                          MailingCity = 'Valid City');
        insert caseContact;
        Test.stopTest();
        
        Case updateCase = [Select Id from Case limit 1];
        updateCase.AccountId = null;
        updateCase.ContactId = caseContact.Id;
        update updateCase;
        Database.executeBatch(new GfkBatchExport(), 200);
        
       // System.assert([select Id from GfK_Export__c].size()>0,'Expecting rows in GfkExport object but none found.');
    }*/
}