public class HasChangedSinceLastSentValidationRule implements I_OpportunityValidator{
	public void Validate(Opportunity opportunity)
    {
    	if(opportunity.LastModifiedDate <= opportunity.TimeLastSentToDMS__c &&
    		opportunity.Account.LastModifiedDate <= opportunity.Account.TimeLastSentToDMS__c &&
    		opportunity.OpportunityContactRoles[0].Contact.LastModifiedDate <= opportunity.OpportunityContactRoles[0].Contact.TimeLastSentToDMS__c )
    	{
            throw new DMSOutbound_InvalidDataException(System.Label.DMSException_DataUnchanged);
    	}
    }
}