@isTest
public with sharing class TestClass_ProductOptionMapping {
    
    public static Product_Option_Mapping__c buildProductOptionMapping(Product2 product, Product2 option, Boolean isMandatory, Decimal priceOverride) {
        Product_Option_Mapping__c pom = new Product_Option_Mapping__c();
        pom.Product__c = product.Id;
        pom.Option__c = option.Id;
        pom.Market_Standard_Required__c = isMandatory;
        pom.Option_Derivative_Price_Override__c = priceOverride;

        return pom;
    }
}