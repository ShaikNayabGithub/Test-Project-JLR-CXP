@isTest(seeAllData=true)
public class OpportunityLookupExpander_Test {
    static testMethod void Expand_ReturnsOpportunity_GivenExistantOpportunity() {
        OpportunityLookupExpander opportunityLookupExpander = new OpportunityLookupExpander();
        
        Opportunity input = TestClass_ValidOpportunityBuilder.Build();
        insert input;
        
        Opportunity result = opportunityLookupExpander.Expand(input);
        
        System.assertNotEquals(null, result);
    }
    
    /*static testMethod void Expand_ReturnsOpportunityAccountName_GivenOpportunityWithAccount() {
        OpportunityLookupExpander opportunityLookupExpander = new OpportunityLookupExpander();
        
        Opportunity opportunity = TestClass_ValidOpportunityBuilder.Build();
        insert opportunity;
        
        Opportunity result = opportunityLookupExpander.Expand(opportunity);
        
        System.assertNotEquals(null, result.Account.Name);
    }*/
}