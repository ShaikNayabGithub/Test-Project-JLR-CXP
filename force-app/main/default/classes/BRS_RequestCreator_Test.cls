@isTest
public class BRS_RequestCreator_Test {
	static testmethod void CreateRequests_InsertsBRSRequest_GivenFeature()
    {
    	BRS_RequestCreator requestCreator = new BRS_RequestCreator();

        BRS_Service.BRSExport brsExport = BuildValidBRSExport();
        List<BRS_Service.Feature> features = new List<BRS_Service.Feature>();
        BRS_Service.Feature feature = new BRS_Service.Feature();
        feature.Code = 'testCode';
        feature.DisplayGroup = 'testDisplay';
        feature.FeatureGroup = 'tFeatGroup';
        feature.Descriptions = new List<BRS_Service.Description>();
        BRS_Service.Description description = new BRS_Service.Description();
        description.Language = 'IN';
        description.Text = 'testDescription';
        feature.Descriptions.Add(description);
        features.Add(feature);
        
        requestCreator.CreateRequests(brsExport, features, new List<BRS_Service.Model>(), new List<BRS_Service.Derivative>());
        
        Integer retrievedRequestCount = [Select COUNT() From BRS_Request__c Where Name=:String.valueOf(brsExport.Serial)];
        
        System.AssertEquals(1, retrievedRequestCount);
    }


    private static BRS_Service.BRSExport BuildValidBRSExport()
    {
        BRS_Service.BRSExport brsExport = new BRS_Service.BRSExport();
        
        brsExport.Serial = 1234;
        brsExport.Market = 'te';
        brsExport.MarketDescription = 'MarketDescription';
        brsExport.Brand = 'Test';
        
        brsExport.Currencies = new List<String>{ 'INR' };
        
        return brsExport;
    }
}