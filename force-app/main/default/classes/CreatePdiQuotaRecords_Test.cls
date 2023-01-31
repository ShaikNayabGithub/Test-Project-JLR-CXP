@isTest
public class CreatePdiQuotaRecords_Test {
    
    @isTest
    static void UnitTest(){
        Id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Retailer').getRecordTypeId();
		Account acc = new Account(name='Test Account',Record_Sub_Type__c = 'Legal Entity (Dealer Group)',Country_ISO_Code__c = 'KR',RecordTypeId =recTypeId);
        Account acc1 = new Account(name='Test Account2',Record_Sub_Type__c = 'Legal Entity (Dealer Group)',Country_ISO_Code__c = 'KR',RecordTypeId =recTypeId);
        insert acc;
        insert acc1;
        createPdiQuotaRecords.createRecords();
        system.assertEquals(2,[select count() from PDI_Quota__c]);
        
        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        System.schedule('TestSchedule', CRON_EXP, new CreatePdiQuotaRecords());
    
    }
    @isTest
    static void UnitTest2(){
        Id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Retailer').getRecordTypeId();
        Account acc = new Account(name='Test Account3',Record_Sub_Type__c = 'Legal Entity (Dealer Group)',Country_ISO_Code__c = 'KR',RecordTypeId =recTypeId);
        insert acc;
        createPdiQuotaRecords.createRecords(system.today());
        system.assertEquals(1,[select count() from PDI_Quota__c]);
    }
    
}