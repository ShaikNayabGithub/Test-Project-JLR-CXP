public class Vista_OrderBuilder {
    private final Map<String, Vista_OrderBuilder_A> eventHandlers;


    public Vista_OrderBuilder(Map<String, Vista_OrderBuilder_A> eventHandlers)
    {
        this.eventHandlers = eventHandlers;
    }


    public void Build(Vista_RequestCollection requestCollection)
    {
        for(String orderNumber : requestCollection.RecordGroups.KeySet()){
            List<Vista_RecordGroup> requests = requestCollection.RecordGroups.get(orderNumber);

            for(Vista_RecordGroup request : requests) {
                Vista_OrderBuilder_A eventHandler = this.eventHandlers.get(request.VistaVehicleOrder.EventCode);
                if(eventHandler != null) { eventHandler.Build(request, requestCollection); }
            }
        }
    }
}