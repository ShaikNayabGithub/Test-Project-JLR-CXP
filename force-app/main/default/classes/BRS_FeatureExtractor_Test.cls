@isTest
public class BRS_FeatureExtractor_Test {
    static testmethod void Extract_ReturnsEmptyMap_GivenEmptyList()
    {
    	BRS_FeatureExtractor extractor = BuildExtractor();
    	
    	List<BRS_Request__c> requests = new List<BRS_Request__c>();
    	
    	Map<BRS_Service.Feature, BRS_Request__c> result = extractor.Extract(requests);
    	
    	System.AssertEquals(0, result.Size());
    }
    
    static testmethod void Extract_ReturnsEmptyMap_GivenRequestWithNoFeatures()
    {
    	BRS_FeatureExtractor extractor = BuildExtractor();
    	
    	List<BRS_Request__c> requests = new List<BRS_Request__c>();
    	BRS_Request__c request1 = new BRS_Request__c();
    	requests.Add(request1);
    	
    	Map<BRS_Service.Feature, BRS_Request__c> result = extractor.Extract(requests);
    	
    	System.AssertEquals(0, result.Size());
    }
    
    static testmethod void Extract_ReturnsFeatureOne_GivenRequestWithFeatureOne()
    {
    	BRS_FeatureExtractor extractor = BuildExtractor();
    	
    	List<BRS_Request__c> requests = new List<BRS_Request__c>();
    	BRS_Request__c request1 = new BRS_Request__c();
    	request1.Features__c = '[{"FeatureGroup":null,"DisplayGroup":null,"Descriptions":null,"Code":"feature1"}]';
    	requests.Add(request1);
    	
    	Map<BRS_Service.Feature, BRS_Request__c> result = extractor.Extract(requests);
    	
    	System.AssertEquals('feature1', new List<BRS_Service.Feature>(result.keySet())[0].code);
    }
    
    static testmethod void Extract_ReturnsFeatureTwo_GivenRequestWithFeatureOneAndFeatureTwo()
    {
    	BRS_FeatureExtractor extractor = BuildExtractor();
    	
    	List<BRS_Request__c> requests = new List<BRS_Request__c>();
    	BRS_Request__c request1 = new BRS_Request__c();
    	request1.Features__c = '[{"FeatureGroup":null,"DisplayGroup":null,"Descriptions":null,"Code":"feature1"},{"FeatureGroup":null,"DisplayGroup":null,"Descriptions":null,"Code":"feature2"}]';
    	requests.Add(request1);
    	
    	Map<BRS_Service.Feature, BRS_Request__c> result = extractor.Extract(requests);
    	
    	System.AssertEquals('feature2', new List<BRS_Service.Feature>(result.keySet())[1].code);
    }
    
    static testmethod void Extract_ReturnsFeatureThree_GivenRequestWithFeatureOneAndFeatureTwoAndRequestTwoWithFeatureThree()
    {
    	BRS_FeatureExtractor extractor = BuildExtractor();
    	
    	List<BRS_Request__c> requests = new List<BRS_Request__c>();
    	BRS_Request__c request1 = new BRS_Request__c();
    	request1.Features__c = '[{"FeatureGroup":null,"DisplayGroup":null,"Descriptions":null,"Code":"feature1"},{"FeatureGroup":null,"DisplayGroup":null,"Descriptions":null,"Code":"feature2"}]';
    	requests.Add(request1);
    	BRS_Request__c request2 = new BRS_Request__c();
    	request2.Features__c = '[{"FeatureGroup":null,"DisplayGroup":null,"Descriptions":null,"Code":"feature3"}]';
    	requests.Add(request2);
    	
    	Map<BRS_Service.Feature, BRS_Request__c> result = extractor.Extract(requests);
    	
    	System.AssertEquals('feature3', new List<BRS_Service.Feature>(result.keySet())[2].code);
    }
    
    static testmethod void Extract_ReturnsFeatureThreeAndRequestTwo_GivenRequestWithFeatureOneAndFeatureTwoAndRequestTwoWithFeatureThree()
    {
    	BRS_FeatureExtractor extractor = BuildExtractor();
    	
    	List<BRS_Request__c> requests = new List<BRS_Request__c>();
    	BRS_Request__c request1 = new BRS_Request__c();
    	request1.Features__c = '[{"FeatureGroup":null,"DisplayGroup":null,"Descriptions":null,"Code":"feature1"},{"FeatureGroup":null,"DisplayGroup":null,"Descriptions":null,"Code":"feature2"}]';
    	requests.Add(request1);
    	BRS_Request__c request2 = new BRS_Request__c();
    	request2.Features__c = '[{"FeatureGroup":null,"DisplayGroup":null,"Descriptions":null,"Code":"feature3"}]';
    	requests.Add(request2);
    	
    	Map<BRS_Service.Feature, BRS_Request__c> result = extractor.Extract(requests);
    	
    	BRS_Service.Feature feature3 = new List<BRS_Service.Feature>(result.keySet())[2];
    	System.AssertEquals(request2, result.get(feature3));
    }
    
    static testmethod void Extract_ReturnsOneFeature_GivenRequestWithFeatureOneAndDerivativeWithWheelBaseFeatureOne()
    {
    	BRS_FeatureGroupFieldMappingByCode__c setting = new BRS_FeatureGroupFieldMappingByCode__c(Name='1',Field_Name__c='Wheel_Driven__c');
    	insert setting;
    	BRS_FeatureExtractor extractor = BuildExtractor();
    	
    	List<BRS_Request__c> requests = new List<BRS_Request__c>();
    	BRS_Request__c request1 = new BRS_Request__c();
    	request1.Features__c = '[{"FeatureGroup":null,"DisplayGroup":null,"Descriptions":null,"Code":"feature1"}]';
    	request1.Derivatives__c = '[{"WheelDriven":"feature1","WheelBase":null,"Transmission":null,"Name":null,"ModelCode":null,"Language":null,"FuelType":null,"Engine":null,"DescriptionGroupId":null,"Colour":null,"BrochureModel":null,"BodyStyle":null}]';
    	requests.Add(request1);
    	
    	Map<BRS_Service.Feature, BRS_Request__c> result = extractor.Extract(requests);
    	
    	System.AssertEquals(1, result.Size());
    }
    
    
    private static BRS_FeatureExtractor BuildExtractor()
    {
    	JSONDeserializer deserializer = new JSONDeserializer();
    	return new BRS_FeatureExtractor(deserializer);
    }
}