public class PostDatabaseInsertDMSResponseUpdater {//no abstraction/common interface for SaveResult and UpsertResult (thank SF...)
    public void UpdateResponses(Database.SaveResult[] databaseResults, DMSInboundUpdateResponse[] responses)
    {
		system.debug('databaseResults -==> '+databaseResults);
    	if(databaseResults.size() != responses.size()){
    		throw new ListException('PostDatabaseInsertDMSResponseUpdater.UpdateResponses: results size does not match response size.'); }
    		
    	for(integer i = 0; i < databaseResults.size(); i++)
    	{
    		if(!databaseResults[i].isSuccess())
    		{
    			this.SetError(responses[i]);
    		}
    	}
    }

    public void UpdateResponses(Database.UpsertResult[] databaseResults, DMSInboundUpdateResponse[] responses)
    {	
		system.debug('databaseResults -==> '+databaseResults);
        if(databaseResults.size() != responses.size()){
            throw new ListException('PostDatabaseInsertDMSResponseUpdater.UpdateResponses: results size does not match response size.'); }
            
        for(integer i = 0; i < databaseResults.size(); i++)
        {
            if(!databaseResults[i].isSuccess())
            {
                this.SetError(responses[i]);
            }
        }
    }

    private void SetError(DMSInboundUpdateResponse response)
    {
		String expMessage;
        string exceptionMessage = String.format(System.Label.DMSException_OpportunityUpdateFailure, new List<String> { response.DMSOpportunityID });
        if(!response.IsSuccess){ exceptionMessage = 'First exception: ' + response.ResponseMessage + ' Second exception: ' + exceptionMessage; }
		expMessage = 'First exception: ' + response.ResponseMessage + ' Second exception: ' + exceptionMessage;
        system.debug('expMessage -==> '+expMessage);
        response.SetError(10005, exceptionMessage);
    }
}