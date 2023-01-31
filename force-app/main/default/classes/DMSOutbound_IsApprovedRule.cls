public class DMSOutbound_IsApprovedRule implements I_OpportunityValidator{
	public void Validate(Opportunity opportunity)
    {
    	if(opportunity.Approved_for_DMS_Hidden__c){ return; }
		throw new DMSOutbound_InvalidDataException(System.Label.DMSException_NotYetApproved);
    }
}