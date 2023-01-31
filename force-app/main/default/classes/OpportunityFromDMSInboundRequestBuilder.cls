public class OpportunityFromDMSInboundRequestBuilder {//change for new Product setup
    private final VehicleSpecificationByNameRetriever vehicleSpecificationByNameRetriever;
    private final DateTimeAdapter dateTimeAdapter;
    private final I_DMSAdapter_OpportunityStage opportunityStageAdapter;
    
    public OpportunityFromDMSInboundRequestBuilder(VehicleSpecificationByNameRetriever vehicleSpecificationByNameRetriever, 
        DateTimeAdapter dateTimeAdapter, I_DMSAdapter_OpportunityStage opportunityStageAdapter)
    {
        this.vehicleSpecificationByNameRetriever = vehicleSpecificationByNameRetriever;
        this.dateTimeAdapter = dateTimeAdapter;
        this.opportunityStageAdapter = opportunityStageAdapter;
    }
    
    public Opportunity BuildOpportunity(DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity inboundDMSRequest, Set<Id> opportunitiesAtOrderStage)
    {
        //Vehicle_Specification__c derivative = vehicleSpecificationByNameRetriever.RetrieveDerivative(inboundDMSRequest.Make, inboundDMSRequest.Model, inboundDMSRequest.Derivative);
        
        Opportunity opportunity = new Opportunity();
        opportunity.Id = inboundDMSRequest.SFOpportunityID;
        opportunity.DMS_Opportunity_ID__c = inboundDMSRequest.DMSOpportunityID;
        //opportunity.Brand__c = derivative.Make__c;
        //opportunity.Primary_Model_Interest__c = derivative.Model__c;
        //opportunity.Derivative__c = derivative.Id;
        //don't want to update Stage if Opportunity is already at Order stage and DMS is setting value to Negotiation
        if(opportunitiesAtOrderStage != null && !opportunitiesAtOrderStage.isEmpty() && opportunitiesAtOrderStage.contains(inboundDMSRequest.SFOpportunityID) && opportunityStageAdapter.GetSalesforceValue(inboundDMSRequest.Stage) == 'Negotiation'){
            opportunity.StageName = 'Order';
        }
        else{
            this.SetStage(opportunity, inboundDMSRequest.Stage);
        }
        if(String.isNotEmpty(inboundDMSRequest.StageTimestamp)){ opportunity.Stage_Timestamp__c = dateTimeAdapter.parseDateTime(inboundDMSRequest.StageTimestamp); }
        this.SetAmount(opportunity, inboundDMSRequest);
        if(String.isNotEmpty(inboundDMSRequest.CloseDate)){ opportunity.CloseDate = dateTimeAdapter.parseDate(inboundDMSRequest.CloseDate); }
        
        return opportunity;
    }

    private void SetStage(Opportunity opportunity, string dmsStage)
    {
        opportunity.StageName = opportunityStageAdapter.GetSalesforceValue(dmsStage);
        DMSInbound_StageFieldUpdates__c customSetting = DMSInbound_StageFieldUpdates__c.getInstance(opportunity.StageName);
        if(customSetting == null){ return; }
        
        String[] fieldsToUpdate = customSetting.FieldsToUpdate__c.split(customSetting.Deliminator__c);
        String[] fieldValues = customSetting.FieldValues__c.split(customSetting.Deliminator__c);

        for(integer i = 0; i < fieldsToUpdate.size(); i++)
        {
            if(i >= fieldValues.size()){ break; }
            opportunity.put(fieldsToUpdate[i], fieldValues[i]);
        }
    }

    private void SetAmount(Opportunity opportunity, DMSInboundIntegrationService.InboundDMSRequest_UpdateOpportunity inboundDMSRequest)
    {
        /*if(inboundDMSRequest.Amount != null){ opportunity.Amount = inboundDMSRequest.Amount; return; }

        Id previousDerivative = [Select Derivative__c from Opportunity Where Id =: inboundDMSRequest.SFOpportunityID].Derivative__c;
        if(opportunity.Derivative__c != previousDerivative){ return; }
        
        Decimal derivativePrice = [Select Price__c From Vehicle_Specification__c Where Id =: opportunity.Derivative__c].Price__c;
        if(derivativePrice == null) { return; }

        opportunity.Amount = derivativePrice;*/
    }
}