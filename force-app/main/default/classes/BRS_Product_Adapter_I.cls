public interface BRS_Product_Adapter_I {
    List<Product2> Convert(BRS_Request__c request, Map<String, Product2> productByProductCodeMap);
}