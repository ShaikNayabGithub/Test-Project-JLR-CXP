public class DMSUpdater {
	private final Set<DMSOutboundProcessor> dmsOutboundProcessors;
	
	public DMSUpdater(Set<DMSOutboundProcessor> dmsOutboundProcessors)
	{
		this.dmsOutboundProcessors = dmsOutboundProcessors;
	}
	
    public void UpdateDMSSystems(Opportunity opportunity)
    {
    	for(DMSOutboundProcessor dmsOutboundProcessor : dmsOutboundProcessors)
    	{
    		dmsOutboundProcessor.SendOpportunity(opportunity);
    	}
    }
}