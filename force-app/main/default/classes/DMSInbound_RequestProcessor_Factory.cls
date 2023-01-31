public class DMSInbound_RequestProcessor_Factory {//messy, but called from webservice - so no constructor for now
    public DMSBatchOpportunityUpdater CreateBatchProcessor(DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity[] requests)
    {
    	DMSInboundRequestValidator_Factory requestValidatorFactory = new DMSInboundRequestValidator_Factory();
    	DMSMessager_Factory dmsMessager_Factory = new DMSMessager_Factory();
    	
    	DMSInboundRequestValidator dmsInboundRequestValidator = requestValidatorFactory.Create(DMSInboundIntegrationService.GetRequestIds(requests));
    	VehicleSpecificationByNameRetriever vehicleSpecificationByNameRetriever = new VehicleSpecificationByNameRetriever();
    	
    	I_DateAdapter dateAdapter = new Date_India();
    	I_TimeAdapter timeAdapter = new TimeAdapter_HHMMSS();
    	DateTimeAdapter dateTimeAdapter = new DateTimeAdapter(dateAdapter, timeAdapter);
    	
    	I_DMSAdapter_OpportunityStage opportunityStageAdapter = new DMSAdapter_OpportunityStage_India();
    	
    	OpportunityFromDMSInboundRequestBuilder opportunityFromDMSInboundRequestBuilder = new OpportunityFromDMSInboundRequestBuilder(vehicleSpecificationByNameRetriever, dateTimeAdapter, opportunityStageAdapter);
    	PostDatabaseInsertDMSResponseUpdater postDatabaseInsertDMSResponseUpdater = new PostDatabaseInsertDMSResponseUpdater();
    	
    	List<DMSInboundUpdateResponse> responses = new List<DMSInboundUpdateResponse>();
    	I_DMSMessager_Response dmsMessager = dmsMessager_Factory.CreateInboundResponseHandler_India();

        DMSInbound_TaskBuilder taskBuilder = new DMSInbound_TaskBuilder(dateAdapter);
    	
    	return new DMSBatchOpportunityUpdater(requests, responses, dmsInboundRequestValidator, opportunityFromDMSInboundRequestBuilder, postDatabaseInsertDMSResponseUpdater,
    		dmsMessager, taskBuilder);
    }
}