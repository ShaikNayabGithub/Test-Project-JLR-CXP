public class DMSOutbound_OwnerDMSIdValidationRule implements I_OpportunityValidator{
    public void Validate(Opportunity opportunity)
    {
        string offendingRecord = '';
        if(String.isEmpty(opportunity.Owner.DMS_Id__c) && String.isEmpty(opportunity.DMS_Opportunity_ID__c)){
            offendingRecord = GetObjectName(opportunity); }
        if(String.isEmpty(opportunity.Account.owner.DMS_Id__c) && String.isEmpty(opportunity.Account.DMS_Identifier__c)){ 
            offendingRecord = GetObjectName(opportunity.Account); }
        if(String.isEmpty(opportunity.OpportunityContactRoles[0].Contact.Account.owner.DMS_Id__c) && String.isEmpty(opportunity.OpportunityContactRoles[0].Contact.DMS_Identifier__c)){ 
            offendingRecord = GetObjectName(opportunity.OpportunityContactRoles[0].Contact); }
        
        if(String.isNotEmpty(offendingRecord))
        {
            string exceptionMessage = String.format(System.Label.DMSException_OwnerMissingDMSId, new List<String> {offendingRecord} );
            throw new DMSOutbound_InvalidDataException(exceptionMessage);
        }
    }

    private string GetObjectName(SObject record)
    {
        return String.valueOf(record.getSObjectType());
    }
}