public without sharing class SearchFirst_HostController {
    public Set<SearchFirst_Controller_A> objectControllers { get; set; }
    public SearchFirst_HostController getThis() { return this; }
    
    public SearchFirstSearchParameters searchParameters { get; set; }
    public String ErrorTitle { get; set; }
    public String ErrorMessage { get; set; }
    
    public SearchFirst_HostController()
    {
        this.searchParameters = new SearchFirstSearchParameters();
        this.objectControllers = new Set<SearchFirst_Controller_A>();
        this.searchParameters.RecordTypeId = ApexPages.currentPage().getParameters().get('RecordType');
    }
    
    public void Search()
    {
        try{
            if(searchParameters.IsEmpty){ return; }
            for(SearchFirst_Controller_A objectController : objectControllers)
            {
                objectController.Reset();
                objectController.Search();
            }
        } catch (Exception e) {
            ErrorTitle = e.getMessage();
            ErrorMessage = e.getMessage();
        }
    }
    
    public void Reset()
    {
        for(SearchFirst_Controller_A objectController : objectControllers)
        {
            objectController.Reset();
        }
        this.searchParameters.Clear();
        
    }
}