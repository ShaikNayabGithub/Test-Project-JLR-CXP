@isTest
public class SearchFirst_HostController_Test {
    static testmethod void Search_DoesNotSetErrorMessage_GiveNoObjectControllers()
    {
        SearchFirst_HostController hostController = new SearchFirst_HostController();
        hostController.searchParameters.Email = 'test';
        
        hostController.Search();
        
        System.assert(String.isEmpty(hostController.ErrorMessage));
    }
    
    static testmethod void Search_DoesNotSetErrorTitle_GiveNoObjectControllers()
    {
        SearchFirst_HostController hostController = new SearchFirst_HostController();
        hostController.searchParameters.Email = 'test';
        
        hostController.Search();
        
        System.assert(String.isEmpty(hostController.ErrorTitle));
    }
    
    static testmethod void Search_SetsErrorMessage_GivenFaultyObjectController()
    {
        SearchFirst_HostController hostController = new SearchFirst_HostController();
        hostController.objectControllers.add(new FaultyObjectController());
        hostController.searchParameters.Email = 'test';
        
        hostController.Search();
        
        System.assert(String.isNotEmpty(hostController.ErrorMessage));
    }
    
    static testmethod void Search_SetsErrorTitle_GivenFaultyObjectController()
    {
        SearchFirst_HostController hostController = new SearchFirst_HostController();
        hostController.objectControllers.add(new FaultyObjectController());
        hostController.searchParameters.Email = 'test';
        
        hostController.Search();
        
        System.assert(String.isNotEmpty(hostController.ErrorTitle));
    }
    
    static testmethod void Search_DoesNotCallObjectController_GivenNoSearchParameters()
    {
        SearchFirst_HostController hostController = new SearchFirst_HostController();
        FaultyObjectController objectController = new FaultyObjectController();
        hostController.objectControllers.add(objectController);
        
        hostController.Search();
        
        System.assert(!objectController.searchIsCalled);
    }
    
    static testmethod void Reset_ClearsSearchParameters_GivenPopulatedSearchParameter()
    {
        SearchFirst_HostController hostController = new SearchFirst_HostController();
        hostController.searchParameters.Email = 'test';
        
        hostController.Reset();
        
        System.assert(hostController.searchParameters.IsEmpty);
    }
    
    static testmethod void Reset_CallsObjectControllerReset_GivenObjectController()
    {
        SearchFirst_HostController hostController = new SearchFirst_HostController();
        FaultyObjectController objectController = new FaultyObjectController();
        hostController.objectControllers.add(objectController);
        
        hostController.Reset();
        
        System.assert(objectController.resetIsCalled);
    }
    
    
    private class FaultyObjectController extends SearchFirst_Controller_A
    {
        public boolean searchIsCalled = false;
        public boolean resetIsCalled = false;
        
        public override void Search()
        {
            searchIsCalled = true;
            throw new TypeException('search error');
        }
        
        public override void Reset()
        {
            resetIsCalled = true;
        }
    
        public override PageReference CreateRecord()
        {
            return new PageReference('');
        }
    }
}