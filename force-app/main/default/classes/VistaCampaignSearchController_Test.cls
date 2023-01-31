@isTest
public with sharing class VistaCampaignSearchController_Test{

    static testMethod void Search_ValidSearchString_ReturnsCampaignByName(){
    	Campaign campaign = TestClass_CampaignBuilder.BuildCampaign();
    	insert campaign;
    	
    	VistaCampaignSearchController campaignSearch = new VistaCampaignSearchController();
    	campaignSearch.searchString = 'TestCampaign';
    	campaignSearch.Search();
    	System.assertEquals(campaign.Id, campaignSearch.SearchResults[0].Id);
    }
    
    static testMethod void Search_ValidWildcardSearchString_ReturnsCampaignByName(){
    	Campaign campaign = TestClass_CampaignBuilder.BuildCampaign();
    	insert campaign;
    	
    	VistaCampaignSearchController campaignSearch = new VistaCampaignSearchController();
    	campaignSearch.searchString = 'Test';
    	campaignSearch.Search();
    	System.assertEquals(campaign.Id, campaignSearch.SearchResults[0].Id);
    }
    
    static testMethod void Search_ValidSearchString_ReturnsMaxNumResults(){
    	List<Campaign> campaigns = new List<Campaign>();
    	for(Integer i=0; i<3; i++){
    		campaigns.add(TestClass_CampaignBuilder.BuildCampaign());
    	}
    	insert campaigns;
    	
    	VistaCampaignSearchController campaignSearch = new VistaCampaignSearchController();
    	campaignSearch.SetMaxResults(2);
    	campaignSearch.searchString = 'TestCampaign';
    	campaignSearch.Search();
    	System.assertEquals(2, campaignSearch.SearchResults.size());    	
    }
   
}