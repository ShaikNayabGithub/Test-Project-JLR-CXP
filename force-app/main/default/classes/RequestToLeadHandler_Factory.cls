public class RequestToLeadHandler_Factory {
    public RequestToLeadHandler Create()
    {
        ContactMatcher contactMatcher = new ContactMatcher();
        AccountByRequestRecordRetriever accountByRequestRecordRetriever = new AccountByRequestRecordRetriever(contactMatcher);
        ExistingLeadRetriever existingLeadRetriever = new ExistingLeadRetriever();
        AvokaFormInformation_Retriever avokaFormInformationRetriever = new AvokaFormInformation_Retriever();
        
        ModelRetriever modelRetriever = new ModelRetriever();
        RetailerContactRequestRetriever retailerContactRequestRetriever = new RetailerContactRequestRetriever();
        LeadBuilder leadBuilder = new LeadBuilder(modelRetriever);
        LeadCreator leadCreator = new LeadCreator(leadBuilder);
        
        return new RequestToLeadHandler(accountByRequestRecordRetriever, existingLeadRetriever, leadCreator, avokaFormInformationRetriever);
    }
}