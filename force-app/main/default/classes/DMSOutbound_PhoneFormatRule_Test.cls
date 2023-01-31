@isTest
public class DMSOutbound_PhoneFormatRule_Test { //cant test contact as contact roles are read only
	static testmethod void Validate_DoesNotThrowException_GivenValidOpportunity()
    {
    	DMSOutbound_PhoneFormatRule validator = new DMSOutbound_PhoneFormatRule();
    	
    	Opportunity opportunity = CreateValidOpportunity();
    	
    	TestClass_OpportunityValidationRuleTest.RunValidationTest(validator, opportunity, false);
    }

    static testmethod void Validate_DoesNotThrowException_GivenNullAccountPhone()
    {
    	DMSOutbound_PhoneFormatRule validator = new DMSOutbound_PhoneFormatRule();
    	
    	Opportunity opportunity = CreateValidOpportunity();
    	opportunity.Account.Phone = null;
    	
    	TestClass_OpportunityValidationRuleTest.RunValidationTest(validator, opportunity, false);
    }

    static testmethod void Validate_DoesNotThrowException_GivenNullAccount()
    {
    	DMSOutbound_PhoneFormatRule validator = new DMSOutbound_PhoneFormatRule();
    	
    	Opportunity opportunity = CreateValidOpportunity();
    	opportunity.Account = null;
    	
    	TestClass_OpportunityValidationRuleTest.RunValidationTest(validator, opportunity, false);
    }

    static testmethod void Validate_ThrowsException_GivenAccountPhoneLength5()
    {
    	DMSOutbound_PhoneFormatRule validator = new DMSOutbound_PhoneFormatRule();
    	
    	Opportunity opportunity = CreateValidOpportunity();
    	opportunity.Account.Phone = '01234';
    	
    	TestClass_OpportunityValidationRuleTest.RunValidationTest(validator, opportunity, true);
    }

    private static Opportunity CreateValidOpportunity()
    {
    	Opportunity opportunity = new Opportunity();
    	opportunity.Account = new Account();
    	opportunity.Account.Phone = '0123456789';
    	
    	return opportunity;
    }
}