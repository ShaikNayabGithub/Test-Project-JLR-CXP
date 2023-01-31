@isTest
public class NewLeadWalkInController_Test {
    
    @testSetup
    public static void createTestData(){
        Account testAccount = new Account();
        testAccount.LastName = 'Account Name';
        testAccount.FirstName = 'Testrec';
        testAccount.RecordTypeid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Individual').getRecordTypeId();
        testAccount.PersonEmail = 'testrec@test.test';
        insert testAccount;
    }
    
    @isTest
    public static void testMethod1(){
        test.startTest();
        NewLeadWalkInController.getEnquiryValues();
        NewLeadWalkInController.getBrandValues();
        NewLeadWalkInController.getBrandModelsMap();
        NewLeadWalkInController.getCampaignCreateAccess();
        NewLeadWalkInController.getOpportunity('tdetdvyde');
        Lead lead = createLead(true);
        NewLeadWalkInController.saveLead(lead, '');
        Account acc = [Select id, firstname, lastname, PersonMobilePhone, PersonEmail, recordtype.name from account limit 1];
        NewLeadWalkInController.accountWrapper accWrap = new NewLeadWalkInController.accountWrapper(acc.id, acc.firstname, acc.lastname, acc.PersonEmail, acc.PersonMobilePhone);
        Opportunity opp = [Select id, name, Brand__r.name, Primary_Model_Interest__r.name, account.firstname, account.lastname, owner.name, createddate from opportunity limit 1];
        NewLeadWalkInController.opportunityWrapper oppWrap = new NewLeadWalkInController.opportunityWrapper(opp.id, opp.name, opp.Brand__r.name, opp.Primary_Model_Interest__r.name, opp.account.firstname + ' ' + opp.account.lastname, opp.owner.name, string.valueOf(opp.createddate), 'Contacted');
        NewLeadWalkInController.getAccount('Testrec', 'Account Name', '', 'testrec@test.test');
        test.stopTest();
    }
    
    public static Lead createLead(boolean emailOptOut)  {
        Lead l = new Lead();
        l.LastName = 'TestLead';     
        l.Email = 'test@test.testing';
        l.Purchase_Type__c = 'New Vehicle';
        l.HasOptedOutOfEmail = emailOptOut;
        l.Company = 'Test Company';
        l.Industry = 'Banking';
        l.In_Market_Date__c = Date.newInstance(2018, 03, 31);
        l.Brand_Offline__c = 'Jaguar';
        l.Vehicle_Model_Offline__c = 'XJ';
        l.Budget__c = 100000;
        Vehicle_Specification__c make = TestClass_VehicleSpecificationBuilder.BuildMake();
        l.Brand__c = make.Id;     
        l.Primary_Model_Interest__c = TestClass_VehicleSpecificationBuilder.BuildModel(make).id;
        return l;
    }

}