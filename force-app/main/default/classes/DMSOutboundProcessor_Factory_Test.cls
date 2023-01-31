@isTest
public class DMSOutboundProcessor_Factory_Test {
    static testMethod void CreateOutboundUpdaterIndia_ReturnsIDMSMessagerUpdate_WhenCalled() {
        insert TestClass_ValidDMSConnectionBuilder.Build();
        DMSMessager_Factory messagerFactory = new DMSMessager_Factory();
        OpportunityValidator_Factory_DMSOutbound opportunityValidatorFactory = new OpportunityValidator_Factory_DMSOutbound();
        DMSOutboundProcessor_Factory factory = new DMSOutboundProcessor_Factory(messagerFactory, opportunityValidatorFactory);
                
        DMSOutboundProcessor result = factory.Create();
        
        System.assertNotEquals(null, result);
    }
}