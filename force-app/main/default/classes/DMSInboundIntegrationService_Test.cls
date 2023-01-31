@isTest
public class DMSInboundIntegrationService_Test {
	static testmethod void UpdateMultipleOpportunities_ReturnsInitialResponse_GivenEmptyList()
	{
		List<DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity> requests = new List<DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity>();

		DMSInboundIntegrationService.InitialResponse response = DMSInboundIntegrationService.UpdateMultipleOpportunities(requests);

		System.assertNotEquals(null, response);
	}
}