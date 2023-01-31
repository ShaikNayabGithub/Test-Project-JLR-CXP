public class CampaignEstimatedRevenueSetter {
	private final CountryMapper countryMapper;
	private final PricebookEntryRetriever pricebookEntryRetriever;
	
	
	public CampaignEstimatedRevenueSetter(CountryMapper countryMapper, PricebookEntryRetriever pricebookEntryRetriever)
	{
		this.countryMapper = countryMapper;
		this.pricebookEntryRetriever = pricebookEntryRetriever;
	}
	
	    
    public void SetEstimatedRevenue(List<Campaign> campaigns)
    {
        Map<String, List<SObject>> campaignsByCountryMap = this.countryMapper.MapRecordsByOwnerCountry(campaigns);        
        List<PricebookEntry> priceBookEntries = pricebookEntryRetriever.Retrieve(campaignsByCountryMap, Campaign.Product__c.getDescribe());
        
        for(String country : campaignsByCountryMap.keySet()){
        	for(SObject campaign : campaignsByCountryMap.get(country)){
        		this.SetEstimatedRevenue((Campaign)campaign, country, priceBookEntries);
        	}
        }
    }
    
    private void SetEstimatedRevenue(Campaign campaign, String country, List<PricebookEntry> priceBookEntries)
    {
    	for(PricebookEntry pricebookEntry : pricebookEntries){
    		if(pricebookEntry.Product2Id == campaign.Product__c && pricebookEntry.Pricebook2.Name == country){
    			Decimal numVehicleSales = 0;
    			if(campaign.Estimated_Number_of_Vehicle_Sales__c != null) numVehicleSales = campaign.Estimated_Number_of_Vehicle_Sales__c;
    			campaign.ExpectedRevenue = pricebookEntry.UnitPrice * numVehicleSales;
    			return;
    		}
    	}
    }
}