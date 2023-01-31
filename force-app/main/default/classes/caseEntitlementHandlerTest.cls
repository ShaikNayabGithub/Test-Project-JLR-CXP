@isTest
private class caseEntitlementHandlerTest {
    
   
    static testMethod void testHighPriorityCaseHasCorrentEntitlement()
    {
    	// create account required for contact required for case
    	Account testAccount = new Account(Name = 'Test Account');
    	insert testAccount;
    	
    	// create contact required for case
    	Contact testContact = new Contact(LastName = 'Steve', Email = 'stevetest@example.com', AccountId = testAccount.Id); 
    	insert testContact;    	
    	
    	Date startDate = date.today();
    	
    	// create entitlement required for case
    	Entitlement testEntitlement =  new Entitlement(Name = 'High Priority Entitlement', StartDate = startDate, AccountId = testAccount.Id);
    	insert testEntitlement;
    	
    	// create new case
    	Case testCase = new  Case(Status = 'Open', Origin = 'Chatter', Priority = 'High', Type = 'Request');
    	
    	// add case to a list so that able to pass it into the method on the handler
    	List<Case> testCaseList = new List<Case>();
    	testCaseList.add(testCase);
    	
    	// trigger fires here? should find the above entitlement and add it to the testCase
    	caseEntitlementHandler entitlementHandler = new caseEntitlementHandler();
    	entitlementHandler.SetEntitlementOnCase(testCaseList);
  	   	
    	// assert the case's entitlement is the same as the entitlement created in the test
        system.assertEquals(testEntitlement.Id, testCase.EntitlementId);  	
    }
    
    static testMethod void testMediumPriorityCaseHasCorrentEntitlement()
    {
    	// create account required for contact required for case
    	Account testAccount = new Account(Name = 'Test Account');
    	insert testAccount;
    	
    	// create contact required for case
    	Contact testContact = new Contact(LastName = 'Steve', Email = 'stevetest@example.com', AccountId = testAccount.Id); 
    	insert testContact;    	
    	
    	Date startDate = date.today();
    	
    	// create entitlement required for case
    	Entitlement testEntitlement =  new Entitlement(Name = 'Medium Priority Entitlement', StartDate = startDate, AccountId = testAccount.Id);
    	insert testEntitlement;
    	
    	// create new case
    	Case testCase = new  Case(Status = 'Open', Origin = 'Chatter', Priority = 'Medium', Type = 'Request');
    	
    	// add case to a list so that able to pass it into the method on the handler
    	List<Case> testCaseList = new List<Case>();
    	testCaseList.add(testCase);
    	
    	// trigger fires here? should find the above entitlement and add it to the testCase
    	caseEntitlementHandler entitlementHandler = new caseEntitlementHandler();
    	entitlementHandler.SetEntitlementOnCase(testCaseList);
  	   	
    	// assert the case's entitlement is the same as the entitlement created in the test
        system.assertEquals(testEntitlement.Id, testCase.EntitlementId);  	
    }
    
    static testMethod void testLowPriorityCaseHasCorrentEntitlement()
    {
    	// create account required for contact required for case
    	Account testAccount = new Account(Name = 'Test Account');
    	insert testAccount;
    	
    	// create contact required for case
    	Contact testContact = new Contact(LastName = 'Steve', Email = 'stevetest@example.com', AccountId = testAccount.Id); 
    	insert testContact;    	
    	
    	Date startDate = date.today();
    	
    	// create entitlement required for case
    	Entitlement testEntitlement =  new Entitlement(Name = 'Low Priority Entitlement', StartDate = startDate, AccountId = testAccount.Id);
    	insert testEntitlement;
    	
    	// create new case
    	Case testCase = new  Case(Status = 'Open', Origin = 'Chatter', Priority = 'Low', Type = 'Request');
    	
    	// add case to a list so that able to pass it into the method on the handler
    	List<Case> testCaseList = new List<Case>();
    	testCaseList.add(testCase);
    	
    	// trigger fires here? should find the above entitlement and add it to the testCase
    	caseEntitlementHandler entitlementHandler = new caseEntitlementHandler();
    	entitlementHandler.SetEntitlementOnCase(testCaseList);
  	   	
    	// assert the case's entitlement is the same as the entitlement created in the test
        system.assertEquals(testEntitlement.Id, testCase.EntitlementId);  	
    }
    
    
    

}