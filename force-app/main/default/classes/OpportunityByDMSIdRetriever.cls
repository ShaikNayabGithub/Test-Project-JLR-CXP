public with sharing class OpportunityByDMSIdRetriever {
    public Opportunity Retrieve(string dmsId)
    {
    	List<Opportunity> opportunities = [Select Id From Opportunity Where DMS_Opportunity_ID__c =:dmsId Limit 1];
    	
    	if(opportunities.Size() > 0){ return opportunities[0]; }    	
    	return new Opportunity();
    }
}