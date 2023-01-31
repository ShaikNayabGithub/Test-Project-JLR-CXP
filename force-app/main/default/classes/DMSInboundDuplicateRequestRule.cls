public class DMSInboundDuplicateRequestRule implements I_DMSInboundRequestValidationRule{
	private final Map<Id, DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity> processedRequests;
	private final DateTimeAdapter dateTimeAdapter;

	public DMSInboundDuplicateRequestRule(Map<Id, DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity> processedRequests, DateTimeAdapter dateTimeAdapter)
	{
		this.processedRequests = processedRequests;
		this.dateTimeAdapter = dateTimeAdapter;
	}


	public void Validate(DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity inboundDMSRequest, 
    	DMSInboundUpdateResponse postValidationResponse)
    {
    	if(processedRequests.containsKey(inboundDMSRequest.SFOpportunityID)){ this.ProcessDuplicateRequest(inboundDMSRequest, postValidationResponse); }
    		else{ this.processedRequests.put(inboundDMSRequest.SFOpportunityID, inboundDMSRequest); }
    }


    private void ProcessDuplicateRequest(DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity duplicateRequest, 
    	DMSInboundUpdateResponse duplicateResponse)
    {
    	DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity existingRequest = this.processedRequests.get(duplicateRequest.SFOpportunityID);
    	try{
	    	if(dateTimeAdapter.parseDateTime(existingRequest.StageTimestamp) < dateTimeAdapter.parseDateTime(duplicateRequest.StageTimestamp))
	    	{
	    		existingRequest.SetDataFromRequest(duplicateRequest);
	    	}
	    	duplicateResponse.SetError(10007, System.Label.DMSInboundDuplicateRequestException);
    	}catch(TypeException e){
            string exceptionMessage = String.format(System.Label.DMSException_FieldFormat, new List<String> { ' StageTimestamp ' });
    		duplicateResponse.SetError(10003, exceptionMessage);
    	}
    }
}