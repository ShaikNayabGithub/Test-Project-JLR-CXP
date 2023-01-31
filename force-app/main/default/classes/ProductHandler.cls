public class ProductHandler {
    
    public void PreCreate(List<Product2> newProducts)
    {
        ProductDuplicateChecker duplicateChecker = new ProductDuplicateChecker();
        duplicateChecker.CheckProductDuplicates(newProducts);
        ProductDerivativeDetailPopulater.PopulateDerivativeDetails(newProducts, null);
    }
    
    public void PreUpdate(List<Product2> newProducts, Map<Id, Product2> oldProductMap)
    {
        ProductDerivativeDetailPopulater.PopulateDerivativeDetails(newProducts, oldProductMap);
    }

}