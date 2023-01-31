@isTest(seeAllData=true)
public class OpportunityByDMSIdRetriever_Test {
    static testMethod void Retrieve_ReturnsEmptyOpportunity_GivenNonExistantDMSIdString() {
    	OpportunityByDMSIdRetriever opportunityByDMSIdRetriever = new OpportunityByDMSIdRetriever();
    	Opportunity result = opportunityByDMSIdRetriever.Retrieve('non-existant id');
    	
    	System.assertEquals(null, result.Id);
    }
    
    static testMethod void Retrieve_ReturnsExistantOpportunity_GivenExistantDMSIdString() {
    	string dmsId = 'dmsId';
    	Opportunity opportunity = TestClass_ValidOpportunityBuilder.Build();
    	opportunity.DMS_Opportunity_ID__c = dmsId;
    	insert opportunity;
    	
    	OpportunityByDMSIdRetriever opportunityByDMSIdRetriever = new OpportunityByDMSIdRetriever();
    	Opportunity result = opportunityByDMSIdRetriever.Retrieve(dmsId);
    	
    	System.assertNotEquals(null, result.Id);
    }
}