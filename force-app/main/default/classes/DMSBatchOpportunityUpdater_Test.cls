@isTest
public class DMSBatchOpportunityUpdater_Test {//could do with much improvement, however would require further abstraction of private/injected classes
    static testMethod void Start_ReturnsRequests_GivenBatchableContext() {
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity[] requests = new DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity[]{};
        Dummy_Messager dmsMessager = new Dummy_Messager();
        DMSBatchOpportunityUpdater batchUpdater = BuildBatchUpdater(requests, dmsMessager);

        Iterable<DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity> results = batchUpdater.start(new Dummy_BatchableContext());

        System.assertEquals(requests, results);
    }

    static testMethod void Finish_CallsMessager_GivenBatchableContext() {
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity[] requests = new DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity[]{};
        Dummy_Messager dmsMessager = new Dummy_Messager();
        DMSBatchOpportunityUpdater batchUpdater = BuildBatchUpdater(requests, dmsMessager);

        batchUpdater.finish(new Dummy_BatchableContext());

        System.assertEquals(1, dmsMessager.callCount);
    }

    static testMethod void Execute_DoesNotFail_GivenBatchableContextAndEmptyList() {
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity[] requests = new DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity[]{};
        Dummy_Messager dmsMessager = new Dummy_Messager();
        DMSBatchOpportunityUpdater batchUpdater = BuildBatchUpdater(requests, dmsMessager);

        batchUpdater.execute(new Dummy_BatchableContext(), requests);

        System.assert(true);
    }

    static testmethod void TestMethodBuildBatchUpdater_ReturnsUpdater_WhenCalled()//doesnt add to coverage
    {
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity[] requests = new DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity[]{};
        Dummy_Messager dmsMessager = new Dummy_Messager();
        DMSBatchOpportunityUpdater result = BuildBatchUpdater(requests, dmsMessager);
        System.assertNotEquals(null, result);
    }
    
    static testmethod void Execute_CreatesSetOfOpportunitiesAtOrder_WhenOpportunitiesAtOrderExist() {
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity[] requests = new DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity[]{};
        
        Opportunity orderOpp = TestClass_ValidOpportunityBuilder.Build();
        orderOpp.StageName = 'Order';
        insert orderOpp;
        
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = new DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity();
        request.SFOpportunityID = orderOpp.Id;
        requests.add(request);
        
        Dummy_Messager dmsMessager = new Dummy_Messager();
        DMSBatchOpportunityUpdater batchUpdater = BuildBatchUpdater(requests, dmsMessager);

        batchUpdater.execute(new Dummy_BatchableContext(), requests);
        
        System.assertEquals(1, batchUpdater.orderOppIds.size());
    }


    private static DMSBatchOpportunityUpdater BuildBatchUpdater(DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity[] requests, I_DMSMessager_Response dmsMessager)
    {
        List<DMSInboundUpdateResponse> responses = new List<DMSInboundUpdateResponse>();
        List<I_DMSInboundRequestValidationRule> validationRules = new List<I_DMSInboundRequestValidationRule>();
        DMSInboundRequestValidator dmsInboundRequestValidator = new DMSInboundRequestValidator(validationRules);
        VehicleSpecificationByNameRetriever vehicleSpecificationByNameRetriever = new VehicleSpecificationByNameRetriever();
        I_DateAdapter dateAdapter = new DummyDateAdapter();
        I_TimeAdapter timeAdapter = new DummyTimeAdapter();
        DateTimeAdapter dateTimeAdapter = new DateTimeAdapter(dateAdapter, timeAdapter);
        I_DMSAdapter_OpportunityStage opportunityStageAdapter = new Dummy_StageAdapter();
        OpportunityFromDMSInboundRequestBuilder opportunityFromDMSInboundRequestBuilder = new OpportunityFromDMSInboundRequestBuilder(vehicleSpecificationByNameRetriever, 
            dateTimeAdapter, opportunityStageAdapter);
        PostDatabaseInsertDMSResponseUpdater postDatabaseInsertDMSResponseUpdater = new PostDatabaseInsertDMSResponseUpdater();
        DMSInbound_TaskBuilder taskBuilder = new DMSInbound_TaskBuilder(dateAdapter);

        return new DMSBatchOpportunityUpdater(requests, responses, dmsInboundRequestValidator, opportunityFromDMSInboundRequestBuilder,
                postDatabaseInsertDMSResponseUpdater, dmsMessager, taskBuilder);
    }

    private class Dummy_BatchableContext implements Database.BatchableContext{
        public Id getChildJobId()
        {
            return Id.valueOf('0068E000002jAG0');//temp
        }

        public Id getJobId()
        {
            return Id.valueOf('0068E000002jAG0');
        }
    }

    private class Dummy_Messager implements I_DMSMessager_Response{
        public integer callCount = 0;
        public void SendResponses(DMSInboundUpdateResponseCollection responseCollection)
        {
            this.callCount++;
        }
    }

    private class Dummy_StageAdapter implements I_DMSAdapter_OpportunityStage
    {
        public string GetSalesforceValue(string dmsValue)
        {
            return dmsValue;
        }
    }

    private class DummyDateAdapter implements I_DateAdapter{
        public Date parse(string timeString)
        {
            return Date.newInstance(0, 0, 0);
        }
    }

    private class DummyTimeAdapter implements I_TimeAdapter{
        public Time parse(string timeString)
        {
            return Time.newInstance(0, 0, 0, 0);
        }
    }
}