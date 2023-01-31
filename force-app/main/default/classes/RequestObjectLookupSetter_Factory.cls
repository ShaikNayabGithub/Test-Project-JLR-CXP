public class RequestObjectLookupSetter_Factory {
    public RequestObjectLookupSetter Create()
    {
        CampaignRetriever campaignRetriever = new CampaignRetriever();
        AccountByCodeRetriever accountRetriever = new AccountByCodeRetriever();
        MakeRetriever makeRetriever = new MakeRetriever();
        ModelRetriever modelRetriever = new ModelRetriever();
        AvokaFormInformation_Retriever avokaFormInformationRetriever = new AvokaFormInformation_Retriever();
        
        return new RequestObjectLookupSetter(makeRetriever, accountRetriever, campaignRetriever,
        	modelRetriever,avokaFormInformationRetriever );
    }
}