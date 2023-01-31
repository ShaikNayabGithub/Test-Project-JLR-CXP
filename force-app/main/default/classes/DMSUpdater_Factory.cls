public class DMSUpdater_Factory {    
    public DMSUpdater Create()
    {
        DMSMessager_Factory dmsMessager_Factory = new DMSMessager_Factory();
        OpportunityValidator_Factory_DMSOutbound opportunityValidator_Factory = new OpportunityValidator_Factory_DMSOutbound();
        DMSOutboundProcessor_Factory outboundProcessorFactory = new DMSOutboundProcessor_Factory(dmsMessager_Factory, opportunityValidator_Factory);
        
        Set<DMSOutboundProcessor> outboundProcessors = new Set<DMSOutboundProcessor>();
        DMSOutboundProcessor indiaProcessor = outboundProcessorFactory.Create();
        outboundProcessors.add(indiaProcessor);
        return new DMSUpdater(outboundProcessors);
    }
}