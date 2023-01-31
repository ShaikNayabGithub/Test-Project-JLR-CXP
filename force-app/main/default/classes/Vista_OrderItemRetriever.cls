public class Vista_OrderItemRetriever implements Vista_EntityRetriever_I {
	public void Retrieve(Vista_RequestCollection requestCollection)
	{
		if(requestCollection.OrderItemsForInsert == null) {
			requestCollection.OrderItemsForInsert = new Map<String, OrderItem>();
		}
		
		for(OrderItem orderItem : [SELECT Id, PricebookEntry.ProductCode, Order.Vista_Order_Number__c
				FROM OrderItem 
				WHERE Order.Vista_Order_Number__c IN: requestCollection.RecordGroups.keySet()]) {
			requestCollection.OrderItemsForInsert.put(orderItem.Order.Vista_Order_Number__c, orderItem);
		}
	}
}