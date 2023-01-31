public class BRS_ProductRecordTypeSpecificCreator {
	private final BRS_Product_Adapter_I adapter;
	private final ProductMatcher productMatcher;
	private final BRS_EnhancedUpserter upserter;

	
	public BRS_ProductRecordTypeSpecificCreator(BRS_Product_Adapter_I adapter, ProductMatcher productMatcher, BRS_EnhancedUpserter upserter)
	{
		this.adapter = adapter;
		this.productMatcher = productMatcher;
		this.upserter = upserter;
	}


    public void Create(BRS_RequestCollection requestCollection)
    {
        Map<Id, List<Product2>> productsByRequestId = new Map<Id, List<Product2>>();
        
        for(BRS_Request__c request : requestCollection.Requests.Values()){
            List<Product2> products = this.adapter.Convert(request, requestCollection.ProductByProductCode);

            List<Product2> requestProducts = productsByRequestId.get(request.Id);
            if(requestProducts == null) {
                requestProducts = new List<Product2> ();
                productsByRequestId.put(request.Id, requestProducts);
            }

            for(Product2 product : products) {
                if(!requestCollection.ProductByProductCode.containsKey(product.ProductCode)) {
                    requestCollection.ProductByProductCode.Put(product.ProductCode, product);
                    requestProducts.add(product);
                }
                

                List<BRS_Request__c> productCodeRequests = requestCollection.RequestsByProductCode.get(product.ProductCode);
                if(productCodeRequests == null) {
                    productCodeRequests = new List<BRS_Request__c>();
                    requestCollection.RequestsByProductCode.Put(product.ProductCode, productCodeRequests);
                }

                productCodeRequests.add(request);
            }
        }


        Map<String, Product2> productsToUpsertByCode = new Map<String, Product2>();
        Map<Integer, List<BRS_Request__c>> requestsByIndex = new Map<Integer, List<BRS_Request__c>>();
        Integer index = -1;

        for(Id requestId : productsByRequestId.keySet()) {
            List<Product2> subList = productsByRequestId.get(requestId);
            if(subList == null) continue;

            for(Product2 upsertRecord : subList) {
                if(!productsToUpsertByCode.containsKey(upsertRecord.ProductCode)) {
                    index++;
                    productsToUpsertByCode.put(upsertRecord.ProductCode, upsertRecord);
                }
                List<BRS_Request__c> productRequests = requestsByIndex.get(index);
                if(productRequests == null) {
                    productRequests = new List<BRS_Request__c>();
                    requestsByIndex.put(index, productRequests);
                }
                productRequests.add(requestCollection.Requests.get(requestId));
            }
        }

        
        this.productMatcher.MatchExisting(productsToUpsertByCode);
        this.upserter.UpsertRecords(productsToUpsertByCode.values(), requestsByIndex);
    }
}