@isTest
public class SearchFirst_ContactController_Test {
    static testmethod void Search_AddsTestContactToKnownLeads_GivenTestContactIsVisibleToUser()
    {
    	SearchFirst_ContactController controller = new SearchFirst_ContactController();
    	controller.pageController = new SearchFirst_HostController();
    	controller.pageController.searchParameters = new SearchFirstSearchParameters();
    	
    	Contact contact = TestClass_ValidContactBuilder.Build();
    	controller.pageController.searchParameters.LastName = contact.LastName;
    	
    	controller.Search();
    	
    	Map<Id, Contact> knownContacts = new Map<Id, Contact>(controller.knownContacts);
    	System.assert(knownContacts.ContainsKey(contact.Id));
    }
    
    static testmethod void Reset_ClearsUnknownContacts_GivenPopulatedUnknownContacts()
    {
    	SearchFirst_ContactController controller = new SearchFirst_ContactController();
    	
    	controller.unknownContacts.add(new Contact());
    	
    	controller.Reset();
    	
    	System.assertEquals(0, controller.unknownContacts.size());
    }
    
    static testmethod void Reset_ClearsKnownContacts_GivenPopulatedKnownContacts()
    {
    	SearchFirst_ContactController controller = new SearchFirst_ContactController();
    	
    	controller.knownContacts.add(new Contact());
    	
    	controller.Reset();
    	
    	System.assertEquals(0, controller.knownContacts.size());
    }
}