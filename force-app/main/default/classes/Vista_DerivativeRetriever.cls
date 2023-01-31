public class Vista_DerivativeRetriever implements Vista_EntityRetriever_I {
	public void Retrieve(Vista_RequestCollection requestCollection)
	{
		if(requestCollection.Derivatives == null) {
			requestCollection.Derivatives = new Map<String, Product2>();
		}

		Set<String> productCodes = new Set<String>();
		for(List<Vista_RecordGroup> recordGroupList : requestCollection.RecordGroups.values()) {
			for(Vista_RecordGroup recordGroup : recordGroupList) {
				productCodes.add(recordGroup.VistaVehicleOrder.Specification.DescriptionGroupId);
			}
		}

		for(Product2 derivative : [SELECT Id, ProductCode, Description, Make__c, Model__c, Body_style__c, Engine__c, 
				Wheel_Base__c, Wheel_Driven__c, Exterior_Colour__c, Transmission__c, Model__r.Model_Colours__c
				FROM Product2 WHERE ProductCode IN: productCodes]) {
			requestCollection.Derivatives.put(derivative.ProductCode, derivative);
		}
	}
}