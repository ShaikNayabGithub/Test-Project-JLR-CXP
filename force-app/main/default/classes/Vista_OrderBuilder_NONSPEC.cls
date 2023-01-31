public class Vista_OrderBuilder_NONSPEC extends Vista_OrderBuilder_A {
    private final Vista_Date_Adapter dateAdapter;


    public Vista_OrderBuilder_NONSPEC(Vista_Date_Adapter dateAdapter)
    {
        this.dateAdapter = dateAdapter;
        this.EventCode = Vista_EventCodes.NONSPEC;
    }

    @testvisible
    protected override void Build(Order order, Vista_RecordGroup request)
    {
        if(request.VistaVehicleOrder.Manufacture == null) { return; }
        
        if(String.isNotBlank(request.VistaVehicleOrder.Manufacture.LastDayForSpecificationChange)) {
            order.Last_Day_for_Specification_Change__c = this.dateAdapter.Parse(request.VistaVehicleOrder.Manufacture.LastDayForSpecificationChange);
        }

        if(request.VistaVehicleOrder.Manufacture.Scheduling == null) { return; }
        
        if(String.isNotBlank(request.VistaVehicleOrder.Manufacture.Scheduling.CurrentPlannedDeliveryDate)) {
            order.Planned_Delivery_Date__c  = this.dateAdapter.Parse(request.VistaVehicleOrder.Manufacture.Scheduling.CurrentPlannedDeliveryDate);
        }
        if(String.isNotBlank(request.VistaVehicleOrder.Manufacture.Scheduling.AcceptedDeliveryDate)) {
            order.Accepted_Delivery_Date__c  = this.dateAdapter.Parse(request.VistaVehicleOrder.Manufacture.Scheduling.AcceptedDeliveryDate);
        }
    }
}