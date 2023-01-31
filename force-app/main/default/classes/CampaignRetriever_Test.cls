@isTest
private class CampaignRetriever_Test {
	@isTest
    static void RetrieveByCode_ReturnsEmptyCampaign_GivenNonExistantCampaignId() {
		CampaignRetriever campaignRetriever = new CampaignRetriever();
        
        string nonExistantCampaignId = 'test id';
        Campaign result = campaignRetriever.RetrieveByCode(nonExistantCampaignId);
        
        System.assertEquals(null, result.Id);
    }
    
    @isTest
    static void RetrieveByCode_ReturnsNonEmptyCampaign_GivenExistingCampaignId() {
		CampaignRetriever campaignRetriever = new CampaignRetriever();
        
        Campaign existingCampaign = new Campaign();
        existingCampaign.Name = 'Test 1';
        existingCampaign.Campaign_ID__c = 'test id';
        existingCampaign.ExpectedResponse = 10;
        existingCampaign.Market_ID__c = 'IN';
        insert existingCampaign;
        
        Campaign result = campaignRetriever.RetrieveByCode(existingCampaign.Campaign_ID__c);
        
        System.assertNotEquals(null, result.Id);
    }
}