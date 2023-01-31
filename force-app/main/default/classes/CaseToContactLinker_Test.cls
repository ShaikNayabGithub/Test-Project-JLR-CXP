@isTest
public class CaseToContactLinker_Test {
    static testmethod void LinkCasesToContacts_DoesNotSetContactId_GivenCaseOriginPhone()
    {
    	CaseToContactLinker_Factory caseToContactLinkerFactory = new CaseToContactLinker_Factory();
    	CaseToContactLinker caseToContactLinker = caseToContactLinkerFactory.Create();
    	
    	List<Case> cases = new List<Case>();
    	Case caseRecord = new Case();
    	caseRecord.Origin = 'Phone';
    	cases.add(caseRecord); 
    	
    	caseToContactLinker.LinkCasesToContactsByTrigger(cases,false,true);
    	 
    	System.AssertEquals(null, caseRecord.ContactId);
    }
    
    static testmethod void LinkCasesToContacts_SetsContactId_GivenCaseOriginEmail()
    {
    	CaseToContactLinker_Factory caseToContactLinkerFactory = new CaseToContactLinker_Factory();
    	CaseToContactLinker caseToContactLinker = caseToContactLinkerFactory.Create();
    	
    	List<Case> cases = new List<Case>();
    	Case caseRecord = new Case();
    	caseRecord.Origin = 'Email';
    	caseRecord.SuppliedEmail = 'test123@test.com';
    	cases.add(caseRecord);
    	
    	caseToContactLinker.LinkCasesToContactsByTrigger(cases,true,true);
    	
    	System.AssertNotEquals(null, caseRecord.ContactId);
    }
}