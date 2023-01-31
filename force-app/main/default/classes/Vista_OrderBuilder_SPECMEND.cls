public class Vista_OrderBuilder_SPECMEND extends Vista_OrderBuilder_A {
    public Vista_OrderBuilder_SPECMEND()
    {
        this.EventCode = Vista_EventCodes.SPECMEND;
    }

    @testvisible
    protected override void Build(Order order, Vista_RecordGroup request)
    {
        //do nothing
    }
}