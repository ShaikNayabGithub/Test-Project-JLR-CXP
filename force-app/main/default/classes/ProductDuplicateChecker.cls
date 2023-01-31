public class ProductDuplicateChecker {
    
    public void CheckProductDuplicates(List<Product2> newProducts)
    {
        Set<string> productCodes = new Set<string>();
        Map<string, Product2> productsMappedToProductCodes = new Map<string, Product2>();
        for(Product2 newProd : newProducts)
        {
            if(newProd.ProductCode != null)
            {
                productCodes.add(newProd.ProductCode);
           		productsMappedToProductCodes.put(newProd.ProductCode, newProd);
            }
        }
        if(!productCodes.isEmpty())
        {
            List<Product2> existingProducts = [SELECT Id, ProductCode FROM Product2 WHERE ProductCode In: productCodes];
            if(!existingProducts.isEmpty())
            {
                for(Product2 existingProd : existingProducts)
                {
                    Product2 newProduct = productsMappedToProductCodes.get(existingProd.ProductCode);
                    newProduct.addError('Duplicate Product Code Entered');
                }
            }
        } 
    }
}