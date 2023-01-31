@isTest
public class BRS_FeatureSecondaryKeyExtractor_T {
	static testmethod void GetPicklistKey_ReturnsFeatureCode_GivenMappingDoesNotExist()
    {
    	BRS_FeatureSecondaryKeyExtractor extractor = new BRS_FeatureSecondaryKeyExtractor();

    	String code1 = 'c1';

    	BRS_Service.Feature feature = new BRS_Service.Feature();
    	feature.Code = code1;


    	String result = extractor.GetPicklistKey(feature);


    	System.assertEquals(code1, result);
    }

    static testmethod void GetPicklistKey_ReturnsFeatureCode_GivenMappingIsNotLocal()
    {
    	BRS_FeatureSecondaryKeyExtractor extractor = new BRS_FeatureSecondaryKeyExtractor();

    	String code1 = 'c1';
    	String featureGroup1 = 'fg1';

    	BRS_FeatureGroupFieldMappingByCode__c mapping = new BRS_FeatureGroupFieldMappingByCode__c(
    			Name = featureGroup1);
    	insert mapping;

    	BRS_Service.Feature feature = new BRS_Service.Feature();
    	feature.Code = code1;
    	feature.FeatureGroup = featureGroup1;


    	String result = extractor.GetPicklistKey(feature);


    	System.assertEquals(code1, result);
    }

    static testmethod void GetPicklistKey_ReturnsFeatureESText_GivenMappingIsLocalAndFeatureOnlyHasESText()
    {
    	BRS_FeatureSecondaryKeyExtractor extractor = new BRS_FeatureSecondaryKeyExtractor();

    	String code1 = 'c1';
    	String spanishColour = 'spanishColour';
    	String featureGroup1 = 'fg1';

    	BRS_FeatureGroupFieldMappingByCode__c mapping = new BRS_FeatureGroupFieldMappingByCode__c(
    			Name = featureGroup1,
    			Is_Local__c = true);
    	insert mapping;

    	BRS_Service.Feature feature = new BRS_Service.Feature();
    	feature.Code = code1;
    	feature.FeatureGroup = featureGroup1;
    	BRS_Service.Description esDescription = new BRS_Service.Description();
    	esDescription.Text = spanishColour;
    	esDescription.Language = 'ES';
    	feature.Descriptions = new List<BRS_Service.Description>{ esDescription };


    	String result = extractor.GetPicklistKey(feature);


    	System.assertEquals(spanishColour, result);
    }

    static testmethod void GetPicklistKey_ReturnsFeatureENText_GivenMappingIsLocalAndFeatureHasFR_EN_ESText()
    {
    	BRS_FeatureSecondaryKeyExtractor extractor = new BRS_FeatureSecondaryKeyExtractor();

    	String code1 = 'c1';
    	String spanishColour = 'spanishColour';
    	String englishColour = 'englishColour';
    	String frenchColour = 'frenchColour';
    	String featureGroup1 = 'fg1';

    	BRS_FeatureGroupFieldMappingByCode__c mapping = new BRS_FeatureGroupFieldMappingByCode__c(
    			Name = featureGroup1,
    			Is_Local__c = true);
    	insert mapping;

    	BRS_Service.Feature feature = new BRS_Service.Feature();
    	feature.Code = code1;
    	feature.FeatureGroup = featureGroup1;
    	BRS_Service.Description frDescription = new BRS_Service.Description();
    	frDescription.Text = frenchColour;
    	frDescription.Language = 'FR';
    	BRS_Service.Description enDescription = new BRS_Service.Description();
    	enDescription.Text = englishColour;
    	enDescription.Language = 'EN';
    	BRS_Service.Description esDescription = new BRS_Service.Description();
    	esDescription.Text = spanishColour;
    	esDescription.Language = 'ES';
    	feature.Descriptions = new List<BRS_Service.Description>{ frDescription, enDescription, esDescription };


    	String result = extractor.GetPicklistKey(feature);


    	System.assertEquals(englishColour, result);
    }
}