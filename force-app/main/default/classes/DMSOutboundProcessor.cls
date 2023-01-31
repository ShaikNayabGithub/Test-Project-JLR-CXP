public class DMSOutboundProcessor{
    private final I_OpportunityValidator opportunityValidator;
    private final I_DMSMessager_Update dmsMessager;
    private final DMSOutbound_ResponseProcessor responseProcessor;
    private final OpportunityLookupExpander opportunityLookupExpander;
    
    public DMSOutboundProcessor(I_OpportunityValidator opportunityValidator, 
    	I_DMSMessager_Update dmsMessager, DMSOutbound_ResponseProcessor responseProcessor,
    	OpportunityLookupExpander opportunityLookupExpander)
    {
    	this.opportunityValidator = opportunityValidator;
    	this.dmsMessager = dmsMessager;
    	this.responseProcessor = responseProcessor;
    	this.opportunityLookupExpander = opportunityLookupExpander;
    }
    
    public void SendOpportunity(Opportunity opportunity)
    {
        opportunity = opportunityLookupExpander.Expand(opportunity);
        opportunityValidator.Validate(opportunity);
        
        DMSOutboundResponse response = dmsMessager.SendOpportunity(opportunity);
        responseProcessor.ProcessResponse(response);
    }
}