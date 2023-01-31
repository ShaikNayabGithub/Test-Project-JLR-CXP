@isTest
public class ProductMatcher_Test {
    static testmethod void MatchExisting_DoesNotSetId_GivenNonExistingProduct()
    {
    	ProductMatcher productMatcher = new ProductMatcher();
    	
    	Product2 product = new Product2(Name='test', ProductCode='12345678', RecordTypeId=ProductUtilities.RecordTypes.get('Derivative').Id);
    	
    	productMatcher.MatchExisting(new List<Product2>{ product });
    	
    	System.Assert(String.isBlank(product.Id));
    }
    
    static testmethod void MatchExisting_SetsId_GivenExistingProduct()
    {
    	ProductMatcher productMatcher = new ProductMatcher();
    	
    	Product2 product = new Product2(Name='test', ProductCode='12345678', RecordTypeId=ProductUtilities.RecordTypes.get('Derivative').Id);
    	insert product;
    	product.Id = null;
    	
    	productMatcher.MatchExisting(new List<Product2>{ product });
    	
    	System.Assert(String.isNotBlank(product.Id));
    }
}