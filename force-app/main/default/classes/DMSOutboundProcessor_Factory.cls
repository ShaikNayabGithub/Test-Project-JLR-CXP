public class DMSOutboundProcessor_Factory {
    private final DMSMessager_Factory dmsMessager_Factory;
    private final OpportunityValidator_Factory_DMSOutbound opportunityValidator_Factory;
    
    public DMSOutboundProcessor_Factory(DMSMessager_Factory dmsMessager_Factory, OpportunityValidator_Factory_DMSOutbound opportunityValidator_Factory)
    {
        this.dmsMessager_Factory = dmsMessager_Factory;
        this.opportunityValidator_Factory = opportunityValidator_Factory;
    }
    
    
    public DMSOutboundProcessor Create()
    {
        return BuildProcessor_India();
    }
    
    private DMSOutboundProcessor BuildProcessor_India()
    {
        DMS_PrefixHandler prefixHandler = new DMS_PrefixHandler('IND-SIE-');//consider adding to custom setting
        I_OpportunityValidator opportunityValidator = this.opportunityValidator_Factory.CreateIndia();
        I_DMSMessager_Update dmsMessager = this.dmsMessager_Factory.CreateOutboundUpdater_India(prefixHandler);
        DMSOutbound_ResponseProcessor responseProcessor = new DMSOutbound_ResponseProcessor(prefixHandler);
        OpportunityLookupExpander opportunityLookupExpander = new OpportunityLookupExpander();
        
        return new DMSOutboundProcessor(opportunityValidator, dmsMessager, responseProcessor, opportunityLookupExpander);
    }
}