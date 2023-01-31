global with sharing class DMSInboundIntegrationService {
    webservice static InitialResponse UpdateMultipleOpportunities(List<InboundDMSRequest_UpdateOpportunity> inboundDMSRequests)
    {
    	 Integration_Log__c log=new Integration_Log__c();
         InitialResponse response;
        try{
            DMSInbound_RequestProcessor_Factory requestProcessorFactory = new DMSInbound_RequestProcessor_Factory();
            DMSBatchOpportunityUpdater requestProcessor = requestProcessorFactory.CreateBatchProcessor(inboundDMSRequests);
            log.status__c='Success';
            Id jobId = Database.executeBatch(requestProcessor,20);
            response=new InitialResponse(jobId);
            return response;
        }
        catch(Exception e)
        {
             log.status__c='Error';
            response=new InitialResponse();
            return response;
        }
        Finally{
            
            log.request__c=(String)Json.serializePretty(inboundDMSRequests);
            log.service__c='DMS India Inbound';
            log.response__c = (String)Json.serializePretty(response);
            insert log;  

        }
    }

    global class InboundDMSRequest_UpdateOpportunity {
        webservice string DMSOpportunityID;
        webservice Id SFOpportunityID;
        webservice string Stage;
        webservice string StageTimestamp;//datetime
        webservice Decimal Amount;
        webservice string CloseDate;//date
        webservice List<DMSActivity> DMSActivities;
        webservice string Make;
        webservice string Model;
        webservice string Derivative;

        public void SetDataFromRequest(InboundDMSRequest_UpdateOpportunity requestToCopyFrom)
        {
            this.Stage = requestToCopyFrom.Stage;
            this.StageTimestamp = requestToCopyFrom.StageTimestamp;
            this.Amount = requestToCopyFrom.Amount;
            this.CloseDate = requestToCopyFrom.CloseDate;
            this.DMSActivities = requestToCopyFrom.DMSActivities;
            this.Make = requestToCopyFrom.Make;
            this.Model = requestToCopyFrom.Model;
            this.Derivative = requestToCopyFrom.Derivative;
        }
    }

    global class DMSActivity{
        webservice string DMSId;
        webservice string NextFollowUpDate;//date
        webservice string NextPlannedActivity;
    }

    global class InitialResponse{
        webservice boolean IsSuccess;
        webservice Id BatchId;
        webservice integer ErrorCode;
        webservice string ResponseMessage;
        
        public InitialResponse(Id batchId)
        {
            IsSuccess = true;
            BatchId = batchId;
        }
        
        public InitialResponse()
        {
            IsSuccess = false;
            ErrorCode = 10006;
            ResponseMessage = System.Label.DMSException_UnknownError;
        }
    }
    
    public static List<Id> GetRequestIds(List<InboundDMSRequest_UpdateOpportunity> requests)
    {
        List<Id> requestIds = new List<Id>();
        for(InboundDMSRequest_UpdateOpportunity request : requests)
        {
            requestIds.add(request.SFOpportunityID);
        }
        return requestIds;
    }
}