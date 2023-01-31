public class Vista_OrderBuilder_Default extends Vista_OrderBuilder_A {
    public Vista_OrderBuilder_Default(String eventCode)
    {
        this.EventCode = eventCode;
    }

    @testvisible 
    protected override void Build(Order order, Vista_RecordGroup request)
    {
        //do nothing
    }
}