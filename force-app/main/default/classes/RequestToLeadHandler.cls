public class RequestToLeadHandler {
    private final AccountByRequestRecordRetriever accountByRequestRecordRetriever;
    private final ExistingLeadRetriever existingLeadRetriever;
    private final LeadCreator leadCreator;
    private final AvokaFormInformation_Retriever avokaFormInformationRetriever;

    public RequestToLeadHandler(AccountByRequestRecordRetriever accountByRequestRecordRetriever,
        ExistingLeadRetriever existingLeadRetriever, LeadCreator leadCreator, AvokaFormInformation_Retriever avokaFormInformationRetriever)
    {
        this.accountByRequestRecordRetriever = accountByRequestRecordRetriever;
        this.existingLeadRetriever = existingLeadRetriever;
        this.leadCreator = leadCreator;
        this.avokaFormInformationRetriever = avokaFormInformationRetriever;
    }
    
    public void HandleRequest(Request__c requestRecord)
    {
        Account existingAccount = accountByRequestRecordRetriever.Retrieve(requestRecord);
        AvokaFormInformation avokaFormInformation = avokaFormInformationRetriever.Retrieve(requestRecord);
        Boolean leadExists = existingLeadRetriever.LeadExists(requestRecord, existingAccount, avokaFormInformation);
        if(leadExists){ return; }
        leadCreator.Create(requestRecord, existingAccount, avokaFormInformation);
    }
}