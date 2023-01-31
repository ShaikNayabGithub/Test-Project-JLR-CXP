public class Vista_RequestToRecordGroup_Adapter {
	/*public List<Vista_RecordGroup> Adapt(List<Vista_Request__c> requests) 
    {
        List<Vista_RecordGroup> recordGroups = new List<Vista_RecordGroup>();
        for(Vista_Request__c request : requests) {
            if(request.Vehicle_Orders__c == null) { continue; }
            List<Vista_OrderService.VehicleOrder> vehicleOrders = (List<Vista_OrderService.VehicleOrder>)system.JSON.deserialize(request.Vehicle_Orders__c, List<Vista_OrderService.VehicleOrder>.class);
            
            for(Vista_OrderService.VehicleOrder vehicleOrder : vehicleOrders) {
                Vista_RecordGroup recordGroup = new Vista_RecordGroup();
                recordGroup.VistaVehicleOrder = vehicleOrder;
                recordGroup.Request = request;
            
            	recordGroups.add(recordGroup);
            }
        }
		return groupList;
    }
    
    @TestVisible private List<Vista_OrderService.VehicleOrder> ParseVehicleOrderFromJSON(string jsonString)
    {
        system.debug(jsonString);
        List<Vista_OrderService.VehicleOrder> newOrder  = (List<Vista_OrderService.VehicleOrder>)system.JSON.deserialize(jsonString, List<Vista_OrderService.VehicleOrder>.class);
        System.debug(newOrder);
        return newOrder;
    }
    
    @TestVisible private Vista_RecordGroup GetRecordGroupFromVehicleOrder(Vista_OrderService.VehicleOrder newOrder, Vista_Request__c vistaReq)
    {
        Vista_RecordGroup newRecGroup = new Vista_RecordGroup();
        newRecGroup.VistaVehicleOrder = newOrder;
        newRecGroup.request = vistaReq;
        
        return newRecGroup;
    }*/
}