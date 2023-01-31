public class DealerDb_AccountValidator implements DealerDb_AccountValidationRule_I{
    private final List<DealerDb_AccountValidationRule_I> validationRules;

    public DealerDb_AccountValidator(List<DealerDb_AccountValidationRule_I> validationRules)
    {
        this.validationRules = validationRules;
    }


    public void Validate(DealerDBService.RetailerAccount retailerAccount)
    {
        for(DealerDb_AccountValidationRule_I validationRule : this.validationRules)
        {
            validationRule.Validate(retailerAccount);
        }
    }
}