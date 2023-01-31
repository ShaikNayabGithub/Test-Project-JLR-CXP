@isTest
public class Vista_RequestToRequestCollection_Adapt_T {
	static testmethod void Adapt_ReturnsRequestCollection_GivenEmptyList()
	{
		Vista_RequestToRequestCollection_Adapter adapter = new Vista_RequestToRequestCollection_Adapter();

		List<Vista_Request__c> input = new List<Vista_Request__c>();

		Vista_RequestCollection result = adapter.Adapt(input);

		System.assertNotEquals(null, result);
	}

	static testmethod void Adapt_SetsRequestStatusToRejected_GivenUnhandledEventCode()
	{
		Vista_RequestToRequestCollection_Adapter adapter = new Vista_RequestToRequestCollection_Adapter();


		Vista_OrderService.VehicleOrder vehicleOrder = new Vista_OrderService.VehicleOrder();
		vehicleOrder.Eventcode = 'Invalid';

		List<Vista_OrderService.VehicleOrder> vehicleOrders = new List<Vista_OrderService.VehicleOrder>{ vehicleOrder };

		Vista_Request__c request1 = new Vista_Request__c();
		request1.Vehicle_Orders__c = JSON.serialize(vehicleOrders);

		List<Vista_Request__c> input = new List<Vista_Request__c>{ request1 };


		Vista_RequestCollection result = adapter.Adapt(input);

		System.assertEquals('Rejected', request1.Status__c);
	}

	static testmethod void Adapt_SetsRequestStatusToRejected_Given2UnhandledEventCodes()
	{
		Vista_RequestToRequestCollection_Adapter adapter = new Vista_RequestToRequestCollection_Adapter();


		Vista_OrderService.VehicleOrder vehicleOrder = new Vista_OrderService.VehicleOrder();
		vehicleOrder.Eventcode = 'Invalid';

		List<Vista_OrderService.VehicleOrder> vehicleOrders = new List<Vista_OrderService.VehicleOrder>{ 
			vehicleOrder, vehicleOrder };

		Vista_Request__c request1 = new Vista_Request__c();
		request1.Vehicle_Orders__c = JSON.serialize(vehicleOrders);

		List<Vista_Request__c> input = new List<Vista_Request__c>{ request1 };


		Vista_RequestCollection result = adapter.Adapt(input);

		System.assertEquals('Rejected', request1.Status__c);
	}

	static testmethod void Adapt_SetsRequestStatusToProcessed_GivenOneUnhandledAndOneHandledEventCode()
	{
		Vista_RequestToRequestCollection_Adapter adapter = new Vista_RequestToRequestCollection_Adapter();


		Vista_OrderService.VehicleOrder vehicleOrder1 = new Vista_OrderService.VehicleOrder();
		vehicleOrder1.Eventcode = Vista_EventCodes.HANDOVER;
		Vista_OrderService.VehicleOrder vehicleOrder2 = new Vista_OrderService.VehicleOrder();
		vehicleOrder2.Eventcode = 'Invalid';

		List<Vista_OrderService.VehicleOrder> vehicleOrders = new List<Vista_OrderService.VehicleOrder>{ 
			vehicleOrder2, vehicleOrder1 };

		Vista_Request__c request1 = new Vista_Request__c();
		request1.Vehicle_Orders__c = JSON.serialize(vehicleOrders);
		request1.Status__c = 'test';

		List<Vista_Request__c> input = new List<Vista_Request__c>{ request1 };


		Vista_RequestCollection result = adapter.Adapt(input);

		System.assertEquals('Processed', request1.Status__c);
	}

	static testmethod void Adapt_SetsRequestErrorLog_GivenOneUnhandledAndOneHandledEventCode()
	{
		Vista_RequestToRequestCollection_Adapter adapter = new Vista_RequestToRequestCollection_Adapter();


		Vista_OrderService.VehicleOrder vehicleOrder1 = new Vista_OrderService.VehicleOrder();
		vehicleOrder1.Eventcode = Vista_EventCodes.HANDOVER;
		Vista_OrderService.VehicleOrder vehicleOrder2 = new Vista_OrderService.VehicleOrder();
		vehicleOrder2.Eventcode = 'Invalid';

		List<Vista_OrderService.VehicleOrder> vehicleOrders = new List<Vista_OrderService.VehicleOrder>{ 
			vehicleOrder2, vehicleOrder1 };

		Vista_Request__c request1 = new Vista_Request__c();
		request1.Vehicle_Orders__c = JSON.serialize(vehicleOrders);
		request1.Status__c = 'test';

		List<Vista_Request__c> input = new List<Vista_Request__c>{ request1 };


		Vista_RequestCollection result = adapter.Adapt(input);

		System.assert(String.isNotBlank(request1.Error_Log__c));
	}

	static testmethod void Adapt_DoesNotSetRequestErrorLog_GivenOneHandledEventCode()
	{
		Vista_RequestToRequestCollection_Adapter adapter = new Vista_RequestToRequestCollection_Adapter();


		Vista_OrderService.VehicleOrder vehicleOrder1 = new Vista_OrderService.VehicleOrder();
		vehicleOrder1.Eventcode = Vista_EventCodes.HANDOVER;

		List<Vista_OrderService.VehicleOrder> vehicleOrders = new List<Vista_OrderService.VehicleOrder>{ 
			vehicleOrder1 };

		Vista_Request__c request1 = new Vista_Request__c();
		request1.Vehicle_Orders__c = JSON.serialize(vehicleOrders);
		request1.Status__c = 'test';

		List<Vista_Request__c> input = new List<Vista_Request__c>{ request1 };


		Vista_RequestCollection result = adapter.Adapt(input);

		System.assert(String.isBlank(request1.Error_Log__c));
	}

	static testmethod void Adapt_DoesNotAddRecordGroupToCollection_GivenOneUnandledEventCode()
	{
		Vista_RequestToRequestCollection_Adapter adapter = new Vista_RequestToRequestCollection_Adapter();


		Vista_OrderService.VehicleOrder vehicleOrder1 = new Vista_OrderService.VehicleOrder();
		vehicleOrder1.Eventcode = 'Invalid';
		vehicleOrder1.MetaOrderNumber = 'test1';

		List<Vista_OrderService.VehicleOrder> vehicleOrders = new List<Vista_OrderService.VehicleOrder>{ 
			vehicleOrder1 };

		Vista_Request__c request1 = new Vista_Request__c();
		request1.Vehicle_Orders__c = JSON.serialize(vehicleOrders);

		List<Vista_Request__c> input = new List<Vista_Request__c>{ request1 };


		Vista_RequestCollection result = adapter.Adapt(input);

		System.assertEquals(null, result.RecordGroups.get(vehicleOrder1.MetaOrderNumber));
	}

	static testmethod void Adapt_AddsRequestToCollectionWithHandledOrderNumber_GivenOneUnhandledAndOneHandledEventCode()
	{
		Vista_RequestToRequestCollection_Adapter adapter = new Vista_RequestToRequestCollection_Adapter();


		Vista_OrderService.VehicleOrder vehicleOrder1 = new Vista_OrderService.VehicleOrder();
		vehicleOrder1.Eventcode = 'Invalid';
		vehicleOrder1.MetaOrderNumber = 'test1';
		Vista_OrderService.VehicleOrder vehicleOrder2 = new Vista_OrderService.VehicleOrder();
		vehicleOrder2.Eventcode = Vista_EventCodes.HANDOVER;
		vehicleOrder2.MetaOrderNumber = 'test2';

		List<Vista_OrderService.VehicleOrder> vehicleOrders = new List<Vista_OrderService.VehicleOrder>{ 
			vehicleOrder1, vehicleOrder2 };

		Vista_Request__c request1 = new Vista_Request__c();
		request1.Name = 'r1';
		request1.Vehicle_Orders__c = JSON.serialize(vehicleOrders);

		List<Vista_Request__c> input = new List<Vista_Request__c>{ request1 };


		Vista_RequestCollection result = adapter.Adapt(input);

		System.assertEquals(request1.Name, result.RecordGroups.get(vehicleOrder2.MetaOrderNumber)[0].Request.Name);
	}

	static testmethod void Adapt_AddsVehicleOrderToCollection_GivenOneHandledEventCode()
	{
		Vista_RequestToRequestCollection_Adapter adapter = new Vista_RequestToRequestCollection_Adapter();


		Vista_OrderService.VehicleOrder vehicleOrder1 = new Vista_OrderService.VehicleOrder();
		vehicleOrder1.Eventcode = Vista_EventCodes.HANDOVER;
		vehicleOrder1.MetaOrderNumber = 'test1';

		List<Vista_OrderService.VehicleOrder> vehicleOrders = new List<Vista_OrderService.VehicleOrder>{ 
			vehicleOrder1 };

		Vista_Request__c request1 = new Vista_Request__c();
		request1.Vehicle_Orders__c = JSON.serialize(vehicleOrders);

		List<Vista_Request__c> input = new List<Vista_Request__c>{ request1 };


		Vista_RequestCollection result = adapter.Adapt(input);

		System.assertEquals(vehicleOrder1.MetaOrderNumber, result.RecordGroups.get(vehicleOrder1.MetaOrderNumber)[0].VistaVehicleOrder.MetaOrderNumber);
	}
}