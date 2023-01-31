@isTest(SeeAllData=true)
public class BRS_PricebookEntryCreator_Test {
    static testmethod void Create_DoesNothing_GivenEmptyMap()
    {
    	BRS_PricebookEntryCreator pricebookEntryCreator = BuildSubject();
    	
    	BRS_RequestCollection requestCollection = new BRS_RequestCollection();
        requestCollection.Requests = new Map<Id, BRS_Request__c>();
    	
    	pricebookEntryCreator.Create(requestCollection);
    	
    	System.AssertEquals(0, requestCollection.ProductByProductCode.Size());	
    }
    
    static testmethod void Create_InsertsPricebookEntry_GivenProduct()
    {
    	insert new PriceBook2(Name='test');
    	BRS_PricebookEntryCreator pricebookEntryCreator = BuildSubject();

        String productCode1 = 'p1';
    	
    	BRS_RequestCollection requestCollection = new BRS_RequestCollection();
        requestCollection.Requests = new Map<Id, BRS_Request__c>();

    	BRS_Request__c request = BuildRequest();
        requestCollection.Requests.put(request.Id, request);

    	Vehicle_Specification__c make = TestClass_VehicleSpecificationBuilder.BuildMake();
    	Product2 product = TestClass_ProductBuilder.BuildModel(make);
        product.ProductCode = productCode1;
        requestCollection.ProductByProductCode.put(productCode1, product);
        requestCollection.RequestsByProductCode.put(productCode1, new List<BRS_Request__c> { request });
    	
    	pricebookEntryCreator.Create(requestCollection);
    	
    	Integer pricebookEntriesCount = [Select Count() From PricebookEntry Where Product2Id =: product.Id];
    	System.AssertEquals(2, pricebookEntriesCount);	
    }
    
    
    private static BRS_Request__c BuildRequest()
    {
    	BRS_Request__c request = new BRS_Request__c();
    	request.Market_Description__c = 'test';
    	request.Currencies__c = '["INR"]';
        insert request;
    	return request;
    }
    
    private static BRS_PricebookEntryCreator BuildSubject()
    {
    	BRS_EnhancedUpserter upserter = new BRS_EnhancedUpserter();
    	JSONDeserializer deserializer = new JSONDeserializer();
    	return new BRS_PricebookEntryCreator(upserter, deserializer);
    }
}