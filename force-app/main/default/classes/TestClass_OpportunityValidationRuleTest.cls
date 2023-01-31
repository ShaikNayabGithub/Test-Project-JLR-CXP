@isTest
public class TestClass_OpportunityValidationRuleTest {
	public static void RunValidationTest(I_OpportunityValidator validator, Opportunity opportunity, boolean exceptionDesired)
    {
        boolean exceptionThrown = false;
        try
        {
            validator.Validate(opportunity);
        }
        catch(DMSOutbound_InvalidDataException e)
        {
            exceptionThrown = true;
        }
        
        System.assertNotEquals(exceptionThrown, null);
    }
}