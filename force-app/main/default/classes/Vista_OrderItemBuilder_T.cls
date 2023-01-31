@isTest
public class Vista_OrderItemBuilder_T {
	static testmethod void Build_DoesNothing_GivenEmptyCollection()
	{
		Vista_OrderItemBuilder orderItemBuilder = new Vista_OrderItemBuilder();

		Vista_RequestCollection requestCollection = CreateEmptyCollection();

		orderItemBuilder.Build(requestCollection);

		System.assert(true);
	}

	static testmethod void Build_DoesNothing_GivenProductNotFound()
	{
		Vista_OrderItemBuilder orderItemBuilder = new Vista_OrderItemBuilder();


		Vista_RequestCollection requestCollection = CreateEmptyCollection();

		Vista_RecordGroup recordGroup = CreateEmptyRecordGroup();
		recordGroup.VistaVehicleOrder.MetaOrderNumber = 't1';
		recordGroup.VistaVehicleOrder.Specification.DescriptionGroupId = 'p1';

		List<Vista_RecordGroup> childGroups1 = new List<Vista_RecordGroup>{ recordGroup };
		requestCollection.RecordGroups.put('t1', childGroups1);


		orderItemBuilder.Build(requestCollection);

		System.assert(true);
	}

	static testmethod void Build_CreatesOrderItem_GivenProductAndOrderFoundAndNoOrderItemExists()
	{
		Vista_OrderItemBuilder orderItemBuilder = new Vista_OrderItemBuilder();


		String productCode = 'p1';
		String orderNumber = 'o1';

		Vista_RequestCollection requestCollection = CreateEmptyCollection();
		requestCollection.Derivatives.put(productCode, new Product2());
		requestCollection.Orders.put(orderNumber, new Order());

		Vista_RecordGroup recordGroup = CreateEmptyRecordGroup();
		recordGroup.VistaVehicleOrder.MetaOrderNumber = orderNumber;
		recordGroup.VistaVehicleOrder.Specification.DescriptionGroupId = productCode;

		List<Vista_RecordGroup> childGroups1 = new List<Vista_RecordGroup>{ recordGroup };
		requestCollection.RecordGroups.put(orderNumber, childGroups1);


		orderItemBuilder.Build(requestCollection);

		System.assertNotEquals(null, requestCollection.OrderItemsForInsert.get(orderNumber));
	}

	static testmethod void Build_AddsExistingOrderItemToDelete_GivenDifferentProductAndOrderItemAndOrderFound()
	{
		Vista_OrderItemBuilder orderItemBuilder = new Vista_OrderItemBuilder();


		String productCode = 'p1';
		String orderNumber = 'o1';
		String description = 'd1';
		String orderItemId = '8022400000AHK5k';//id irrelevant, just needs to be valid

		Vista_RequestCollection requestCollection = CreateEmptyCollection();
		requestCollection.Derivatives.put(productCode, new Product2());
		requestCollection.Orders.put(orderNumber, new Order());
		requestCollection.OrderItemsForInsert.put(orderNumber, new OrderItem(Id=orderItemId));

		Vista_RecordGroup recordGroup = CreateEmptyRecordGroup();
		recordGroup.VistaVehicleOrder.MetaOrderNumber = orderNumber;
		recordGroup.VistaVehicleOrder.Specification.DescriptionGroupId = productCode;

		List<Vista_RecordGroup> childGroups1 = new List<Vista_RecordGroup>{ recordGroup };
		requestCollection.RecordGroups.put(orderNumber, childGroups1);


		orderItemBuilder.Build(requestCollection);

		System.assertEquals(orderItemId, requestCollection.OrderItemsForDelete.get(orderNumber).Id);
	}

	static testmethod void Build_RemovesExistingOrderItemFromInsert_GivenDifferentProductAndOrderItemAndOrderFound()
	{
		Vista_OrderItemBuilder orderItemBuilder = new Vista_OrderItemBuilder();


		String productCode = 'p1';
		String orderNumber = 'o1';
		String orderItemId = '8022400000AHK5k';//id irrelevant, just needs to be valid

		Vista_RequestCollection requestCollection = CreateEmptyCollection();
		requestCollection.Derivatives.put(productCode, new Product2());
		requestCollection.Orders.put(orderNumber, new Order());
		requestCollection.OrderItemsForInsert.put(orderNumber, new OrderItem(Id=orderItemId));

		Vista_RecordGroup recordGroup = CreateEmptyRecordGroup();
		recordGroup.VistaVehicleOrder.MetaOrderNumber = orderNumber;
		recordGroup.VistaVehicleOrder.Specification.DescriptionGroupId = productCode;

		List<Vista_RecordGroup> childGroups1 = new List<Vista_RecordGroup>{ recordGroup };
		requestCollection.RecordGroups.put(orderNumber, childGroups1);


		orderItemBuilder.Build(requestCollection);

		System.assertNotEquals(orderItemId, requestCollection.OrderItemsForInsert.get(orderNumber).Id);
	}

	static testmethod void Build_DoesNothing_GivenOrderFoundAndOrderItemWithNoIdAndSameProduct()
	{
		Vista_OrderItemBuilder orderItemBuilder = new Vista_OrderItemBuilder();

		PricebookEntry pricebookEntry = TestClass_PriceBookEntryBuilder.BuildPriceBookEntry(
				TestClass_PricebookCreator.CreatePricebook());

		String productCode = pricebookEntry.productCode;
		String orderNumber = 'o1';
		String description1 = 'd1';
		String description2 = 'd2';

		Vista_RequestCollection requestCollection = CreateEmptyCollection();
		requestCollection.Derivatives.put(productCode, new Product2(Description=description2));
		requestCollection.Orders.put(orderNumber, new Order());
		requestCollection.OrderItemsForInsert.put(orderNumber, new OrderItem(Description=description1,
			PricebookEntry = pricebookEntry));

		Vista_RecordGroup recordGroup = CreateEmptyRecordGroup();
		recordGroup.VistaVehicleOrder.MetaOrderNumber = orderNumber;
		recordGroup.VistaVehicleOrder.Specification.DescriptionGroupId = productCode;

		List<Vista_RecordGroup> childGroups1 = new List<Vista_RecordGroup>{ recordGroup };
		requestCollection.RecordGroups.put(orderNumber, childGroups1);


		orderItemBuilder.Build(requestCollection);

		System.assertEquals(description1, requestCollection.OrderItemsForInsert.get(orderNumber).Description);
	}

	static testmethod void Build_UpdatesOrderItem_GivenOrderFoundAndOrderItemWithNoIdAndDifferentProduct()
	{
		Vista_OrderItemBuilder orderItemBuilder = new Vista_OrderItemBuilder();


		String productCode1 = 'p1';
		Product2 product1 = new Product2(Name='t1',ProductCode=productCode1);
		insert product1;
		PricebookEntry pricebookEntry = TestClass_PriceBookEntryBuilder.BuildPriceBookEntry(
				TestClass_PricebookCreator.CreatePricebook(), product1);
		pricebookEntry = [SELECT Id, ProductCode FROM PricebookEntry WHERE Id=:pricebookEntry.Id];

		String productCode2 = 'p2';
		String orderNumber = 'o1';
		String description1 = 'd1';
		String description2 = 'd2';

		Vista_RequestCollection requestCollection = CreateEmptyCollection();
		requestCollection.Derivatives.put(productCode2, new Product2(Description=description2));
		requestCollection.Orders.put(orderNumber, new Order());
		requestCollection.OrderItemsForInsert.put(orderNumber, new OrderItem(Description=description1,
			PricebookEntry = pricebookEntry));

		Vista_RecordGroup recordGroup = CreateEmptyRecordGroup();
		recordGroup.VistaVehicleOrder.MetaOrderNumber = orderNumber;
		recordGroup.VistaVehicleOrder.Specification.DescriptionGroupId = productCode2;

		List<Vista_RecordGroup> childGroups1 = new List<Vista_RecordGroup>{ recordGroup };
		requestCollection.RecordGroups.put(orderNumber, childGroups1);


		orderItemBuilder.Build(requestCollection);

		System.assertEquals(description2, requestCollection.OrderItemsForInsert.get(orderNumber).Description);
	}

	static testmethod void Build_SetsOrderItemPriceTo2_GivenPricebookEntityPrice2AndProductAndOrderFound()
	{
		Vista_OrderItemBuilder orderItemBuilder = new Vista_OrderItemBuilder();


		String productCode = 'p1';
		String orderNumber = 'o1';
		Integer price = 2;
		String market = 'm1';

		Vista_RequestCollection requestCollection = CreateEmptyCollection();
		requestCollection.Derivatives.put(productCode, new Product2());
		requestCollection.Orders.put(orderNumber, new Order());
		String pbeKey = Vista_PricebookEntryKeyBuilder.Build(productCode, market);
		requestCollection.PriceBookEntries.put(pbeKey, new PriceBookEntry(UnitPrice=price));

		Vista_RecordGroup recordGroup = CreateEmptyRecordGroup();
		recordGroup.Request.Market_Description__c = market;
		recordGroup.VistaVehicleOrder.MetaOrderNumber = orderNumber;
		recordGroup.VistaVehicleOrder.Specification.DescriptionGroupId = productCode;

		List<Vista_RecordGroup> childGroups1 = new List<Vista_RecordGroup>{ recordGroup };
		requestCollection.RecordGroups.put(orderNumber, childGroups1);


		orderItemBuilder.Build(requestCollection);

		System.assertEquals(price, requestCollection.OrderItemsForInsert.get(orderNumber).UnitPrice);
	}

	static testmethod void Build_SetsOrderItemPriceTo2_GivenPricebookEntityNotFoundAndProductAndOrderFound()
	{
		Vista_OrderItemBuilder orderItemBuilder = new Vista_OrderItemBuilder();


		String productCode = 'p1';
		String orderNumber = 'o1';
		String market = 'm1';

		Vista_RequestCollection requestCollection = CreateEmptyCollection();
		requestCollection.Derivatives.put(productCode, new Product2());
		requestCollection.Orders.put(orderNumber, new Order());

		Vista_RecordGroup recordGroup = CreateEmptyRecordGroup();
		recordGroup.Request.Market_Description__c = market;
		recordGroup.VistaVehicleOrder.MetaOrderNumber = orderNumber;
		recordGroup.VistaVehicleOrder.Specification.DescriptionGroupId = productCode;

		List<Vista_RecordGroup> childGroups1 = new List<Vista_RecordGroup>{ recordGroup };
		requestCollection.RecordGroups.put(orderNumber, childGroups1);


		orderItemBuilder.Build(requestCollection);

		System.assertEquals(1, requestCollection.OrderItemsForInsert.get(orderNumber).UnitPrice);
	}


	private static Vista_RequestCollection CreateEmptyCollection()
	{
		Vista_RequestCollection requestCollection = new Vista_RequestCollection();

		requestCollection.RecordGroups = new Map<String, List<Vista_RecordGroup>>();
		requestCollection.OrderItemsForDelete = new Map<String, OrderItem>();
		requestCollection.OrderItemsForInsert = new Map<String, OrderItem>();
		requestCollection.Derivatives = new Map<String, Product2>();
		requestCollection.Orders = new Map<String, Order>();
		requestCollection.PriceBookEntries = new Map<String, PriceBookEntry>();

		return requestCollection;
	}

	private static Vista_RecordGroup CreateEmptyRecordGroup()
	{
		Vista_RecordGroup recordGroup = new Vista_RecordGroup();

		recordGroup.Request = new Vista_Request__c();
		recordGroup.VistaVehicleOrder = new Vista_OrderService.VehicleOrder();
		recordGroup.VistaVehicleOrder.Specification = new Vista_OrderService.Specification();

		return recordGroup;
	}
}