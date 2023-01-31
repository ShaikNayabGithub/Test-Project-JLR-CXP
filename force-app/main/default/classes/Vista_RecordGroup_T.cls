@isTest
public class Vista_RecordGroup_T {
	static testmethod void CompareTo_Returns0_Given2NullVehicles()
	{
		Vista_RecordGroup thisGroup = new Vista_RecordGroup();

		Vista_RecordGroup compareToGroup = new Vista_RecordGroup();


		Integer result = thisGroup.compareTo(compareToGroup);

		System.assertEquals(0, result);
	}

	static testmethod void CompareTo_ReturnsMinus1_GivenThisGroupHasNullVehicleAndCompareToHasVehicle()
	{
		Vista_RecordGroup thisGroup = new Vista_RecordGroup();

		Vista_RecordGroup compareToGroup = new Vista_RecordGroup();
		compareToGroup.VistaVehicleOrder = new Vista_OrderService.VehicleOrder();


		Integer result = thisGroup.compareTo(compareToGroup);

		System.assertEquals(-1, result);
	}

	static testmethod void CompareTo_Returns1_GivenThisGroupHasVehicleAndCompareToHasNullVehicle()
	{
		Vista_RecordGroup thisGroup = new Vista_RecordGroup();
		thisGroup.VistaVehicleOrder = new Vista_OrderService.VehicleOrder();

		Vista_RecordGroup compareToGroup = new Vista_RecordGroup();


		Integer result = thisGroup.compareTo(compareToGroup);

		System.assertEquals(1, result);
	}

	static testmethod void CompareTo_Returns0_GivenGroupsHaveSameDateAndNoEventCode()
	{
		Vista_RecordGroup thisGroup = new Vista_RecordGroup();
		thisGroup.VistaVehicleOrder = new Vista_OrderService.VehicleOrder();
		thisGroup.VistaVehicleOrder.EventDateTime = '2018-01-01';

		Vista_RecordGroup compareToGroup = new Vista_RecordGroup();
		compareToGroup.VistaVehicleOrder = new Vista_OrderService.VehicleOrder();
		compareToGroup.VistaVehicleOrder.EventDateTime = '2018-01-01';


		Integer result = thisGroup.compareTo(compareToGroup);

		System.assertEquals(0, result);
	}

	static testmethod void CompareTo_Returns0_GivenGroupsHaveSameDateAndSameEventCode()
	{
		Vista_RecordGroup thisGroup = new Vista_RecordGroup();
		thisGroup.VistaVehicleOrder = new Vista_OrderService.VehicleOrder();
		thisGroup.VistaVehicleOrder.EventDateTime = '2018-01-01';
		thisGroup.VistaVehicleOrder.Eventcode = Vista_EventCodes.CONFIRMOK;

		Vista_RecordGroup compareToGroup = new Vista_RecordGroup();
		compareToGroup.VistaVehicleOrder = new Vista_OrderService.VehicleOrder();
		compareToGroup.VistaVehicleOrder.EventDateTime = '2018-01-01';
		compareToGroup.VistaVehicleOrder.Eventcode = Vista_EventCodes.CONFIRMOK;


		Integer result = thisGroup.compareTo(compareToGroup);

		System.assertEquals(0, result);
	}

	static testmethod void CompareTo_Returns0_GivenGroupsHaveSameDateAndNoEventCodes()
	{
		Vista_RecordGroup thisGroup = new Vista_RecordGroup();
		thisGroup.VistaVehicleOrder = new Vista_OrderService.VehicleOrder();
		thisGroup.VistaVehicleOrder.EventDateTime = '2018-01-01';

		Vista_RecordGroup compareToGroup = new Vista_RecordGroup();
		compareToGroup.VistaVehicleOrder = new Vista_OrderService.VehicleOrder();
		compareToGroup.VistaVehicleOrder.EventDateTime = '2018-01-01';


		Integer result = thisGroup.compareTo(compareToGroup);

		System.assertEquals(0, result);
	}

	static testmethod void CompareTo_Returns1_GivenThisGroupHasConfirmOkEventCodeAndCompareToHasNoEventCode()
	{
		Vista_RecordGroup thisGroup = new Vista_RecordGroup();
		thisGroup.VistaVehicleOrder = new Vista_OrderService.VehicleOrder();
		thisGroup.VistaVehicleOrder.EventDateTime = '2018-01-01';
		thisGroup.VistaVehicleOrder.Eventcode = Vista_EventCodes.CONFIRMOK;

		Vista_RecordGroup compareToGroup = new Vista_RecordGroup();
		compareToGroup.VistaVehicleOrder = new Vista_OrderService.VehicleOrder();
		compareToGroup.VistaVehicleOrder.EventDateTime = '2018-01-01';


		Integer result = thisGroup.compareTo(compareToGroup);

		System.assertEquals(1, result);
	}

	static testmethod void CompareTo_ReturnsMinus1_GivenThisGroupHasNoEventCodeAndCompareToHasConfirmOkEventCode()
	{
		Vista_RecordGroup thisGroup = new Vista_RecordGroup();
		thisGroup.VistaVehicleOrder = new Vista_OrderService.VehicleOrder();
		thisGroup.VistaVehicleOrder.EventDateTime = '2018-01-01';

		Vista_RecordGroup compareToGroup = new Vista_RecordGroup();
		compareToGroup.VistaVehicleOrder = new Vista_OrderService.VehicleOrder();
		compareToGroup.VistaVehicleOrder.EventDateTime = '2018-01-01';
		compareToGroup.VistaVehicleOrder.Eventcode = Vista_EventCodes.CONFIRMOK;


		Integer result = thisGroup.compareTo(compareToGroup);

		System.assertEquals(-1, result);
	}

	static testmethod void CompareTo_Returns1_GivenThisGroupHasDeleteCodeAndCompareToHasNonSpecEventCode()
	{
		Vista_RecordGroup thisGroup = new Vista_RecordGroup();
		thisGroup.VistaVehicleOrder = new Vista_OrderService.VehicleOrder();
		thisGroup.VistaVehicleOrder.EventDateTime = '2018-01-01';
		thisGroup.VistaVehicleOrder.Eventcode = Vista_EventCodes.DELETE_CODE;

		Vista_RecordGroup compareToGroup = new Vista_RecordGroup();
		compareToGroup.VistaVehicleOrder = new Vista_OrderService.VehicleOrder();
		compareToGroup.VistaVehicleOrder.EventDateTime = '2018-01-01';
		compareToGroup.VistaVehicleOrder.Eventcode = Vista_EventCodes.NONSPEC;


		Integer result = thisGroup.compareTo(compareToGroup);

		System.assertEquals(1, result);
	}

	static testmethod void CompareTo_Returns1_GivenThisGroupHasDeleteCodeAndCompareToHasHandoverEventCode()
	{
		Vista_RecordGroup thisGroup = new Vista_RecordGroup();
		thisGroup.VistaVehicleOrder = new Vista_OrderService.VehicleOrder();
		thisGroup.VistaVehicleOrder.EventDateTime = '2018-01-01';
		thisGroup.VistaVehicleOrder.Eventcode = Vista_EventCodes.DELETE_CODE;

		Vista_RecordGroup compareToGroup = new Vista_RecordGroup();
		compareToGroup.VistaVehicleOrder = new Vista_OrderService.VehicleOrder();
		compareToGroup.VistaVehicleOrder.EventDateTime = '2018-01-01';
		compareToGroup.VistaVehicleOrder.Eventcode = Vista_EventCodes.HANDOVER;


		Integer result = thisGroup.compareTo(compareToGroup);

		System.assertEquals(1, result);
	}

	static testmethod void CompareTo_ReturnsMinus1_GivenThisGroupHasNonSpecCodeAndCompareToHasDeleteEventCode()
	{
		Vista_RecordGroup thisGroup = new Vista_RecordGroup();
		thisGroup.VistaVehicleOrder = new Vista_OrderService.VehicleOrder();
		thisGroup.VistaVehicleOrder.EventDateTime = '2018-01-01';
		thisGroup.VistaVehicleOrder.Eventcode = Vista_EventCodes.NONSPEC;

		Vista_RecordGroup compareToGroup = new Vista_RecordGroup();
		compareToGroup.VistaVehicleOrder = new Vista_OrderService.VehicleOrder();
		compareToGroup.VistaVehicleOrder.EventDateTime = '2018-01-01';
		compareToGroup.VistaVehicleOrder.Eventcode = Vista_EventCodes.DELETE_CODE;


		Integer result = thisGroup.compareTo(compareToGroup);

		System.assertEquals(-1, result);
	}

	static testmethod void CompareTo_Returns1_GivenThisGroupHasHandoverCodeAndCompareToHasDeleteEventCode()
	{
		Vista_RecordGroup thisGroup = new Vista_RecordGroup();
		thisGroup.VistaVehicleOrder = new Vista_OrderService.VehicleOrder();
		thisGroup.VistaVehicleOrder.EventDateTime = '2018-01-01';
		thisGroup.VistaVehicleOrder.Eventcode = Vista_EventCodes.HANDOVER;

		Vista_RecordGroup compareToGroup = new Vista_RecordGroup();
		compareToGroup.VistaVehicleOrder = new Vista_OrderService.VehicleOrder();
		compareToGroup.VistaVehicleOrder.EventDateTime = '2018-01-01';
		compareToGroup.VistaVehicleOrder.Eventcode = Vista_EventCodes.DELETE_CODE;


		Integer result = thisGroup.compareTo(compareToGroup);

		System.assertEquals(-1, result);
	}

	static testmethod void CompareTo_Returns0_GivenGroupsHaveSameDateAndUnhandledEventCodes()
	{
		Vista_RecordGroup thisGroup = new Vista_RecordGroup();
		thisGroup.VistaVehicleOrder = new Vista_OrderService.VehicleOrder();
		thisGroup.VistaVehicleOrder.EventDateTime = '2018-01-01';
		thisGroup.VistaVehicleOrder.Eventcode = 'Unhandled';

		Vista_RecordGroup compareToGroup = new Vista_RecordGroup();
		compareToGroup.VistaVehicleOrder = new Vista_OrderService.VehicleOrder();
		compareToGroup.VistaVehicleOrder.EventDateTime = '2018-01-01';
		compareToGroup.VistaVehicleOrder.Eventcode = 'Unhandled';


		Integer result = thisGroup.compareTo(compareToGroup);

		System.assertEquals(0, result);
	}

	static testmethod void CompareTo_ReturnsMinus1_GivenThisGroupHasUnhandledCodeAndCompareToHasDeleteEventCode()
	{
		Vista_RecordGroup thisGroup = new Vista_RecordGroup();
		thisGroup.VistaVehicleOrder = new Vista_OrderService.VehicleOrder();
		thisGroup.VistaVehicleOrder.EventDateTime = '2018-01-01';
		thisGroup.VistaVehicleOrder.Eventcode = 'Unhandled';

		Vista_RecordGroup compareToGroup = new Vista_RecordGroup();
		compareToGroup.VistaVehicleOrder = new Vista_OrderService.VehicleOrder();
		compareToGroup.VistaVehicleOrder.EventDateTime = '2018-01-01';
		compareToGroup.VistaVehicleOrder.Eventcode = Vista_EventCodes.DELETE_CODE;


		Integer result = thisGroup.compareTo(compareToGroup);

		System.assertEquals(-1, result);
	}

	static testmethod void CompareTo_Returns1_GivenThisGroupHasDeleteCodeAndCompareToHasUnhandledEventCode()
	{
		Vista_RecordGroup thisGroup = new Vista_RecordGroup();
		thisGroup.VistaVehicleOrder = new Vista_OrderService.VehicleOrder();
		thisGroup.VistaVehicleOrder.EventDateTime = '2018-01-01';
		thisGroup.VistaVehicleOrder.Eventcode = Vista_EventCodes.DELETE_CODE;

		Vista_RecordGroup compareToGroup = new Vista_RecordGroup();
		compareToGroup.VistaVehicleOrder = new Vista_OrderService.VehicleOrder();
		compareToGroup.VistaVehicleOrder.EventDateTime = '2018-01-01';
		compareToGroup.VistaVehicleOrder.Eventcode = 'Unhandled';


		Integer result = thisGroup.compareTo(compareToGroup);

		System.assertEquals(1, result);
	}
}