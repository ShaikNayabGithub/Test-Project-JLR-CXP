@isTest
public class BRS_PicklistAdapter_Test {
    static testmethod void Adapt_ReturnsEmptyMap_GivenMap()
    {
    	BRS_PicklistAdapter adapter = CreateAdapter();
    	
    	Map<BRS_Service.Feature, BRS_Request__c> features = new Map<BRS_Service.Feature, BRS_Request__c>();
    	
    	Map<String, BRS_PicklistGroup_A> results = adapter.Adapt(features);
    	
    	System.AssertEquals(0, results.Size());
    }
    
    static testmethod void Adapt_ReturnsPicklistGroupOneWithValueTwo_GivenFeatureGroupOneAndCodeTwo()
    {
    	String featureGroup = '1';
    	String featureGroupField = 'Wheel_Driven';
    	BRS_FeatureGroupFieldMappingByCode__c setting = new BRS_FeatureGroupFieldMappingByCode__c(Name=featureGroup,Field_Name__c=featureGroupField);
    	insert setting;
    	
    	BRS_PicklistAdapter adapter = CreateAdapter();
    	
    	Map<BRS_Service.Feature, BRS_Request__c> features = new Map<BRS_Service.Feature, BRS_Request__c>();
    	BRS_Service.Feature feature = new BRS_Service.Feature();
    	feature.code = '2';
    	feature.FeatureGroup = featureGroup;
    	BRS_Request__c request = new BRS_Request__c();
    	features.put(feature, request);
    	
    	Map<String, BRS_PicklistGroup_A> results = adapter.Adapt(features);
    	
    	System.Assert(results.get(featureGroupField).GetValues().contains(feature.code));
    }
    
    static testmethod void Adapt_ReturnsPicklistGroupOneWithRequest_GivenFeatureGroupOne()
    {
    	String featureGroup = '1';
    	String featureGroupField = 'Wheel_Driven';
    	BRS_FeatureGroupFieldMappingByCode__c setting = new BRS_FeatureGroupFieldMappingByCode__c(Name=featureGroup,Field_Name__c=featureGroupField);
    	insert setting;
    	
    	BRS_PicklistAdapter adapter = CreateAdapter();
    	
    	Map<BRS_Service.Feature, BRS_Request__c> features = new Map<BRS_Service.Feature, BRS_Request__c>();
    	BRS_Service.Feature feature = new BRS_Service.Feature();
    	feature.code = '2';
    	feature.FeatureGroup = featureGroup;
    	BRS_Request__c request = TestClass_BRSRequestCreator.Create();
    	features.put(feature, request);
    	
    	Map<String, BRS_PicklistGroup_A> results = adapter.Adapt(features);
    	
    	System.AssertEquals(request, results.get(featureGroupField).Requests.get(request.Id));
    }


    private static BRS_PicklistAdapter CreateAdapter()
    {
        BRS_PicklistGroup_F picklistGroupFactory = new BRS_PicklistGroup_F();
        BRS_FeatureSecondaryKeyExtractor secondaryKeyExtractor = new BRS_FeatureSecondaryKeyExtractor();

        return new BRS_PicklistAdapter(picklistGroupFactory, secondaryKeyExtractor);
    }
}