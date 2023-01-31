public class Vista_RequestToRequestCollection_Adapter {
    private static final Set<string> HANDLED_EVENT_CODES = new Set<string>{ Vista_EventCodes.HANDOVER, 
        Vista_EventCodes.DELETE_CODE, Vista_EventCodes.NONSPEC, Vista_EventCodes.SPECMEND, 
        Vista_EventCodes.CONFIRMOK, Vista_EventCodes.RETRY, Vista_EventCodes.DLRTAG, Vista_EventCodes.PLANNING,
        Vista_EventCodes.STATUS, Vista_EventCodes.SHIPPING,Vista_EventCodes.CANHDOVER,Vista_EventCodes.SECONDHDOVER,Vista_EventCodes.BMYUOK,Vista_EventCodes.HOLD,
        Vista_EventCodes.LIFECYCL,Vista_EventCodes.NEWORDER,Vista_EventCodes.NSCCPDDUPD,Vista_EventCodes.PULLXFER,Vista_EventCodes.REGISTRATI,Vista_EventCodes.UNCTRADE,Vista_EventCodes.VEHUPDT};
  
    public Vista_RequestCollection Adapt(List<Vista_Request__c> requests) 
    {
        Vista_RequestCollection requestCollection = new Vista_RequestCollection();
        requestCollection.RecordGroups = new Map<String, List<Vista_RecordGroup>>();

        for(Vista_Request__c request : requests) {
            if(request.Vehicle_Orders__c == null) { continue; }
            List<Vista_OrderService.VehicleOrder> vehicleOrders = (List<Vista_OrderService.VehicleOrder>)system.JSON.deserialize(request.Vehicle_Orders__c, List<Vista_OrderService.VehicleOrder>.class);
            
            Boolean containsHandledEvent = false;
            for(Vista_OrderService.VehicleOrder vehicleOrder : vehicleOrders) {
                if(!HANDLED_EVENT_CODES.contains(vehicleOrder.Eventcode)) {
                    request.Error_Log__c = request.Error_Log__c + '\n' + 'Unable to process Event Code supplied: ' +  vehicleOrder.EventCode;
                    continue;
                }
                containsHandledEvent = true;

                Vista_RecordGroup recordGroup = new Vista_RecordGroup();
                recordGroup.VistaVehicleOrder = vehicleOrder;
                recordGroup.Request = request;
                
                List<Vista_RecordGroup> orderRecordGroups = requestCollection.RecordGroups.get(vehicleOrder.MetaOrderNumber);
                if(orderRecordGroups == null) {
                    orderRecordGroups = new List<Vista_RecordGroup>();
                    requestCollection.RecordGroups.put(vehicleOrder.MetaOrderNumber, orderRecordGroups);
                }
                orderRecordGroups.add(recordGroup);
            }

            request.Status__c = 'Processed';
            if(!containsHandledEvent) {
                request.Status__c = 'Rejected';
            }
        }

        for(List<Vista_RecordGroup> orderRecordGroups : requestCollection.RecordGroups.values()) { 
            orderRecordGroups.sort(); 
        }

        return requestCollection;
    }
}