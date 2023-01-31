public class Vista_OrderBuilder_HANDOVER extends Vista_OrderBuilder_A {
	public Vista_OrderBuilder_HANDOVER()
	{
		this.EventCode = Vista_EventCodes.HANDOVER;
	}


	protected override void Build(Order order, Vista_RecordGroup request)
    {
        order.Status = System.label.Order_FulfilledStatus;
    }
}