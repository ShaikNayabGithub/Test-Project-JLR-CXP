@isTest
public class SearchFirst_LeadController_Test {
    static testmethod void Search_AddsTestLeadToKnownLeads_GivenTestLeadIsVisibleToUser()
    {
    	SearchFirst_LeadController leadController = new SearchFirst_LeadController();
    	leadController.pageController = new SearchFirst_HostController();
    	leadController.pageController.searchParameters = new SearchFirstSearchParameters();
    	
    	Lead lead = TestClass_LeadCreator.CreateLead();
    	leadController.pageController.searchParameters.LastName = lead.LastName;
    	
    	leadController.Search();
    	
    	Map<Id, Lead> knownLeads = new Map<Id, Lead>(leadController.knownLeads);
    	System.assert(knownLeads.ContainsKey(lead.Id));
    }
    
    static testmethod void Reset_ClearsUnknownLeads_GivenPopulatedUnknownLeads()
    {
    	SearchFirst_LeadController leadController = new SearchFirst_LeadController();
    	
    	leadController.unknownLeads.add(new Lead());
    	
    	leadController.Reset();
    	
    	System.assertEquals(0, leadController.unknownLeads.size());
    }
    
    static testmethod void Reset_ClearsKnownLeads_GivenPopulatedKnownLeads()
    {
    	SearchFirst_LeadController leadController = new SearchFirst_LeadController();
    	
    	leadController.knownLeads.add(new Lead());
    	
    	leadController.Reset();
    	
    	System.assertEquals(0, leadController.knownLeads.size());
    }
}