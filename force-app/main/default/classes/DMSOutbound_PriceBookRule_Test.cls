@isTest
public class DMSOutbound_PriceBookRule_Test {
    static testmethod void Validate_DoesNotThrowException_GivenValidOpportunity()
    {
        DMSOutbound_PriceBookRule validator = new DMSOutbound_PriceBookRule();
        
        Opportunity opportunity = CreateValidOpportunity();
        
        TestClass_OpportunityValidationRuleTest.RunValidationTest(validator, opportunity, false);
    }

    static testmethod void Validate_ThrowsException_GivenNullPriceBookId()
    {
        DMSOutbound_PriceBookRule validator = new DMSOutbound_PriceBookRule();
        
        Opportunity opportunity = CreateValidOpportunity();
        opportunity.Pricebook2Id = null;
        
        TestClass_OpportunityValidationRuleTest.RunValidationTest(validator, opportunity, true);
    }

    static testmethod void Validate_ThrowsException_GivenPriceBookOfInvalidName()
    {
        DMSOutbound_PriceBookRule validator = new DMSOutbound_PriceBookRule();
        
        Opportunity opportunity = CreateValidOpportunity();
        Pricebook2 priceBook = new Pricebook2();
        priceBook.Name = 'Invalid';
        pricebook.isActive = true;
        insert priceBook;
        opportunity.Pricebook2Id = priceBook.Id;
        
        TestClass_OpportunityValidationRuleTest.RunValidationTest(validator, opportunity, true);
    }

    private static Opportunity CreateValidOpportunity()
    {
        Pricebook2 priceBook = new Pricebook2();
        priceBook.Name = 'India';
        pricebook.isActive = true;
        insert priceBook;

        Opportunity opportunity = new Opportunity();
        opportunity.Pricebook2Id = priceBook.Id;
        
        return opportunity;
    }
}