@isTest(SeeAllData=true)
///Bulk tests for the BRS batch job
///Commented out tests fail with CPU timeouts, other failures should be fixed and the tests maintained
///Actual limits may be considerably lower due to callout times against the Metadata API
public class BRS_RequestProcessor_Batchable_Test {
    static Profile adminProfile = [select Id from Profile where Name = 'JLR System Administrator' limit 1];
    /*
    static testmethod void TestBatchWithSingles()
    {
        User newUser = TestClass_UserCreator.CreateUser(adminProfile);
        System.runAs(newUser){
            TestBatch(1, 1, newUser);
        }
    }

    static testmethod void TestBatchWithTwentyAndOne()
    {
        User newUser = TestClass_UserCreator.CreateUser(adminProfile);
        System.runAs(newUser){
            TestBatch(20, 1, newUser);
        }
    }

    /*static testmethod void TestBatchWithTwoHundredAndOne()
    {
        User newUser = TestClass_UserCreator.CreateUser(adminProfile);
        System.runAs(newUser){
            TestBatch(200, 1, newUser);
        }
    }*/

    /*static testmethod void TestBatchWithTwoHundredAndFive()//fails
    {
        User newUser = TestClass_UserCreator.CreateUser(adminProfile);
        System.runAs(newUser){
            TestBatch(200, 5, newUser);
        }
    }*/
/*
    static testmethod void TestBatchWithTwentyAndFive()
    {
        User newUser = TestClass_UserCreator.CreateUser(adminProfile);
        System.runAs(newUser){
            TestBatch(20, 5, newUser);
        }
    }*/

    /*static testmethod void TestBatchWithFiftyAndTen()
    {
        User newUser = TestClass_UserCreator.CreateUser(adminProfile);
        System.runAs(newUser){
            TestBatch(50, 10, newUser);
        }
    }*/

    /*static testmethod void TestBatchWithOneHundredAndTen()//fails
    {
        User newUser = TestClass_UserCreator.CreateUser(adminProfile);
        System.runAs(newUser){
            TestBatch(100, 10, newUser);
        }
    }

    static testmethod void TestBatchWithTwoHundredAndTen()//fails
    {
        User newUser = TestClass_UserCreator.CreateUser(adminProfile);
        System.runAs(newUser){
            TestBatch(200, 10, newUser);
        }
    }*/

    /*static testmethod void TestBatchWithTenAndFifty()
    {
        User newUser = TestClass_UserCreator.CreateUser(adminProfile);
        System.runAs(newUser){
            TestBatch(10, 50, newUser);
        }
    }*/

    /*static testmethod void TestBatchWithTenAndOneHundred()//fails
    {
        User newUser = TestClass_UserCreator.CreateUser(adminProfile);
        System.runAs(newUser){
            TestBatch(10, 100, newUser);
        }
    }

    static testmethod void TestBatchWithTenAndTwoHundred()//fails
    {
        User newUser = TestClass_UserCreator.CreateUser(adminProfile);
        System.runAs(newUser){
            TestBatch(10, 200, newUser);
        }
    }*/
/*
    private static void TestBatch(Integer numberToMake, Integer childMagnitudeModifier, User runningUser)
    {
        SetupTest();
        BRS_RequestProcessor_Batchable batchable = BuildBatchable(true);

        List<BRS_Request__c> requests = BuildRequests(numberToMake, childMagnitudeModifier);  
        insert requests;    

        Test.startTest();
        Database.executeBatch(batchable);
        Test.stopTest();

        Integer expectedInsertedSubtractionValue = 0;
        /*if(childMagnitudeModifier > 1 && numberToMake > childMagnitudeModifier) {
            expectedInsertedSubtractionValue = numberToMake - childMagnitudeModifier;
        }*/
/*
        Integer newProductCount = [Select Count() From Product2 where CreatedById=:runningUser.Id];
        System.AssertEquals(3*numberToMake*childMagnitudeModifier - expectedInsertedSubtractionValue, newProductCount);

        requests = [Select Status__c From BRS_Request__c Where Id IN: requests];
        for(BRS_Request__c request : requests){
            System.AssertEquals(BRSRequestUtilities.SuccessStatus, request.Status__c);
        }
    }


    static void SetupTest()
    {
        TestClass_VehicleSpecificationBuilder.BuildMake();
        TestClass_PricebookCreator.CreatePricebook('testMarket');

        List<BRS_FeatureGroupFieldMappingByCode__c> featureGroupSettings = new List<BRS_FeatureGroupFieldMappingByCode__c>();
        BRS_FeatureGroupFieldMappingByCode__c setting1 = new BRS_FeatureGroupFieldMappingByCode__c(Name='1',Field_Name__c='Body_Style');
        featureGroupSettings.Add(setting1);
        BRS_FeatureGroupFieldMappingByCode__c setting2 = new BRS_FeatureGroupFieldMappingByCode__c(Name='2',Field_Name__c='Engine');
        featureGroupSettings.Add(setting2);
        BRS_FeatureGroupFieldMappingByCode__c setting3 = new BRS_FeatureGroupFieldMappingByCode__c(Name='3',Field_Name__c='Fuel_Type');
        featureGroupSettings.Add(setting3);
        BRS_FeatureGroupFieldMappingByCode__c setting4 = new BRS_FeatureGroupFieldMappingByCode__c(Name='4',Field_Name__c='Transmission');
        featureGroupSettings.Add(setting4);
        BRS_FeatureGroupFieldMappingByCode__c setting5 = new BRS_FeatureGroupFieldMappingByCode__c(Name='5',Field_Name__c='Wheel_Base');
        featureGroupSettings.Add(setting5);
        BRS_FeatureGroupFieldMappingByCode__c setting6 = new BRS_FeatureGroupFieldMappingByCode__c(Name='6',Field_Name__c='Wheel_Driven');
        featureGroupSettings.Add(setting6);

        insert featureGroupSettings;

        ESB_ObjectRecordTypes__c esbSetting1 = new ESB_ObjectRecordTypes__c(Name='Product2.Derivative');
        Database.Insert(esbSetting1, false);
        BRSToSFLangaugeCodeMapping__c languageMapping = new BRSToSFLangaugeCodeMapping__c(Name='ENG',SF_Value__c='en_gb');
        insert languageMapping;
    }


    private static BRS_Request__c BuildBaseRequest(String name)
    {
        BRS_Request__c request = new BRS_Request__c();
        request.Name = name;
        request.Brand__c = 'Jaguar';
        request.Market_Description__c = 'testMarket';
        request.Currencies__c = '["INR"]';
        request.Status__c = 'Unprocessed';

        return request;
    }

    private static List<BRS_Request__c> BuildRequests(Integer numberToMake, Integer childMagnitudeModifier)
    {
        List<BRS_Request__c> requests = new List<BRS_Request__c>();

        for(Integer i = 0; i < numberToMake; i++) {
            String identifier = String.valueOf(i);
            BRS_Request__c request = BuildBaseRequest(identifier);
            request.Features__c = BuildFeatures(3*childMagnitudeModifier, identifier);
            request.Models__c = BuildModels(1*childMagnitudeModifier, identifier);
            request.Derivatives__c = BuildDerivatives(2*childMagnitudeModifier, identifier);
            requests.Add(request);
        }

        return requests;
    }

    private static String BuildFeatures(Integer numberToMake, String index)
    {
        List<BRS_Service.Feature> features = new List<BRS_Service.Feature>();

        for(Integer i = 0; i <= numberToMake; i++) {
            String identifier = 'BRS_RequestProcessor_Batchable_Test' + String.valueOf(i) + index;
            BRS_Service.Feature feature = new BRS_Service.Feature();
            feature.Code = identifier;
            feature.FeatureGroup= '1';
            feature.Descriptions = new List<BRS_Service.Description>();
            BRS_Service.Description description = new BRS_Service.Description();
            description.Language = 'ENG';
            description.Text = identifier;
            feature.Descriptions.Add(description);
            features.Add(feature);
        }

        return JSON.serialize(features);
    }

    private static String BuildModels(Integer numberToMake, String index)
    {
        List<BRS_Service.Model> models = new List<BRS_Service.Model>();

        for(Integer i = 0; i < numberToMake; i++) {
            String identifier = 'BRS_RequestProcessor_Batchable_Test' + String.valueOf(i) + index;
            BRS_Service.Model model = new BRS_Service.Model();
            model.Code = identifier;
            model.Description = identifier;
            models.Add(model);
        }

        return JSON.serialize(models);
    }

    private static String BuildDerivatives(Integer numberToMake, String index)
    {
        List<BRS_Service.Derivative> derivatives = new List<BRS_Service.Derivative>();

        for(Integer i = 0; i < numberToMake; i++) {
            String identifier = 'BRS_RequestProcessor_Batchable_Test' + String.valueOf(i) + index;
            BRS_Service.Derivative derivative = new BRS_Service.Derivative();
            derivative.DescriptionGroupId = identifier;
            derivative.ModelCode = 'BRS_RequestProcessor_Batchable_Test' + String.valueOf((i+1)/2);
            derivative.Name = identifier;
            derivatives.Add(derivative);
        }

        return JSON.serialize(derivatives);
    }

    private static BRS_RequestProcessor_Batchable BuildBatchable(Boolean calloutIsSuccessfull)
    {
        JSONDeserializer deserializer = new JSONDeserializer();

        SF_MetadataAPI.MetadataPort metadataPort = new DummyPort(calloutIsSuccessfull);
        metadataPort.SessionHeader = new SF_MetadataAPI.SessionHeader_element();
        BRS_PicklistGroup_F picklistGroupFactory = new BRS_PicklistGroup_F();
        BRS_TranslationGroup_F translationGroupFactory = new BRS_TranslationGroup_F();
        BRS_FeatureSecondaryKeyExtractor secondaryKeyExtractor = new BRS_FeatureSecondaryKeyExtractor();

        BRS_FeatureExtractor featureExtractor = new BRS_FeatureExtractor(deserializer);
        BRS_PicklistAdapter picklistAdapter = new BRS_PicklistAdapter(picklistGroupFactory, secondaryKeyExtractor);
        BRS_TranslationAdapter translationAdapter = new BRS_TranslationAdapter(translationGroupFactory, secondaryKeyExtractor);
        BRS_RecordTypeAdapter recordTypeAdapter = new BRS_RecordTypeAdapter();
        BRS_MetadataUpserter metadataUpserter = new BRS_MetadataUpserter(metadataPort);


        BRS_FeatureCreator featureCreator = new BRS_FeatureCreator(featureExtractor, picklistAdapter, translationAdapter, recordTypeAdapter, metadataUpserter);

        BRS_ProductCreator_Factory productCreatorFactory = new BRS_ProductCreator_Factory();
        BRS_ProductCreator productCreator = productCreatorFactory.Build();
        BRS_RequestPostProcessor requestPostProcessor = new BRS_RequestPostProcessor();

        return new BRS_RequestProcessor_Batchable(featureCreator, productCreator, requestPostProcessor);
    }


    private class DummyPort extends SF_MetadataAPI.MetadataPort
    {
        private Boolean isSuccessful;


        public DummyPort(Boolean isSuccessful)
        {
            this.isSuccessful = isSuccessful;
        }


        public override SF_MetadataAPI.UpsertResult[] upsertMetadata(SF_MetadataAPI.Metadata[] metadataCollection) {
            List<SF_MetadataAPI.UpsertResult> results = new List<SF_MetadataAPI.UpsertResult>();

            for(SF_MetadataAPI.Metadata metadata : metadataCollection){
                SF_MetadataAPI.UpsertResult result = new SF_MetadataAPI.UpsertResult();
                result.success = isSuccessful;
                result.errors = new List<SF_MetadataAPI.Error>();
                SF_MetadataAPI.Error resultException = new SF_MetadataAPI.Error();
                resultException.message = 'exception';
                result.errors.Add(resultException);
                results.Add(result);
            }

            return results;
        }
    }*/
}