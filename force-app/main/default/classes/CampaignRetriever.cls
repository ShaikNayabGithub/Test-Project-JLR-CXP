public class CampaignRetriever {
    public Campaign RetrieveByCode(string campaignCode)
    {
    	List<Campaign> campaigns = [Select Id From Campaign where Campaign_ID__c = :campaignCode Limit 1];
    	
    	if(campaigns.Size() > 0){ return campaigns[0]; }
    	return new Campaign();
    }
}