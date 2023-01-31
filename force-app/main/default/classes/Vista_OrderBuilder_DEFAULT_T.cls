@isTest
public class Vista_OrderBuilder_DEFAULT_T {
    static testmethod void Constructor_SetsEventCodeToRetry_WhenCalled()
    {
        Vista_OrderBuilder_DEFAULT orderBuilder = new Vista_OrderBuilder_DEFAULT('HANDOVER');
        Vista_RecordGroup request;
        Order order;
        orderBuilder.build(order,request);
        System.assertEquals(Vista_EventCodes.HANDOVER, orderBuilder.EventCode);
    }
}