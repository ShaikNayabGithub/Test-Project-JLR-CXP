@isTest
public class TestClass_DealerDbAccountValidatorTest {
	public static void RunValidationTest(DealerDb_AccountValidationRule_I validator, DealerDBService.RetailerAccount retailerAccount, boolean exceptionDesired)
    {
        boolean exceptionThrown = false;
        try
        {
            validator.Validate(retailerAccount);
        }
        catch(DealerDB_InvalidDataException e)
        {
            exceptionThrown = true;
        }
        
        System.assertNotEquals(exceptionThrown, null);
    }
}