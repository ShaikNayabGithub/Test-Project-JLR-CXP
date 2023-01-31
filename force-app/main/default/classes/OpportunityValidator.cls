public class OpportunityValidator implements I_OpportunityValidator{
	private final List<I_OpportunityValidator> validationRules;
	public OpportunityValidator(List<I_OpportunityValidator> validationRules) {
		this.validationRules = validationRules;
	}

	public void Validate(Opportunity opportunity)
    {
    	for(I_OpportunityValidator validationRule : validationRules)
    	{
    		validationRule.Validate(opportunity);
    	}
    }
}