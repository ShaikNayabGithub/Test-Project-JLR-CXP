public class DMSOutbound_OpportunityStageValidator implements I_OpportunityValidator{
	private final List<String> excludedStages;

	public DMSOutbound_OpportunityStageValidator(List<String> excludedStages)
	{
		this.excludedStages = excludedStages;
	}

	public void Validate(Opportunity opportunity)
    {
    	
    	for(string stage : excludedStages)
    	{
    		if(opportunity.StageName == stage)
    		{
                string exceptionMessage = String.format(System.Label.DMSException_StageProgression, new List<String> {stage} );
    			throw new DMSOutbound_InvalidDataException(exceptionMessage);
    		}
    	}
    }
}