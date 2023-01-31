@isTest
public class Vista_OrderBuilder_CONFIRMOK_T {
    static testmethod void Constructor_SetsEventCodeToConfirmOk_WhenCalled()
    {
        Vista_OrderBuilder_CONFIRMOK orderBuilder = new Vista_OrderBuilder_CONFIRMOK();
         Vista_RecordGroup request;
        Order order;
        orderBuilder.build(order,request);

        System.assertEquals(Vista_EventCodes.CONFIRMOK, orderBuilder.EventCode);
    }
}