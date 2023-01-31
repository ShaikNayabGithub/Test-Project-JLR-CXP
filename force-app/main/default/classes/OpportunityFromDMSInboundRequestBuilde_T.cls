@isTest(seeAllData=true)
public class OpportunityFromDMSInboundRequestBuilde_T {//tests needed for vehicle specs
    static testMethod void BuildOpportunity_ReturnsOpportunity_GivenEmptyRequest() {
        Opportunity opportunity = TestClass_ValidOpportunityBuilder.Build();
        insert opportunity;
        OpportunityFromDMSInboundRequestBuilder opportunityBuilder = BuildOpportunityBuilder();
        
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = new DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity();
        request.SFOpportunityID = opportunity.Id;
        Opportunity result = opportunityBuilder.BuildOpportunity(request, null);
        
        System.assertNotEquals(null, result);
    }
    
    static testMethod void BuildOpportunity_SetsOpportunityId_GivenRequestSFID() {
        Opportunity opportunity = TestClass_ValidOpportunityBuilder.Build();
        insert opportunity;
        OpportunityFromDMSInboundRequestBuilder opportunityBuilder = BuildOpportunityBuilder();
        
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = new DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity();
        request.SFOpportunityID = opportunity.Id;
        
        Opportunity result = opportunityBuilder.BuildOpportunity(request, null);
        
        System.assertEquals(opportunity.Id, result.Id);
    }
    
    static testMethod void BuildOpportunity_SetsOpportunityDMSID_GivenRequestDMSID() {
        Opportunity opportunity = TestClass_ValidOpportunityBuilder.Build();
        insert opportunity;
        OpportunityFromDMSInboundRequestBuilder opportunityBuilder = BuildOpportunityBuilder();
        
        string dmsId = 'dmsId';
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = new DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity();
        request.DMSOpportunityID = dmsId;
        request.SFOpportunityID = opportunity.Id;
        
        Opportunity result = opportunityBuilder.BuildOpportunity(request, null);
        
        System.assertEquals(dmsId, result.DMS_Opportunity_ID__c);
    }
    
    static testMethod void BuildOpportunity_SetsOpportunityStage_GivenRequestStage() {
        Opportunity opportunity = TestClass_ValidOpportunityBuilder.Build();
        insert opportunity;
        OpportunityFromDMSInboundRequestBuilder opportunityBuilder = BuildOpportunityBuilder();
        
        string stage = 'test stage';
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = new DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity();
        request.Stage = stage;
        request.SFOpportunityID = opportunity.Id;
        
        Opportunity result = opportunityBuilder.BuildOpportunity(request, null);
        
        System.assertEquals(stage, result.StageName);
    }
    
    static testMethod void BuildOpportunity_SetsOpportunityStageToNegotiation_GivenNegotiationStageAndOpportunityNotAtOrder() {
        Opportunity opportunity = TestClass_ValidOpportunityBuilder.Build();
        opportunity.StageName = 'Contacted';
        insert opportunity;
        OpportunityFromDMSInboundRequestBuilder opportunityBuilder = BuildOpportunityBuilder();
        
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = new DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity();
        request.Stage = 'Negotiation';
        request.SFOpportunityID = opportunity.Id;
        
        Opportunity result = opportunityBuilder.BuildOpportunity(request, null);
        
        System.assertEquals('Negotiation', result.StageName);
    }
    
    static testMethod void BuildOpportunity_SetsOpportunityStageToLost_GivenLostStageAndOpportunityAtOrder() {
        Opportunity opportunity = TestClass_ValidOpportunityBuilder.Build();
        opportunity.StageName = 'Order';
        insert opportunity;
        OpportunityFromDMSInboundRequestBuilder opportunityBuilder = BuildOpportunityBuilder();
        
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = new DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity();
        request.Stage = 'Retailer Lost';
        request.SFOpportunityID = opportunity.Id;
        
        Set<Id> orderOppId = new Set<Id>();
        orderOppId.add(opportunity.Id);
        
        Opportunity result = opportunityBuilder.BuildOpportunity(request, orderOppId);
        
        System.assertEquals('Retailer Lost', result.StageName);
    }
    
    static testMethod void BuildOpportunity_DoesNotSetOpportunityStageToNegotiation_GivenNegotiationStageAndOpportunityAtOrder() {
        Opportunity opportunity = TestClass_ValidOpportunityBuilder.Build();
        opportunity.StageName = 'Order';
        insert opportunity;
        OpportunityFromDMSInboundRequestBuilder opportunityBuilder = BuildOpportunityBuilder();
        
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = new DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity();
        request.Stage = 'Negotiation';
        request.SFOpportunityID = opportunity.Id;
        
        Set<Id> orderOppId = new Set<Id>();
        orderOppId.add(opportunity.Id);
        
        Opportunity result = opportunityBuilder.BuildOpportunity(request, orderOppId);
        
        System.assertEquals('Order', result.StageName);
    }
    
    static testMethod void BuildOpportunity_SetsOpportunityStageTimeStamp_ToValueReturnedByAdapter() {
        Opportunity opportunity = TestClass_ValidOpportunityBuilder.Build();
        insert opportunity;
        OpportunityFromDMSInboundRequestBuilder opportunityBuilder = BuildOpportunityBuilder();
        
        string stageTimestamp = 'date time';
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = new DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity();
        request.StageTimestamp = stageTimestamp;
        request.SFOpportunityID = opportunity.Id;
        
        Opportunity result = opportunityBuilder.BuildOpportunity(request, null);
        
        System.assertEquals(DateTime.newInstance(1991, 10, 20), result.Stage_Timestamp__c);
    }
    
    /*static testMethod void BuildOpportunity_SetsOpportunityAmount_GivenRequestAmount() { //removed for 1.1
        Opportunity opportunity = TestClass_ValidOpportunityBuilder.Build();
        insert opportunity;
        OpportunityFromDMSInboundRequestBuilder opportunityBuilder = BuildOpportunityBuilder();
        
        Decimal amount = 1.5;
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = new DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity();
        request.Amount = amount;
        request.SFOpportunityID = opportunity.Id;
        
        Opportunity result = opportunityBuilder.BuildOpportunity(request);
        
        System.assertEquals(amount, result.Amount);
    }*/
    
    static testMethod void BuildOpportunity_SetsOpportunityCloseDate_ToValueReturnedByAdapter() {
        Opportunity opportunity = TestClass_ValidOpportunityBuilder.Build();
        insert opportunity;
        OpportunityFromDMSInboundRequestBuilder opportunityBuilder = BuildOpportunityBuilder();
        
        string closeDate = 'date';
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = new DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity();
        request.CloseDate = closeDate;
        request.SFOpportunityID = opportunity.Id;
        
        Opportunity result = opportunityBuilder.BuildOpportunity(request, null);
        
        System.assertEquals(Date.newInstance(1991, 10, 20), result.CloseDate);
    }
    
    /*static testMethod void BuildOpportunity_SetsOpportunityNextFollowUpDate_ToValueReturnedByAdapter() {
        OpportunityFromDMSInboundRequestBuilder opportunityBuilder = BuildOpportunityBuilder();
        
        string nextFollowUpDate = 'date';
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = new DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity();
        request.NextFollowUpDate = nextFollowUpDate;
        
        Opportunity result = opportunityBuilder.BuildOpportunity(request);
        
        System.assertEquals(Date.newInstance(1991, 10, 20), result.Next_Follow_Up_Date__c);
    }
    
    static testMethod void BuildOpportunity_SetsOpportunityNextPlannedActivity_GivenRequestNextPlannedActivity() {
        OpportunityFromDMSInboundRequestBuilder opportunityBuilder = BuildOpportunityBuilder();
        
        string nextPlannedActivity = 'dmsId';
        DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity request = new DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity();
        request.NextPlannedActivity = nextPlannedActivity;
        
        Opportunity result = opportunityBuilder.BuildOpportunity(request);
        
        System.assertEquals(nextPlannedActivity, result.Next_Planned_Activity__c);
    }*/
    
    
    private static OpportunityFromDMSInboundRequestBuilder BuildOpportunityBuilder()
    {
        VehicleSpecificationByNameRetriever vehicleSpecificationByNameRetriever = new VehicleSpecificationByNameRetriever();
        I_DateAdapter dateAdapter = new Dummy_DateAdapter();
        I_TimeAdapter timeAdapter = new Dummy_TimeAdapter();
        DateTimeAdapter dateTimeAdapter = new DateTimeAdapter(dateAdapter, timeAdapter);
        I_DMSAdapter_OpportunityStage stageAdapter = new Dummy_DMSAdapter_OpportunityStage();
        return new OpportunityFromDMSInboundRequestBuilder(vehicleSpecificationByNameRetriever, dateTimeAdapter, stageAdapter);
    }
    
    private class Dummy_DateAdapter implements I_DateAdapter{
        public Date parse(string dateString)
        {
            return Date.newInstance(1991, 10, 20);
        }
    }
    
    private class Dummy_TimeAdapter implements I_TimeAdapter{
        public Time parse(string timeString)
        {
            return Time.newInstance(0,0,0,0);
        }
    }
    
    private class Dummy_DMSAdapter_OpportunityStage implements I_DMSAdapter_OpportunityStage{
        public string GetSalesforceValue(string dmsValue)
        {
            return dmsValue;
        }
    }
}