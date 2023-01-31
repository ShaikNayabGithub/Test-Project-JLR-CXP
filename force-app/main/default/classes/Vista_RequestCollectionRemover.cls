public class Vista_RequestCollectionRemover {
	public void RemoveByVistaOrderNumber(Set<String> keys, Vista_RequestCollection requestCollection)
	{
		for(String key : keys) {
			if(requestCollection.RecordGroups != null){
				requestCollection.RecordGroups.remove(key);
			}
			if(requestCollection.Orders != null){
				requestCollection.Orders.remove(key);
			}
			if(requestCollection.Assets != null){
				requestCollection.Assets.remove(key);
			}
			if(requestCollection.OrderItemsForDelete != null){
				requestCollection.OrderItemsForDelete.remove(key);
			}
			if(requestCollection.OrderItemsForInsert != null){
				requestCollection.OrderItemsForInsert.remove(key);
			}
		}
	}
}