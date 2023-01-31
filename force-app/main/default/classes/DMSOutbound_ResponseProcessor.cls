public class DMSOutbound_ResponseProcessor {
    private final DMS_PrefixHandler prefixHandler;

    public DMSOutbound_ResponseProcessor(DMS_PrefixHandler prefixHandler)
    {
        this.prefixHandler = prefixHandler;
    }

    public void ProcessResponse(DMSOutboundResponse response)
    {
        if(response.IsSuccess)
        {
            UpdateRecords(response);
            return; 
        }
        throw new DMSOutbound_InvalidDataException(response.ErrorMessage);
    }
    
    private void UpdateRecords(DMSOutboundResponse response)
    {
        List<SObject> objectsForUpdate = new List<SObject>();

        Opportunity opportunity = new Opportunity();
        opportunity.Id = response.SFOpportunityId;
        opportunity.TimeLastSentToDMS__c = Datetime.now();
        opportunity.DMS_Opportunity_ID__c = response.DMSOpportunityId;
        objectsForUpdate.add(opportunity);
        
        if(String.isNotEmpty(response.SFAccountId)){
            objectsForUpdate.add(this.BuildAccount(response));
        }
        
        Contact contact = new Contact();
        contact.Id = response.SFContactId;
        contact.TimeLastSentToDMS__c = Datetime.now();
        contact.DMS_Identifier__c = prefixHandler.AddPrefix(response.DMSContactId);
        objectsForUpdate.add(contact);
        
        update objectsForUpdate;
    }

    private Account BuildAccount(DMSOutboundResponse response)
    {
        Account account = new Account();

        account.Id = response.SFAccountId;
        account.TimeLastSentToDMS__c = Datetime.now();
        account.DMS_Identifier__c = prefixHandler.AddPrefix(response.DMSAccountId);

        return account;
    }
}