public class aopCheckfrontDuplicateErrorController {
    public string language;
    
    
    public aopCheckfrontDuplicateErrorController()
    {
        if(ApexPages.currentPage() != null &&ApexPages.currentPage().getParameters() != null && ApexPages.currentPage().getParameters().containsKey('language')){
            language = ApexPages.currentPage().getParameters().get('language');
        }
    }
    
    public string getLanguage()
    {
        if(language != null)
        {
            return language;
        }
        return 'en_US';        
    }
    
    public void setLanguage(string renderLanguage)
    {
        language = renderLanguage;
    }

}