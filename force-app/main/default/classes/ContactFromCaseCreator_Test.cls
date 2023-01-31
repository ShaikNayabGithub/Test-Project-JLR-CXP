@isTest
public class ContactFromCaseCreator_Test {
    static testmethod void CreateFromCases_SetsContactId_GivenCaseWithEmail()
    {
        AccountFromCaseBuilder accountFromCaseBuilder = new AccountFromCaseBuilder();
        PersonContactRetriever personContactRetriever = new PersonContactRetriever();
        ContactFromCaseCreator contactFromCaseCreator = new ContactFromCaseCreator(accountFromCaseBuilder, personContactRetriever);
        
        List<Case> cases = new List<Case>();
        Case caseRecord = new Case();
        caseRecord.SuppliedEmail = 'test123@test.com';
        caseRecord.Case_Contact_Email__c = 'test123@test.com';
        cases.add(caseRecord);
        
        contactFromCaseCreator.CreateFromCases(cases);
        
        System.AssertNotEquals(null, caseRecord.ContactId);
    }
}