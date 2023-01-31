@isTest
public class DMSOutbound_OpportunityStageValidator_Te {
	static testmethod void Validate_DoesNotThrowException_WhenValidatorHasNoExcludedStages()
    {
    	DMSOutbound_OpportunityStageValidator validator = new DMSOutbound_OpportunityStageValidator(new List<String>());
    	Opportunity opportunity = new Opportunity();

    	TestClass_OpportunityValidationRuleTest.RunValidationTest(validator, opportunity, false);
    }

    static testmethod void Validate_ThrowsException_WhenValidatorContainsOpportunityStage()
    {
    	string stage ='test';
    	List<String> excludedStages = new List<String>();
    	excludedStages.add(stage);

    	DMSOutbound_OpportunityStageValidator validator = new DMSOutbound_OpportunityStageValidator(excludedStages);
    	Opportunity opportunity = new Opportunity();
    	opportunity.StageName = stage;

    	TestClass_OpportunityValidationRuleTest.RunValidationTest(validator, opportunity, true);
    }
}