public class BRS_DerivativeToProduct_Adapter implements BRS_Product_Adapter_I{
	private final JSONDeserializer deserializer = new JSONDeserializer();
	
	private static final Id RecordTypeId = ProductUtilities.RecordTypes.get('Derivative').Id;
	
	
    public List<Product2> Convert(BRS_Request__c request, Map<String, Product2> productByProductCodeMap) 
    {
    	List<Product2> products = new List<Product2>();
    	
    	List<BRS_Service.Derivative> derivatives = (List<BRS_Service.Derivative>)this.deserializer.DeserializeSingle(request.Derivatives__c, BRS_Service.DerivativeListType);
    	
    	for(BRS_Service.Derivative derivative : derivatives){
    		Product2 product = BuildProduct(request.Brand__c, derivative);
    		if(String.IsNotEmpty(product.Name)) {
    			products.add(product);
    		}
    	}
    	system.debug(products);
    	return products;
    }
    
    
    private Product2 BuildProduct(String brandName, BRS_Service.Derivative derivative)
    {
    	Vehicle_Specification__c brand = VehicleSpecificationUtilities.Brands.get(brandName.toLowerCase());

		Product2 model = ProductUtilities.ModelsByCode.get(derivative.ModelCode);
		//Product2 brochureModel = ProductUtilities.ModelsByCode.get(derivative.BrochureModel);
		
		if(brand == null) { return new Product2(); }
		
		Product2 product = new Product2(RecordTypeId=RecordTypeId,
			Name=derivative.Name,
			ProductCode=derivative.DescriptionGroupId,
			Make__c=brand.Id,
			Body_Style__c=derivative.BodyStyle,
			Engine__c=derivative.Engine,
			Wheel_Base__c=derivative.WheelBase,
			Transmission__c=derivative.Transmission,
			Wheel_Driven__c=derivative.WheelDriven,
			Brochure_Model__c=derivative.BrochureModel);
			
		if(model != null && String.isNotEmpty(model.Id)){
			product.Model__c=model.Id;
		}
		//if(brochureModel != null && String.isNotEmpty(brochureModel.Id)){
			//product.Brochure_Model__c=brochureModel.Id;
		//}
		
		return product;
    }
}