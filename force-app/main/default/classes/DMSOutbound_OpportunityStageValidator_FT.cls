@isTest
public class DMSOutbound_OpportunityStageValidator_FT {
	static testmethod void Create_ReturnsStageValidator_WhenCalled()
	{
		DMSOutbound_OpportunityStageValidator_Fa validatorFactory = new DMSOutbound_OpportunityStageValidator_Fa();

		DMSOutbound_OpportunityStageValidator result = validatorFactory.Create();

		System.assertNotEquals(null, result);
	}
}