public class RequestObjectLookupSetter {
    private final MakeRetriever makeRetriever;
    private final AccountByCodeRetriever accountRetriever;
    private final CampaignRetriever campaignRetriever;
    private final ModelRetriever modelRetriever;
    private final AvokaFormInformation_Retriever avokaFormInformationRetriever;
    
    public RequestObjectLookupSetter(MakeRetriever makeRetriever, AccountByCodeRetriever accountRetriever,
        CampaignRetriever campaignRetriever, ModelRetriever modelRetriever,AvokaFormInformation_Retriever avokaFormInformationRetriever)
    {
        this.makeRetriever = makeRetriever;
        this.accountRetriever = accountRetriever;
        this.campaignRetriever = campaignRetriever;
        this.modelRetriever = modelRetriever;
        this.avokaFormInformationRetriever = avokaFormInformationRetriever;
    }
    
    public void SetLookups(Request__c requestRecord)
    {
        AvokaFormInformation avokaFormInformation = avokaFormInformationRetriever.Retrieve(requestRecord.Request_Source__c);
        string ciCode = requestRecord.Preferred_Retailer_Code__c;
        string brandPrefix = '';           
        if(ciCode != null && ciCode.length()==5){
            if(requestRecord.Brand__c == 'Land Rover'){
                brandPrefix = 'LR';
            }else{
                brandPrefix = 'J';
            }
            
            ciCode = brandprefix + avokaFormInformation.CountryISOCode + ciCode;
        }
        //requestRecord.Brand_Lookup__c = makeRetriever.Retrieve(requestRecord.Brand__c).Id;
        requestRecord.Preferred_Retailer__c = accountRetriever.Retrieve(ciCode).Id;
        //requestRecord.Campaign__c = campaignRetriever.RetrieveByCode(requestRecord.Campaign_Code__c).Id;temporarily removed from 1.0
        //requestRecord.Primary_Model_Of_Interest__c = modelRetriever.RetrieveByName(requestRecord.Primary_Model_Of_Interest_Text__c,
        	//requestRecord.Brand__c).Id;
    }
}