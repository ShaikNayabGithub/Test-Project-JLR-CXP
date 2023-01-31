public class ProductMatcher {
    public void MatchExisting(List<Product2> products)
    {
    	Set<String> productCodes = SObjectUtilities.GetFieldValues(products, ProductUtilities.ProductCodeFieldName);
        Set<String> recordTypes = SObjectUtilities.GetFieldValues(products, ProductUtilities.RecordTypeIdFieldName);
        
        List<Product2> existingProducts = [Select ProductCode, RecordTypeId From Product2 Where ProductCode IN: productCodes AND RecordTypeId IN: recordTypes];
        
        List<String> fieldsToMatch = new List<String> { ProductUtilities.ProductCodeFieldName, ProductUtilities.RecordTypeIdFieldName };
        Map<SObject, SObject> matchedMap = SObjectMatcher.Match(new List<Product2>(products), existingProducts, fieldsToMatch);
        
        for(Product2 product : products) {
            SObject matchedRecord = matchedMap.get(product);
            if(matchedRecord != null) {
                product.Id = matchedRecord.Id;
            }
        }
    }

    public void MatchExisting(Map<String, Product2> productsByCode)
    {
        Set<String> productCodes = SObjectUtilities.GetFieldValues(productsByCode.values(), ProductUtilities.ProductCodeFieldName);
        Set<String> recordTypes = SObjectUtilities.GetFieldValues(productsByCode.values(), ProductUtilities.RecordTypeIdFieldName);
        
        List<Product2> existingProducts = [Select ProductCode, RecordTypeId From Product2 Where ProductCode IN: productCodes AND RecordTypeId IN: recordTypes];
        
        for(Product2 product : existingProducts) {
            Product2 matchedProduct = productsByCode.get(product.ProductCode);
            if(matchedProduct != null) {
                matchedProduct.Id = product.Id;
            }
        }
    }
}