public with sharing class VistaCampaignSearchController{

	public String searchString {get; set;}
	public List<Campaign> searchResults {get; private set;}
	private Integer maxResults = 100;
	
	public VistaCampaignSearchController(){
		if(ApexPages.currentPage().getParameters().containsKey('lksrch')){
			searchString = ApexPages.currentPage().getParameters().get('lksrch');
			Search();
		}
	}
	
	public void Search(){
		String searchToken = '%';
		if(String.IsNotBlank(searchString)){
			searchToken = '%' + searchString + '%';
		}
		searchResults = [SELECT Id, Name FROM Campaign WHERE Name LIKE :searchToken LIMIT :maxResults];
		if(searchResults.size() == 0){
			ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.INFO, System.Label.Stock_Search_No_Results));
		}
		else if(searchResults.size() == maxResults){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, System.Label.Stock_Search_More_Results_Available));
		}
	}
	
	public void SetMaxResults(Integer newValue){
		maxResults = newValue;
	}

}