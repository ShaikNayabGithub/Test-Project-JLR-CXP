public class DMSInboundRequestOpportunityExistsRule_F {
    public DMSInboundRequestOpportunityExistsRule Create(List<Id> requestedIds)
    {
    	Set<Id> validOpportunityIds = new Set<Id>();
    	for(Opportunity opportunity : [Select Id From Opportunity Where Id IN :requestedIds])
    	{
    		validOpportunityIds.add(opportunity.Id);
    	}
    	
    	return new DMSInboundRequestOpportunityExistsRule(validOpportunityIds);
    }
}