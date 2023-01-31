@isTest
public class Vista_OrderBuilder_NONSPEC_T {
    static testmethod void Constructor_SetsEventCodeToNonSpec_WhenCalled()
    {
        Vista_Date_Adapter dateAdapter = new Vista_Date_Adapter();
        Vista_OrderBuilder_NONSPEC orderBuilder = new Vista_OrderBuilder_NONSPEC(dateAdapter);
        

        System.assertEquals(Vista_EventCodes.NONSPEC, orderBuilder.EventCode);
    }

    static testmethod void Build_DoesNothing_GivenManufactureIsNull()
    {
        Vista_OrderBuilder_NONSPEC orderBuilder = CreateBuilder();

        String orderNumber = 'o1';
        Order order1 = new Order();

        Vista_RequestCollection requestCollection = CreateEmptyCollection();
        requestCollection.Orders.put(orderNumber, order1);

        Vista_RecordGroup recordGroup = CreateEmptyRecordGroup();
        recordGroup.VistaVehicleOrder.MetaOrderNumber = orderNumber;


        orderBuilder.Build(recordGroup, requestCollection);

        System.assert(true);
    }

    static testmethod void Build_SetsLastDayForSpecificationChange_GivenLastDayForSpecificationChange()
    {
        Vista_OrderBuilder_NONSPEC orderBuilder = CreateBuilder();

        String orderNumber = 'o1';
        String dateString = '2016-12-15';
        Date expectedDate = Date.newInstance(2016, 12, 15);
        Order order1 = new Order();

        Vista_RequestCollection requestCollection = CreateEmptyCollection();
        requestCollection.Orders.put(orderNumber, order1);

        Vista_RecordGroup recordGroup = CreateEmptyRecordGroup();
        recordGroup.VistaVehicleOrder.MetaOrderNumber = orderNumber;
        recordGroup.VistaVehicleOrder.Manufacture = new Vista_OrderService.Manufacture();
        recordGroup.VistaVehicleOrder.Manufacture.LastDayForSpecificationChange = dateString;


        orderBuilder.Build(recordGroup, requestCollection);

        System.assertEquals(expectedDate, order1.Last_Day_for_Specification_Change__c);
    }

    static testmethod void Build_DoesNotClearLastDayForSpecificationChange_GivenLastDayForSpecificationChangeIsEmpty()
    {
        Vista_OrderBuilder_NONSPEC orderBuilder = CreateBuilder();

        String orderNumber = 'o1';
        String dateString = '';
        Date expectedDate = Date.newInstance(2016, 12, 15);
        Order order1 = new Order(Last_Day_for_Specification_Change__c=expectedDate);

        Vista_RequestCollection requestCollection = CreateEmptyCollection();
        requestCollection.Orders.put(orderNumber, order1);

        Vista_RecordGroup recordGroup = CreateEmptyRecordGroup();
        recordGroup.VistaVehicleOrder.MetaOrderNumber = orderNumber;
        recordGroup.VistaVehicleOrder.Manufacture = new Vista_OrderService.Manufacture();
        recordGroup.VistaVehicleOrder.Manufacture.LastDayForSpecificationChange = dateString;


        orderBuilder.Build(recordGroup, requestCollection);

        System.assertEquals(expectedDate, order1.Last_Day_for_Specification_Change__c);
    }

    static testmethod void Build_SetsPlannedDeliveryDate_GivenPlannedDeliveryDate()
    {
        Vista_OrderBuilder_NONSPEC orderBuilder = CreateBuilder();

        String orderNumber = 'o1';
        String dateString = '2016-12-15';
        Date expectedDate = Date.newInstance(2016, 12, 15);
        Order order1 = new Order();

        Vista_RequestCollection requestCollection = CreateEmptyCollection();
        requestCollection.Orders.put(orderNumber, order1);

        Vista_RecordGroup recordGroup = CreateEmptyRecordGroup();
        recordGroup.VistaVehicleOrder.MetaOrderNumber = orderNumber;
        recordGroup.VistaVehicleOrder.Manufacture = new Vista_OrderService.Manufacture();
        recordGroup.VistaVehicleOrder.Manufacture.Scheduling = new Vista_OrderService.Scheduling();
        recordGroup.VistaVehicleOrder.Manufacture.Scheduling.CurrentPlannedDeliveryDate = dateString;


        orderBuilder.Build(recordGroup, requestCollection);

        System.assertEquals(expectedDate, order1.Planned_Delivery_Date__c);
    }

    static testmethod void Build_DoesNotClearPlannedDeliveryDate_GivenPlannedDeliveryDateIsEmpty()
    {
        Vista_OrderBuilder_NONSPEC orderBuilder = CreateBuilder();

        String orderNumber = 'o1';
        String dateString = '';
        Date expectedDate = Date.newInstance(2016, 12, 15);
        Order order1 = new Order(Planned_Delivery_Date__c=expectedDate);

        Vista_RequestCollection requestCollection = CreateEmptyCollection();
        requestCollection.Orders.put(orderNumber, order1);

        Vista_RecordGroup recordGroup = CreateEmptyRecordGroup();
        recordGroup.VistaVehicleOrder.MetaOrderNumber = orderNumber;
        recordGroup.VistaVehicleOrder.Manufacture = new Vista_OrderService.Manufacture();
        recordGroup.VistaVehicleOrder.Manufacture.Scheduling = new Vista_OrderService.Scheduling();
        recordGroup.VistaVehicleOrder.Manufacture.Scheduling.CurrentPlannedDeliveryDate = dateString;


        orderBuilder.Build(recordGroup, requestCollection);

        System.assertEquals(expectedDate, order1.Planned_Delivery_Date__c);
    }

    static testmethod void Build_SetsAcceptedDeliveryDate_GivenAcceptedDeliveryDate()
    {
        Vista_OrderBuilder_NONSPEC orderBuilder = CreateBuilder();

        String orderNumber = 'o1';
        String dateString = '2016-12-15';
        Date expectedDate = Date.newInstance(2016, 12, 15);
        Order order1 = new Order();

        Vista_RequestCollection requestCollection = CreateEmptyCollection();
        requestCollection.Orders.put(orderNumber, order1);

        Vista_RecordGroup recordGroup = CreateEmptyRecordGroup();
        recordGroup.VistaVehicleOrder.MetaOrderNumber = orderNumber;
        recordGroup.VistaVehicleOrder.Manufacture = new Vista_OrderService.Manufacture();
        recordGroup.VistaVehicleOrder.Manufacture.Scheduling = new Vista_OrderService.Scheduling();
        recordGroup.VistaVehicleOrder.Manufacture.Scheduling.AcceptedDeliveryDate = dateString;


        orderBuilder.Build(recordGroup, requestCollection);

        System.assertEquals(expectedDate, order1.Accepted_Delivery_Date__c);
    }

    static testmethod void Build_DoesNotClearAcceptedDeliveryDate_GivenAcceptedDeliveryDateIsEmpty()
    {
        Vista_OrderBuilder_NONSPEC orderBuilder = CreateBuilder();

        String orderNumber = 'o1';
        String dateString = '';
        Date expectedDate = Date.newInstance(2016, 12, 15);
        Order order1 = new Order(Accepted_Delivery_Date__c=expectedDate);

        Vista_RequestCollection requestCollection = CreateEmptyCollection();
        requestCollection.Orders.put(orderNumber, order1);

        Vista_RecordGroup recordGroup = CreateEmptyRecordGroup();
        recordGroup.VistaVehicleOrder.MetaOrderNumber = orderNumber;
        recordGroup.VistaVehicleOrder.Manufacture = new Vista_OrderService.Manufacture();
        recordGroup.VistaVehicleOrder.Manufacture.Scheduling = new Vista_OrderService.Scheduling();
        recordGroup.VistaVehicleOrder.Manufacture.Scheduling.AcceptedDeliveryDate = dateString;


        orderBuilder.Build(recordGroup, requestCollection);

        System.assertEquals(expectedDate, order1.Accepted_Delivery_Date__c);
    }


    private static Vista_OrderBuilder_NONSPEC CreateBuilder()
    {
        Vista_Date_Adapter dateAdapter = new Vista_Date_Adapter();
        return new Vista_OrderBuilder_NONSPEC(dateAdapter);
    }

    private static Vista_RequestCollection CreateEmptyCollection()
    {
        Vista_RequestCollection requestCollection = new Vista_RequestCollection();

        requestCollection.RecordGroups = new Map<String, List<Vista_RecordGroup>>();
        requestCollection.Orders = new Map<String, Order>();
        requestCollection.PriceBookEntries = new Map<String, PriceBookEntry>();
        requestCollection.OpportunityLineItems = new Map<String, OpportunityLineItem>();
        requestCollection.Retailers = new Map<String, Account>();

        return requestCollection;
    }

    private static Vista_RecordGroup CreateEmptyRecordGroup()
    {
        Vista_RecordGroup recordGroup = new Vista_RecordGroup();

        recordGroup.Request = new Vista_Request__c();
        recordGroup.VistaVehicleOrder = new Vista_OrderService.VehicleOrder();
        recordGroup.VistaVehicleOrder.Specification = new Vista_OrderService.Specification();
        recordGroup.VistaVehicleOrder.Distribution = new Vista_OrderService.Distribution();
        recordGroup.VistaVehicleOrder.Distribution.DistributionChannel = new Vista_OrderService.DistributionChannel();

        return recordGroup;
    }
}