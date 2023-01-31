public class DMSInboundRequestFormatValidationRule implements I_DMSInboundRequestValidationRule{
	private final DateTimeAdapter dateTimeAdapter;
	
	public DMSInboundRequestFormatValidationRule(DateTimeAdapter dateTimeAdapter)
	{
		this.dateTimeAdapter = dateTimeAdapter;
	}
	
    public void Validate(DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity inboundDMSRequest, 
    	DMSInboundUpdateResponse postValidationResponse)
    {
    	string offendingField = '';
    	try{
    		offendingField = ' StageTimestamp ';
    		if(string.isNotEmpty(inboundDMSRequest.StageTimestamp)){
    			dateTimeAdapter.parseDateTime(inboundDMSRequest.StageTimestamp);
    		}
    		offendingField = ' CloseDate ';
    		if(string.isNotEmpty(inboundDMSRequest.CloseDate)){
    			dateTimeAdapter.parseDate(inboundDMSRequest.CloseDate);
    		}
            if(inboundDMSRequest.DMSActivities != null) {
        		offendingField = ' NextFollowUpDate ';
                for(DMSInboundIntegrationService.DMSActivity activity : inboundDMSRequest.DMSActivities){
                    if(string.isNotEmpty(activity.NextFollowUpDate)){
                        dateTimeAdapter.parseDate(activity.NextFollowUpDate);
                    }
                }  
            }  		
    	}
        catch(TypeException e){
            string exceptionMessage = String.format(System.Label.DMSException_FieldFormat, new List<String> { offendingField });
    		postValidationResponse.SetError(10003, exceptionMessage);
    	}
    }
}