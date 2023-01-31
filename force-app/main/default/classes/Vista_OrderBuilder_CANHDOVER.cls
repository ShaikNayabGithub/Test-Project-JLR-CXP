public class Vista_OrderBuilder_CANHDOVER extends Vista_OrderBuilder_A {
  public Vista_OrderBuilder_CANHDOVER()
  {
    this.EventCode = Vista_EventCodes.CANHDOVER;
  }


  protected override void Build(Order order, Vista_RecordGroup request)
    {
     order.Status = System.label.Order_FulfilledStatus;  
    }
}