@isTest(seeAllData=false)
public class AccountFromCaseBuilderTest {

    static testmethod void testBuildPersonAccount1()
    {
        Case caseRecord= New Case();
        caseRecord.Next_Follow_up_Date__c = System.today();
    	caseRecord.Priority='Low';
    	caseRecord.Status = 'Open';
    	caseRecord.Origin = 'Email';
    	caseRecord.Case_Contact_Email__c = 'test123@test.com';
        caseRecord.Case_Contact_Phone__c='9876543210';
    	caseRecord.SuppliedEmail = 'test123@test.com';   
        caseRecord.Subject = 'Subject 1';
        caseRecord.Country_ISO_Code__c='IN';
        //Set RecordType to Retailer
        caseRecord.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Label.Retailer).getRecordTypeId();
        Test.startTest();
        AccountFromCaseBuilder controller= new AccountFromCaseBuilder();
        controller.BuildPersonAccount(caseRecord);
        Test.stopTest();
    }
    static testmethod void testBuildPersonAccount2()
    {
        Case caseRecord= New Case();
        caseRecord.Next_Follow_up_Date__c = System.today();
    	caseRecord.Priority='Low';
    	caseRecord.Status = 'Open';
    	caseRecord.Origin = 'Email';
    	caseRecord.Case_Contact_Email__c = 'test123@test.com';
        caseRecord.Case_Contact_Phone__c='9876543210';
    	caseRecord.SuppliedEmail = 'test123@test.com';   
        caseRecord.Subject = 'Subject 1';
        //Set RecordType to Retailer
        caseRecord.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Label.Retailer).getRecordTypeId();
        Test.startTest();
        AccountFromCaseBuilder controller= new AccountFromCaseBuilder();
        controller.BuildPersonAccount(caseRecord);
        Test.stopTest();
    }
}