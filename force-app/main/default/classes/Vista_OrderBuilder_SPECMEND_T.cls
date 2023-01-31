@isTest
public class Vista_OrderBuilder_SPECMEND_T {
    static testmethod void Constructor_SetsEventCodeToSpecMend_WhenCalled()
    {
        Vista_OrderBuilder_SPECMEND orderBuilder = new Vista_OrderBuilder_SPECMEND();
        Vista_RecordGroup request;
        Order order;
        orderBuilder.build(order,request);
        System.assertEquals(Vista_EventCodes.SPECMEND, orderBuilder.EventCode);
    }
}