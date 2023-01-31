@isTest
public class Vista_OrderBuilder_CANHDOVER_T {
  static testmethod void Constructor_SetsEventCodeToHandover_WhenCalled()
  {
    Vista_OrderBuilder_CANHDOVER orderBuilder = new Vista_OrderBuilder_CANHDOVER();

    System.assertEquals(Vista_EventCodes.CANHDOVER, orderBuilder.EventCode);
  }

  static testmethod void Build_AddsOrderWithStatusFulfilled_GivenOrderDoesntExist()
  {
    Vista_OrderBuilder_CANHDOVER orderBuilder = new Vista_OrderBuilder_CANHDOVER();


    String orderNumber = 'o1';

    Vista_RequestCollection requestCollection = CreateEmptyCollection();

    Vista_RecordGroup recordGroup = CreateEmptyRecordGroup();
    recordGroup.VistaVehicleOrder.MetaOrderNumber = orderNumber;


    orderBuilder.Build(recordGroup, requestCollection);

    System.assertEquals(System.label.Order_FulfilledStatus, requestCollection.Orders.get(orderNumber).Status);
  }

  static testmethod void Build_AddsOrderWithStatusFulfilled_GivenOrderFound()
  {
    Vista_OrderBuilder_CANHDOVER orderBuilder = new Vista_OrderBuilder_CANHDOVER();


    String orderNumber = 'o1';
    Order order1 = new Order();

    Vista_RequestCollection requestCollection = CreateEmptyCollection();
    requestCollection.Orders.put(orderNumber, order1);

    Vista_RecordGroup recordGroup = CreateEmptyRecordGroup();
    recordGroup.VistaVehicleOrder.MetaOrderNumber = orderNumber;


    orderBuilder.Build(recordGroup, requestCollection);

    System.assertEquals(System.label.Order_FulfilledStatus, order1.Status);
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