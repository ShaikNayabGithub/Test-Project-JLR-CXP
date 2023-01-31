@isTest
public class ProductDuplicateChecker_Test {
    
    static testMethod void ProductDuplicateChecker_AllowsProductInsert_WithNullProductCode()
    {
        Product2 newProduct = new Product2(Name = 'TestProduct');
        insert newProduct;
        
        system.assertNotEquals(null, newProduct.Id);
    }
    
    static testMethod void ProductDuplicateChecker_AddsError_GivenProductWithDuplicateCode()
    {
        Product2 newProduct = new Product2(Name = 'TestProduct', ProductCode = 'productcode');
        insert newProduct;
        Product2 duplicateProduct = new Product2(Name = 'TestProduct2', ProductCode = 'productcode');
        
        try
        {
            insert duplicateProduct;
        }
        catch(Exception e)
        {
            system.assert(e.getMessage().contains('Duplicate Product Code'));
        }
    }
    
    static testMethod void ProductDuplicateChecker_AllowsInsert_GivenProductWithNoneDuplicateCode()
    {
        Product2 newProduct = new Product2(Name = 'TestProduct', ProductCode = 'productcode');
        insert newProduct;
        Product2 duplicateProduct = new Product2(Name = 'TestProduct2', ProductCode = 'productcode2');
        try
        {
            insert duplicateProduct;
        }
        catch(Exception e)
        {
        }
        system.assertNotEquals(null, duplicateProduct.Id);
    }
}