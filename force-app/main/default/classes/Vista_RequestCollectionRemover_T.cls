@isTest
public class Vista_RequestCollectionRemover_T {
	static testmethod void RemoveByVistaOrderNumber_DoesNothing_GivenEmptySet()
	{
		Vista_RequestCollectionRemover collectionRemover = new Vista_RequestCollectionRemover();

		Set<String> keys = new Set<String>();
		Vista_RequestCollection requestCollection = new Vista_RequestCollection();

		collectionRemover.RemoveByVistaOrderNumber(keys, requestCollection);

		System.assert(true);
	}

	static testmethod void RemoveByVistaOrderNumber_RemovesRecordGroupK1_GivenK1()
	{
		Vista_RequestCollectionRemover collectionRemover = new Vista_RequestCollectionRemover();


		String key1 = 'k1';
		String key2 = 'k2';

		Set<String> keys = new Set<String> { key1 };
		Vista_RequestCollection requestCollection = CreateCollection(new Set<String> { key1, key2 });


		collectionRemover.RemoveByVistaOrderNumber(keys, requestCollection);

		System.assertEquals(null, requestCollection.RecordGroups.get(key1));
	}

	static testmethod void RemoveByVistaOrderNumber_DoesNotRemoveRecordGroupK2_GivenK1()
	{
		Vista_RequestCollectionRemover collectionRemover = new Vista_RequestCollectionRemover();


		String key1 = 'k1';
		String key2 = 'k2';

		Set<String> keys = new Set<String> { key1 };
		Vista_RequestCollection requestCollection = CreateCollection(new Set<String> { key1, key2 });


		collectionRemover.RemoveByVistaOrderNumber(keys, requestCollection);

		System.assertNotEquals(null, requestCollection.RecordGroups.get(key2));
	}

	static testmethod void RemoveByVistaOrderNumber_RemovesOrderK1_GivenK1()
	{
		Vista_RequestCollectionRemover collectionRemover = new Vista_RequestCollectionRemover();


		String key1 = 'k1';
		String key2 = 'k2';

		Set<String> keys = new Set<String> { key1 };
		Vista_RequestCollection requestCollection = CreateCollection(new Set<String> { key1, key2 });


		collectionRemover.RemoveByVistaOrderNumber(keys, requestCollection);

		System.assertEquals(null, requestCollection.Orders.get(key1));
	}

	static testmethod void RemoveByVistaOrderNumber_DoesNotRemoveOrderK2_GivenK1()
	{
		Vista_RequestCollectionRemover collectionRemover = new Vista_RequestCollectionRemover();


		String key1 = 'k1';
		String key2 = 'k2';

		Set<String> keys = new Set<String> { key1 };
		Vista_RequestCollection requestCollection = CreateCollection(new Set<String> { key1, key2 });


		collectionRemover.RemoveByVistaOrderNumber(keys, requestCollection);

		System.assertNotEquals(null, requestCollection.Orders.get(key2));
	}

	static testmethod void RemoveByVistaOrderNumber_RemovesAssetK1_GivenK1()
	{
		Vista_RequestCollectionRemover collectionRemover = new Vista_RequestCollectionRemover();


		String key1 = 'k1';
		String key2 = 'k2';

		Set<String> keys = new Set<String> { key1 };
		Vista_RequestCollection requestCollection = CreateCollection(new Set<String> { key1, key2 });


		collectionRemover.RemoveByVistaOrderNumber(keys, requestCollection);

		System.assertEquals(null, requestCollection.Assets.get(key1));
	}

	static testmethod void RemoveByVistaOrderNumber_DoesNotRemoveAssetK2_GivenK1()
	{
		Vista_RequestCollectionRemover collectionRemover = new Vista_RequestCollectionRemover();


		String key1 = 'k1';
		String key2 = 'k2';

		Set<String> keys = new Set<String> { key1 };
		Vista_RequestCollection requestCollection = CreateCollection(new Set<String> { key1, key2 });


		collectionRemover.RemoveByVistaOrderNumber(keys, requestCollection);

		System.assertNotEquals(null, requestCollection.Assets.get(key2));
	}

	static testmethod void RemoveByVistaOrderNumber_RemovesOrderItemForDeleteK1_GivenK1()
	{
		Vista_RequestCollectionRemover collectionRemover = new Vista_RequestCollectionRemover();


		String key1 = 'k1';
		String key2 = 'k2';

		Set<String> keys = new Set<String> { key1 };
		Vista_RequestCollection requestCollection = CreateCollection(new Set<String> { key1, key2 });


		collectionRemover.RemoveByVistaOrderNumber(keys, requestCollection);

		System.assertEquals(null, requestCollection.OrderItemsForDelete.get(key1));
	}

	static testmethod void RemoveByVistaOrderNumber_DoesNotRemoveOrderItemForDeleteK2_GivenK1()
	{
		Vista_RequestCollectionRemover collectionRemover = new Vista_RequestCollectionRemover();


		String key1 = 'k1';
		String key2 = 'k2';

		Set<String> keys = new Set<String> { key1 };
		Vista_RequestCollection requestCollection = CreateCollection(new Set<String> { key1, key2 });


		collectionRemover.RemoveByVistaOrderNumber(keys, requestCollection);

		System.assertNotEquals(null, requestCollection.OrderItemsForDelete.get(key2));
	}

	static testmethod void RemoveByVistaOrderNumber_RemovesOrderItemForInsertK1_GivenK1()
	{
		Vista_RequestCollectionRemover collectionRemover = new Vista_RequestCollectionRemover();


		String key1 = 'k1';
		String key2 = 'k2';

		Set<String> keys = new Set<String> { key1 };
		Vista_RequestCollection requestCollection = CreateCollection(new Set<String> { key1, key2 });


		collectionRemover.RemoveByVistaOrderNumber(keys, requestCollection);

		System.assertEquals(null, requestCollection.OrderItemsForInsert.get(key1));
	}

	static testmethod void RemoveByVistaOrderNumber_DoesNotRemoveOrderItemForInsertK2_GivenK1()
	{
		Vista_RequestCollectionRemover collectionRemover = new Vista_RequestCollectionRemover();


		String key1 = 'k1';
		String key2 = 'k2';

		Set<String> keys = new Set<String> { key1 };
		Vista_RequestCollection requestCollection = CreateCollection(new Set<String> { key1, key2 });


		collectionRemover.RemoveByVistaOrderNumber(keys, requestCollection);

		System.assertNotEquals(null, requestCollection.OrderItemsForInsert.get(key2));
	}


	private static Vista_RequestCollection CreateCollection(Set<String> keys)
	{
		Vista_RequestCollection requestCollection = new Vista_RequestCollection();

		requestCollection.RecordGroups = new Map<String, List<Vista_RecordGroup>>();
		requestCollection.Orders = new Map<String, Order>();
		requestCollection.Assets = new Map<String, Asset>();
		requestCollection.OrderItemsForDelete = new Map<String, OrderItem>();
		requestCollection.OrderItemsForInsert = new Map<String, OrderItem>();

		for(String key : keys) {
			requestCollection.RecordGroups.put(key, new List<Vista_RecordGroup>());
			requestCollection.Orders.put(key, new Order());
			requestCollection.Assets.put(key, new Asset());
			requestCollection.OrderItemsForDelete.put(key, new OrderItem());
			requestCollection.OrderItemsForInsert.put(key, new OrderItem());
		}

		return requestCollection;
	}
}