@isTest
public class BRS_DerivativeToProduct_Adapter_Test {
    static testmethod void Convert_ReturnsEmptyList_GivenNoDerivatives()
    {
    	BRS_DerivativeToProduct_Adapter adapter = new BRS_DerivativeToProduct_Adapter();
    	
    	BRS_Request__c request = new BRS_Request__c();
        Map<String, Product2> productByProductCodeMap = new Map<String, Product2>();
    	
    	List<Product2> products = adapter.Convert(request, productByProductCodeMap);
    	
    	System.assertEquals(0, products.Size());
    }
    
    static testmethod void Convert_ReturnsModelTwo_GivenDerivativeOneAndDerivativeTwo()
    {
    	String productCode2 = '2';
    	BRS_DerivativeToProduct_Adapter adapter = new BRS_DerivativeToProduct_Adapter();
    	    	
        Map<String, Product2> productByProductCodeMap = new Map<String, Product2>();
    	BRS_Request__c request = new BRS_Request__c();
    	request.Brand__c = 'Jaguar';
    	request.Derivatives__c = '[{"WheelDriven":null,"WheelBase":null,"Transmission":null,"Name":"t1","ModelCode":null,"Language":null,"FuelType":null,"Engine":null,"DescriptionGroupId":null,"Colour":null,"BrochureModel":null,"BodyStyle":null},{"WheelDriven":null,"WheelBase":null,"Transmission":null,"Name":"t1","ModelCode":null,"Language":null,"FuelType":null,"Engine":null,"DescriptionGroupId":"'+productCode2+'","Colour":null,"BrochureModel":null,"BodyStyle":null}]';
    	
    	List<Product2> products = adapter.Convert(request, productByProductCodeMap);
    	
    	System.assertEquals(productCode2, products[1].ProductCode);
    }
    
    static testmethod void Convert_ReturnsDerivativeOne_GivenDerivativeOneAndDerivativeTwo()
    {
    	String productCode = '1';
    	BRS_DerivativeToProduct_Adapter adapter = new BRS_DerivativeToProduct_Adapter();
    	
        Map<String, Product2> productByProductCodeMap = new Map<String, Product2>();
    	BRS_Request__c request = new BRS_Request__c();
    	request.Brand__c = 'Jaguar';
    	request.Derivatives__c = '[{"WheelDriven":null,"WheelBase":null,"Transmission":null,"Name":"t1","ModelCode":null,"Language":null,"FuelType":null,"Engine":null,"DescriptionGroupId":"'+productCode+'","Colour":null,"BrochureModel":null,"BodyStyle":null},{"WheelDriven":null,"WheelBase":null,"Transmission":null,"Name":"t1","ModelCode":null,"Language":null,"FuelType":null,"Engine":null,"DescriptionGroupId":null,"Colour":null,"BrochureModel":null,"BodyStyle":null}]';
    	
    	List<Product2> products = adapter.Convert(request, productByProductCodeMap);
    	
    	System.assertEquals(productCode, products[0].ProductCode);
    }
    
    static testmethod void Convert_ReturnsModelTwoWithRecordTypeDerivative_GivenDerivativeOneAndDerivativeTwo()
    {
    	BRS_DerivativeToProduct_Adapter adapter = new BRS_DerivativeToProduct_Adapter();
    	    	
        Map<String, Product2> productByProductCodeMap = new Map<String, Product2>();
    	BRS_Request__c request = new BRS_Request__c();
    	request.Brand__c = 'Jaguar';
    	request.Derivatives__c = '[{"WheelDriven":null,"WheelBase":null,"Transmission":null,"Name":"t1","ModelCode":null,"Language":null,"FuelType":null,"Engine":null,"DescriptionGroupId":null,"Colour":null,"BrochureModel":null,"BodyStyle":null},{"WheelDriven":null,"WheelBase":null,"Transmission":null,"Name":"t1","ModelCode":null,"Language":null,"FuelType":null,"Engine":null,"DescriptionGroupId":null,"Colour":null,"BrochureModel":null,"BodyStyle":null}]';
    	
    	List<Product2> products = adapter.Convert(request, productByProductCodeMap);
    	
    	System.assertEquals(ProductUtilities.RecordTypes.get('Derivative').Id, products[1].RecordTypeId);
    }
    
    static testmethod void Convert_ReturnsDerivativeTwoWithNameNameTwo_GivenDerivativeOneAndDerivativeTwo()
    {
    	String productName = 'name2';
    	BRS_DerivativeToProduct_Adapter adapter = new BRS_DerivativeToProduct_Adapter();
    	
        Map<String, Product2> productByProductCodeMap = new Map<String, Product2>();
    	BRS_Request__c request = new BRS_Request__c();
    	request.Brand__c = 'Jaguar';
    	request.Derivatives__c = '[{"WheelDriven":null,"WheelBase":null,"Transmission":null,"Name":"t1","ModelCode":null,"Language":null,"FuelType":null,"Engine":null,"DescriptionGroupId":null,"Colour":null,"BrochureModel":null,"BodyStyle":null},{"WheelDriven":null,"WheelBase":null,"Transmission":null,"Name":"'+productName+'","ModelCode":null,"Language":null,"FuelType":null,"Engine":null,"DescriptionGroupId":2,"Colour":null,"BrochureModel":null,"BodyStyle":null}]';
    	
    	List<Product2> products = adapter.Convert(request, productByProductCodeMap);
    	
    	System.assertEquals(productName, products[1].Name);
    }
    
    
    @testSetup
	static void SetupTests() 
	{
		TestClass_VehicleSpecificationBuilder.BuildMake();
		VehicleSpecificationUtilities.SetBrandMap();
	}
}