public class CampaignEstimatedRevenueSetter_Factory {
    public CampaignEstimatedRevenueSetter Create()
    {
    	CountryMapper countryMapper = new CountryMapper();
    	PricebookEntryRetriever pricebookEntryRetriever = new PricebookEntryRetriever();
    	
    	return new CampaignEstimatedRevenueSetter(countryMapper, pricebookEntryRetriever);
    }
}