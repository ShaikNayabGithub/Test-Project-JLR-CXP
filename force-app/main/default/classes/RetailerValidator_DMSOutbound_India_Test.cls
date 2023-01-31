@isTest
public class RetailerValidator_DMSOutbound_India_Test {
    static testMethod void Validate_ThrowsException_GivenEmptyAccount() {
    	RetailerValidator_DMSOutbound_India validator = new RetailerValidator_DMSOutbound_India();
    	
        Opportunity opportunity = new Opportunity();
    	opportunity.Account = new Account();
        opportunity.Account.Preferred_Sales_Retailer__r = new Account();
    	
    	TestClass_OpportunityValidationRuleTest.RunValidationTest(validator, opportunity, true);
    }
    
    static testMethod void Validate_DoesNotThrowException_GivenAccountDealerCICode() {
    	RetailerValidator_DMSOutbound_India validator = new RetailerValidator_DMSOutbound_India();
    	
    	Opportunity opportunity = new Opportunity();
        opportunity.Account = new Account();
        opportunity.Account.Preferred_Sales_Retailer__r = new Account();
    	opportunity.Account.Preferred_Sales_Retailer__r.Dealer_CI_Code__c = 'code';
    	
    	TestClass_OpportunityValidationRuleTest.RunValidationTest(validator, opportunity, false);
    }
}