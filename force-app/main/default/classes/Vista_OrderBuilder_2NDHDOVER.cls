public class Vista_OrderBuilder_2NDHDOVER extends Vista_OrderBuilder_A {
  public Vista_OrderBuilder_2NDHDOVER()
  {
    this.EventCode = Vista_EventCodes.SECONDHDOVER;
  }


  protected override void Build(Order order, Vista_RecordGroup request)
    {
        order.Status = System.label.Order_FulfilledStatus;
    }
}