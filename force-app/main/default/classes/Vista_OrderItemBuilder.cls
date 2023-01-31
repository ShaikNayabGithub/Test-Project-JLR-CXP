public class Vista_OrderItemBuilder {
    public void Build(Vista_RequestCollection requestCollection)
    {
        if(requestCollection.OrderItemsForDelete == null) {
            requestCollection.OrderItemsForDelete = new Map<String, OrderItem>();
        }
        if(requestCollection.OrderItemsForInsert == null) {
            requestCollection.OrderItemsForInsert = new Map<String, OrderItem>();
        }
        for(String orderNumber : requestCollection.RecordGroups.KeySet()){
            List<Vista_RecordGroup> requests = requestCollection.RecordGroups.get(orderNumber);

            for(Vista_RecordGroup request : requests) {
                this.BuildOrderItem(request, requestCollection);
            }
        }
    }


    private void BuildOrderItem(Vista_RecordGroup request, Vista_RequestCollection requestCollection)
    {
        OrderItem orderItem = requestCollection.OrderItemsForInsert.get(request.VistaVehicleOrder.MetaOrderNumber);
        Order order = requestCollection.Orders.get(request.VistaVehicleOrder.MetaOrderNumber);
        Product2 derivative = requestCollection.Derivatives.get(request.VistaVehicleOrder.Specification.DescriptionGroupId);
        if(derivative == null) { return; }

        String pbeKey = Vista_PricebookEntryKeyBuilder.Build(request.VistaVehicleOrder.Specification.DescriptionGroupId, 
                request.Request.Market_Description__c);
        PriceBookEntry priceBookEntry = requestCollection.PriceBookEntries.get(pbeKey);

        if(orderItem != null){
            if(request.VistaVehicleOrder.Specification.DescriptionGroupId == orderItem.PricebookEntry.ProductCode) { 
                return; 
            }
            else if(String.isNotBlank(orderItem.Id)) {
                requestCollection.OrderItemsForDelete.put(request.VistaVehicleOrder.MetaOrderNumber, orderItem);
                requestCollection.OrderItemsForInsert.remove(request.VistaVehicleOrder.MetaOrderNumber);
            }
        } 
        
        orderItem = new OrderItem();
        requestCollection.OrderItemsForInsert.put(request.VistaVehicleOrder.MetaOrderNumber, orderItem);

        orderItem.Description = derivative.Description;
        orderItem.Quantity = 1;
        orderItem.UnitPrice = 1;
        orderItem.OrderId = order.Id;

        if(priceBookEntry != null) {
            orderItem.UnitPrice = priceBookEntry.UnitPrice;
            orderItem.PricebookEntryId = priceBookEntry.Id;
        }
    }
}