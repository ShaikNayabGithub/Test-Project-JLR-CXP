@isTest
public class DMSInbound_RequestProcessor_Factory_Test {
    static testMethod void CreateBatchProcessor_ReturnsDMSBatchOpportunityUpdater_GivenEmptyList() {
    	insert TestClass_ValidDMSConnectionBuilder.Build();
    	DMSInbound_RequestProcessor_Factory requestProcessorFactory = new DMSInbound_RequestProcessor_Factory();
    	
    	List<DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity> input = new List<DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity>();
    	
    	DMSBatchOpportunityUpdater result = requestProcessorFactory.CreateBatchProcessor(input);
    	
    	System.assertNotEquals(null, result);
    }
}