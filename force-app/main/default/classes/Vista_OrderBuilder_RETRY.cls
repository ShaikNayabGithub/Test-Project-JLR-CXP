public class Vista_OrderBuilder_RETRY extends Vista_OrderBuilder_A {
    public Vista_OrderBuilder_RETRY()
    {
        this.EventCode = Vista_EventCodes.RETRY;
    }

    @testvisible
    protected override void Build(Order order, Vista_RecordGroup request)
    {
        //do nothing
    }
}