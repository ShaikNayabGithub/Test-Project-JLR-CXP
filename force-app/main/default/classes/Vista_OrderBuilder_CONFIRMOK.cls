public class Vista_OrderBuilder_CONFIRMOK extends Vista_OrderBuilder_A {
    public Vista_OrderBuilder_CONFIRMOK()
    {
        this.EventCode = Vista_EventCodes.CONFIRMOK;
    }

    @testvisible
    protected override void Build(Order order, Vista_RecordGroup request)
    {
        //do nothing
    }
}