@isTest
public class BRS_ModelToProduct_Adapter_Test {
	static testmethod void Convert_ReturnsEmptyList_GivenNoModels()
    {
    	BRS_ModelToProduct_Adapter adapter = CreateAdapter();
    	
    	Vehicle_Specification__c make = TestClass_VehicleSpecificationBuilder.BuildMake();
    	
        Map<String, Product2> productByProductCodeMap = new Map<String, Product2>();
    	BRS_Request__c request = new BRS_Request__c();
    	request.Brand__c = make.Name;
    	
    	List<Product2> products = adapter.Convert(request, productByProductCodeMap);
    	
    	System.assertEquals(0, products.Size());
    }
    
    static testmethod void Convert_ReturnsModelTwo_GivenModelOneAndModelTwo()
    {
    	String productCode2 = '2';
    	BRS_ModelToProduct_Adapter adapter = CreateAdapter();
    	
    	Vehicle_Specification__c make = TestClass_VehicleSpecificationBuilder.BuildMake();
    	
        Map<String, Product2> productByProductCodeMap = new Map<String, Product2>();
    	BRS_Request__c request = new BRS_Request__c();
    	request.Brand__c = make.Name;
    	request.Models__c = '[{"Description":"name1","Code":"1"},{"Description":"name2","Code":"'+productCode2+'"}]';
    	
    	List<Product2> products = adapter.Convert(request, productByProductCodeMap);
    	
    	System.assertEquals(productCode2, products[1].ProductCode);
    }
    
    static testmethod void Convert_ReturnsModelOne_GivenModelOneAndModelTwo()
    {
    	String productCode = '1';
    	BRS_ModelToProduct_Adapter adapter = CreateAdapter();
    	
    	Vehicle_Specification__c make = TestClass_VehicleSpecificationBuilder.BuildMake();
    	
        Map<String, Product2> productByProductCodeMap = new Map<String, Product2>();
    	BRS_Request__c request = new BRS_Request__c();
    	request.Brand__c = make.Name;
    	request.Models__c = '[{"Description":"name1","Code":"'+productCode+'"},{"Description":"name2","Code":"2"}]';
    	
    	List<Product2> products = adapter.Convert(request, productByProductCodeMap);
    	
    	System.assertEquals(productCode, products[0].ProductCode);
    }
    
    static testmethod void Convert_ReturnsModelTwoWithRecordTypeModel_GivenModelOneAndModelTwo()
    {
    	BRS_ModelToProduct_Adapter adapter = CreateAdapter();
    	
    	Vehicle_Specification__c make = TestClass_VehicleSpecificationBuilder.BuildMake();
    	
        Map<String, Product2> productByProductCodeMap = new Map<String, Product2>();
    	BRS_Request__c request = new BRS_Request__c();
    	request.Brand__c = make.Name;
    	request.Models__c = '[{"Description":"name1","Code":"1"},{"Description":"name2","Code":"2"}]';
    	
    	List<Product2> products = adapter.Convert(request, productByProductCodeMap);
    	
    	System.assertEquals(ProductUtilities.RecordTypes.get('Model').Id, products[1].RecordTypeId);
    }
    
    static testmethod void Convert_ReturnsModelTwoWithNameNameTwo_GivenModelOneAndModelTwo()
    {
    	String productName = 'name2';
    	BRS_ModelToProduct_Adapter adapter = CreateAdapter();
    	
    	Vehicle_Specification__c make = TestClass_VehicleSpecificationBuilder.BuildMake();
    	
        Map<String, Product2> productByProductCodeMap = new Map<String, Product2>();
        productByProductCodeMap.put('2',new Product2(name='Test', Model_Colours__c= '[{"Key":"1AA","Value":"Fuji White","LanguageCode":"EN"}]' ));
    	BRS_Request__c request = new BRS_Request__c();
    	request.Brand__c = make.Name;
    	request.Models__c = '[{"Description":"name1","Code":"1"},{"Description":"'+productName+'","Code":"2"}]';
    	
    	List<Product2> products = adapter.Convert(request, productByProductCodeMap);
    	
    	System.assertEquals(productName, products[1].Name);
    }


    private static BRS_ModelToProduct_Adapter CreateAdapter()
    {
        JSONDeserializer deserializer = new JSONDeserializer();
        BRS_FeatureSecondaryKeyExtractor secondaryKeyExtractor = new BRS_FeatureSecondaryKeyExtractor();

        return new BRS_ModelToProduct_Adapter(deserializer, secondaryKeyExtractor);
    }
}