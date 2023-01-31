@isTest
public class DMSOutboundOpportunityValidator_India_Te {
    static testmethod void Validate_DoesNotThrowException_GivenValidOpportunity()
    {
    	DMSOutboundOpportunityValidator_India validator = new DMSOutboundOpportunityValidator_India();
    	
    	Opportunity opportunity = CreateValidOpportunity();
    	
    	TestClass_OpportunityValidationRuleTest.RunValidationTest(validator, opportunity, false);
    }
    
    static testmethod void Validate_ThrowsException_GivenEmptyLeadSource()
    {
    	DMSOutboundOpportunityValidator_India validator = new DMSOutboundOpportunityValidator_India();
    	
    	Opportunity opportunity = CreateValidOpportunity();
    	opportunity.LeadSource = '';
    	
    	TestClass_OpportunityValidationRuleTest.RunValidationTest(validator, opportunity, true);
    }
    
    static testmethod void Validate_ThrowsException_GivenNullLeadSource()
    {
    	DMSOutboundOpportunityValidator_India validator = new DMSOutboundOpportunityValidator_India();
    	
    	Opportunity opportunity = CreateValidOpportunity();
    	opportunity.LeadSource = null;
    	
    	TestClass_OpportunityValidationRuleTest.RunValidationTest(validator, opportunity, true);
    }
    
    static testmethod void Validate_ThrowsException_GivenNullBrand()
    {
    	DMSOutboundOpportunityValidator_India validator = new DMSOutboundOpportunityValidator_India();
    	
    	Opportunity opportunity = CreateValidOpportunity();
    	opportunity.Brand__c = null;
    	
    	TestClass_OpportunityValidationRuleTest.RunValidationTest(validator, opportunity, true);
    }
    
    static testmethod void Validate_ThrowsException_GivenNullModel()
    {
    	DMSOutboundOpportunityValidator_India validator = new DMSOutboundOpportunityValidator_India();
    	
    	Opportunity opportunity = CreateValidOpportunity();
    	opportunity.Primary_Model_Interest__c = null;
    	
    	TestClass_OpportunityValidationRuleTest.RunValidationTest(validator, opportunity, true);
    }
    
    static testmethod void Validate_ThrowsException_GivenNullDerivative()
    {
    	DMSOutboundOpportunityValidator_India validator = new DMSOutboundOpportunityValidator_India();
    	
    	Opportunity opportunity = CreateValidOpportunity();
    	opportunity.Derivative__c = null;
    	
    	TestClass_OpportunityValidationRuleTest.RunValidationTest(validator, opportunity, true);
    }
    
    private static Opportunity CreateValidOpportunity()
    {
    	Opportunity opportunity = new Opportunity();
    	
    	opportunity.LeadSource = 'test';
    	opportunity.Brand__c = Id.valueOf('0A28E000000Ccn0');
    	opportunity.Primary_Model_Interest__c = Id.valueOf('0A28E000000Ccn0');
    	opportunity.Derivative__c = Id.valueOf('0A28E000000Ccn0');
    	
    	return opportunity;
    }
}