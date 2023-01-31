@isTest
public class Vista_OrderBuilder_RETRY_T {
    static testmethod void Constructor_SetsEventCodeToRetry_WhenCalled()
    {
        Vista_OrderBuilder_RETRY orderBuilder = new Vista_OrderBuilder_RETRY();
        Vista_RecordGroup request;
        Order order;
        orderBuilder.build(order,request);
        System.assertEquals(Vista_EventCodes.RETRY, orderBuilder.EventCode);
    }
}