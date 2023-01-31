global class DMSBatchOpportunityUpdater implements Database.batchable<DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity>, Database.AllowsCallouts, Database.Stateful{
    private final DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity[] requests;
    private final List<DMSInboundUpdateResponse> responses;
    
    private final DMSInboundRequestValidator dmsInboundRequestValidator;
    private final OpportunityFromDMSInboundRequestBuilder opportunityFromDMSInboundRequestBuilder;
    private final PostDatabaseInsertDMSResponseUpdater postDatabaseInsertDMSResponseUpdater;
    private final I_DMSMessager_Response dmsMessager;
    private final DMSInbound_TaskBuilder taskBuilder;
    
    public final Set<Id> orderOppIds;
    
    public DMSBatchOpportunityUpdater(DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity[] requests,
        List<DMSInboundUpdateResponse> responses,
        DMSInboundRequestValidator dmsInboundRequestValidator, 
        OpportunityFromDMSInboundRequestBuilder opportunityFromDMSInboundRequestBuilder,
        PostDatabaseInsertDMSResponseUpdater postDatabaseInsertDMSResponseUpdater, I_DMSMessager_Response dmsMessager,
        DMSInbound_TaskBuilder taskBuilder)
    {
        this.requests = requests;
        this.responses = responses;
        
        this.dmsInboundRequestValidator = dmsInboundRequestValidator;
        this.opportunityFromDMSInboundRequestBuilder = opportunityFromDMSInboundRequestBuilder;
        this.postDatabaseInsertDMSResponseUpdater = postDatabaseInsertDMSResponseUpdater;
        this.dmsMessager = dmsMessager;
        this.taskBuilder = taskBuilder;
        
        this.orderOppIds = new Set<Id>();
    }
    
    
    global Iterable<DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity> start(Database.BatchableContext info)
    {
        return requests;
    }
    
    
    global void execute(Database.BatchableContext info, List<DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity> inboundDMSRequests)//refactor me!!
    {
        system.debug('@@ inboundDMSRequests '+inboundDMSRequests);
        List<Opportunity> opportunitiesForUpdate = new List<Opportunity>();
        List<DMSInboundUpdateResponse> responsesForUpdate = new List<DMSInboundUpdateResponse>();

        List<Task> tasksForInsertion = new List<Task>();
        List<DMSInboundUpdateResponse> responsesWithTasks = new List<DMSInboundUpdateResponse>();
        
        //obtain the Opportunity Ids for all inboundDMSRequests - need to determine what the current stage of these is
        Set<Id> idsToQuery = new Set<Id>();
        for(DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity inboundDMSRequest : inboundDMSRequests){
            if(inboundDMSRequest.SFOpportunityID != null){
                idsToQuery.add(inboundDMSRequest.SFOpportunityID);
            }
        }
        system.debug('idsToQuery '+idsToQuery);
        if(idsToQuery.isEmpty() == false){
            for(Opportunity opp : [SELECT Id, StageName FROM Opportunity WHERE Id IN :idsToQuery AND (StageName = 'Order' OR StageName = 'Order Taken')]){
                orderOppIds.add(opp.Id);
            }    
        }
        system.debug('orderOppIds '+orderOppIds);
        for(DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity inboundDMSRequest : inboundDMSRequests)
        {
            DMSInboundUpdateResponse postValidationResponse = new DMSInboundUpdateResponse(inboundDMSRequest.SFOpportunityID, inboundDMSRequest.DMSOpportunityID);
            responses.add(postValidationResponse);
            system.debug('responses '+responses);
            try
            {
                dmsInboundRequestValidator.Validate(inboundDMSRequest, postValidationResponse);
				system.debug('validated '+postValidationResponse.IsSuccess);
                system.debug('validated '+postValidationResponse.ResponseMessage);
                
                if(postValidationResponse.IsSuccess){
                    taskBuilder.Build(inboundDMSRequest, postValidationResponse, tasksForInsertion,
                            responsesWithTasks);

                    opportunitiesForUpdate.add(opportunityFromDMSInboundRequestBuilder.BuildOpportunity(inboundDMSRequest, orderOppIds));
                    responsesForUpdate.add(postValidationResponse);
                }
            }
            catch(Exception e)
            {
                postValidationResponse.SetError(10006, e.getMessage());
            }
        }

        Database.UpsertResult[] taskResults = Database.upsert(tasksForInsertion, false);
        postDatabaseInsertDMSResponseUpdater.UpdateResponses(taskResults, responsesWithTasks);
        
        Database.SaveResult[] opportunityResults = Database.update(opportunitiesForUpdate, false);
        postDatabaseInsertDMSResponseUpdater.UpdateResponses(opportunityResults, responsesForUpdate);
    }
    
    
    global void finish(Database.BatchableContext info)
    {
        DMSInboundUpdateResponseCollection responseCollection = new DMSInboundUpdateResponseCollection(responses, info.getJobId());
        dmsMessager.SendResponses(responseCollection);
    }
}