public class Vista_OrderBuilder_DELETE extends Vista_OrderBuilder_A {
	public Vista_OrderBuilder_DELETE()
	{
		this.EventCode = Vista_EventCodes.DELETE_CODE;
	}


	protected override void Build(Order order, Vista_RecordGroup request)
    {
        order.Status = System.label.Order_DeletedStatus;
    }
}