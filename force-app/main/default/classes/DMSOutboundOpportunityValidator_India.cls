public class DMSOutboundOpportunityValidator_India implements I_OpportunityValidator{
    public void Validate(Opportunity opportunity)
    {
    	DMS_FieldPopulatedValidator.CheckField(opportunity, Schema.sObjectType.Opportunity.fields.LeadSource);

    	if(opportunity.OpportunityLineItems.size() == 0){ throw new DMSOutbound_InvalidDataException(System.Label.DMSException_MissingProduct); }
    	DMS_FieldPopulatedValidator.CheckField(opportunity.OpportunityLineItems[0], Schema.sObjectType.OpportunityLineItem.fields.Brand__c);
    	DMS_FieldPopulatedValidator.CheckField(opportunity.OpportunityLineItems[0], Schema.sObjectType.OpportunityLineItem.fields.Model__c);
    	DMS_FieldPopulatedValidator.CheckField(opportunity.OpportunityLineItems[0], Schema.sObjectType.OpportunityLineItem.fields.Product2Id);
    }
}