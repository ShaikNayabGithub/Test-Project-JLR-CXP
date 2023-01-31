@isTest
public class SearchFirst_AccountController_Test {
    static testmethod void Search_AddsTestAccountToKnownAccounts_GivenTestAccountIsVisibleToUser()
    {
    	SearchFirst_AccountController controller = new SearchFirst_AccountController();
    	controller.pageController = new SearchFirst_HostController();
    	controller.pageController.searchParameters = new SearchFirstSearchParameters();
    	
    	Account account = TestClass_AccountCreator.CreateRetailer();
    	controller.pageController.searchParameters.CompanyName = account.Name;
    	
    	controller.Search();
    	
    	Map<Id, Account> knownAccounts = new Map<Id, Account>(controller.knownAccounts);
    	System.assert(knownAccounts.ContainsKey(Account.Id));
    }
    
    static testmethod void Reset_ClearsUnknownAccounts_GivenPopulatedUnknownAccounts()
    {
    	SearchFirst_AccountController controller = new SearchFirst_AccountController();
    	
    	controller.unknownAccounts.add(new Account());
    	
    	controller.Reset();
    	
    	System.assertEquals(0, controller.unknownAccounts.size());
    }
    
    static testmethod void Reset_ClearsKnownAccounts_GivenPopulatedKnownAccounts()
    {
    	SearchFirst_AccountController controller = new SearchFirst_AccountController();
    	
    	controller.knownAccounts.add(new Account());
    	
    	controller.Reset();
    	
    	System.assertEquals(0, controller.knownAccounts.size());
    }
}