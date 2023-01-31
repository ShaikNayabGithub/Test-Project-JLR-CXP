public class BRS_RequestCreator{
    private final JSONSerializer serializer = new JSONSerializer();
    
    
    public void CreateRequests(BRS_Service.BRSExport BRSExport, List<BRS_Service.Feature> Features, List<BRS_Service.Model> Models, List<BRS_Service.Derivative> Derivatives)
    {
        List<String> serializedModels = this.serializer.Serialize(Models, 10000);
        List<String> serializedDerivatives = this.serializer.Serialize(Derivatives, 50000);
        List<String> serializedFeatures = this.serializer.Serialize(Features, 100000);

        List<BRS_Request__c> requests = new List<BRS_Request__c>();
        
        this.AddRequestFieldData(BRSExport, requests, serializedModels, BRSRequestUtilities.ModelFieldName);
        this.AddRequestFieldData(BRSExport, requests, serializedDerivatives, BRSRequestUtilities.DerivativeFieldName);
        this.AddRequestFieldData(BRSExport, requests, serializedFeatures, BRSRequestUtilities.FeatureFieldName);
        
        if(requests.Size() == 0) { throw new BRS_NoUsefulDataException(); }
        insert requests;
    }


    private void AddRequestFieldData(BRS_Service.BRSExport BRSExport, List<BRS_Request__c> requests,  List<String> fieldData, String fieldName)
    {
        for(Integer i = 0; i < fieldData.Size(); i++){
            if(requests.Size() <= i) {
                requests.Add(this.BuildRequest(BRSExport));
            }
            requests[i].put(fieldName, fieldData[i]);
        }
    }

    private BRS_Request__c BuildRequest(BRS_Service.BRSExport BRSExport)
    {
        BRS_Request__c request = new BRS_Request__c();

        request.Name = String.valueOf(BRSExport.Serial);
        request.Market__c = BRSExport.Market;
        request.Market_Description__c = BRSExport.MarketDescription;
        request.Brand__c = BRSExport.Brand;
        request.Short_Brand__c = BRSExport.ShortBrand;
        request.Status__c = BRSRequestUtilities.UnprocessedStatus;
        request.Currencies__c = JSON.serialize(BRSExport.Currencies);

        return request;
    }
}