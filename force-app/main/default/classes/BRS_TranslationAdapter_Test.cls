@isTest
public class BRS_TranslationAdapter_Test {
    static testmethod void Adapt_ReturnsEmptyMap_GivenMap()
    {
    	BRS_TranslationAdapter adapter = CreateAdapter();
    	
    	Map<BRS_Service.Feature, BRS_Request__c> features = new Map<BRS_Service.Feature, BRS_Request__c>();
    	
    	Map<String, BRS_TranslationGroup_A> results = adapter.Adapt(features);
    	
    	System.AssertEquals(0, results.Size());
    }
    
    static testmethod void Adapt_ReturnsTranslationGroupOneWithValueTwo_GivenFeatureGroupOneAndCodeTwo()
    {
    	String featureCode = '2';
    	String featureGroup = '1';
    	String featureGroupField = 'Wheel_Driven__c';
    	String language = 'IN';
    	BRS_FeatureGroupFieldMappingByCode__c setting = new BRS_FeatureGroupFieldMappingByCode__c(Name=featureGroup,Field_Name__c=featureGroupField);
    	insert setting;
    	BRSToSFLangaugeCodeMapping__c languageMapping = new BRSToSFLangaugeCodeMapping__c(Name=language,SF_Value__c=language);
    	insert languageMapping;
    	
    	BRS_TranslationAdapter adapter = CreateAdapter();
    	
    	Map<BRS_Service.Feature, BRS_Request__c> features = new Map<BRS_Service.Feature, BRS_Request__c>();
    	BRS_Service.Feature feature = new BRS_Service.Feature();
    	feature.code = featureCode;
    	feature.FeatureGroup = featureGroup;
    	feature.Descriptions = new List<BRS_Service.Description>();
    	BRS_Service.Description description = new BRS_Service.Description();
    	description.Language = language;
    	description.Text = 'translation';
    	feature.Descriptions.Add(description);
    	BRS_Request__c request = new BRS_Request__c();
    	features.put(feature, request);
    	
    	Map<String, BRS_TranslationGroup_A> results = adapter.Adapt(features);
    	
    	System.AssertEquals(featureCode, ((BRS_TranslationGroup_Global)results.get(language + setting.Is_Local__c)).Translations.globalPicklists[0].picklistValues[0].masterLabel);
    }
    
    static testmethod void Adapt_ReturnsTranslationGroupOneWithValueTwoAndTranslationThree_GivenFeatureGroupOneAndCodeTwoAndTranslationThree()
    {
    	String featureCode = '2';
    	String featureGroup = '1';
    	String featureGroupField = 'Wheel_Driven__c';
    	String language = 'IN';
    	String translation = '3';
    	BRS_FeatureGroupFieldMappingByCode__c setting = new BRS_FeatureGroupFieldMappingByCode__c(Name=featureGroup,Field_Name__c=featureGroupField);
    	insert setting;
    	BRSToSFLangaugeCodeMapping__c languageMapping = new BRSToSFLangaugeCodeMapping__c(Name=language,SF_Value__c=language);
    	insert languageMapping;
    	
    	BRS_TranslationAdapter adapter = CreateAdapter();
    	
    	Map<BRS_Service.Feature, BRS_Request__c> features = new Map<BRS_Service.Feature, BRS_Request__c>();
    	BRS_Service.Feature feature = new BRS_Service.Feature();
    	feature.code = featureCode;
    	feature.FeatureGroup = featureGroup;
    	feature.Descriptions = new List<BRS_Service.Description>();
    	BRS_Service.Description description = new BRS_Service.Description();
    	description.Language = language;
    	description.Text = translation;
    	feature.Descriptions.Add(description);
    	BRS_Request__c request = new BRS_Request__c();
    	features.put(feature, request);
    	
    	Map<String, BRS_TranslationGroup_A> results = adapter.Adapt(features);
    	
    	System.AssertEquals(translation, ((BRS_TranslationGroup_Global)results.get(language + setting.Is_Local__c)).Translations.globalPicklists[0].picklistValues[0].translation);
    }


    private static BRS_TranslationAdapter CreateAdapter()
    {
        BRS_TranslationGroup_F translationGroupFactory = new BRS_TranslationGroup_F();
        BRS_FeatureSecondaryKeyExtractor secondaryKeyExtractor = new BRS_FeatureSecondaryKeyExtractor();

        return new BRS_TranslationAdapter(translationGroupFactory, secondaryKeyExtractor);
    }
}