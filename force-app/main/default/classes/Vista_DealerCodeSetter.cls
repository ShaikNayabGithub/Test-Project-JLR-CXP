public class Vista_DealerCodeSetter{
    
    private List<Vista_OrderService.ExportDetails> vistaOrders;
    private static Map<String,Dealer_Code_Override__c> dealerCodes = Dealer_Code_Override__c.getAll();
    
    public Vista_DealerCodeSetter (List<Vista_OrderService.ExportDetails> vistaOrders){
        this.vistaOrders = vistaOrders;
    }
    
    public List<Vista_OrderService.ExportDetails> updateDealerCodes(){
    
        for(Vista_OrderService.ExportDetails vistaOrder : vistaOrders)
        {
            String newDealerCode = getNewDealerCode(vistaOrder);
            if(string.isNotBlank(newDealerCode))   
            {            
                vistaOrder.VehicleOrders[0].Distribution.DistributionChannel.PartnerUniqueID = newDealerCode;
            }                   
        }
    
        return vistaOrders;
    }
    
    private String getNewDealerCode(Vista_OrderService.ExportDetails vistaOrder){
        if(vistaOrder.VehicleOrders == null || vistaOrder.VehicleOrders.size() == 0) return null;
        
        Vista_OrderService.VehicleOrder vehicleOrder =  vistaOrder.VehicleOrders[0];            
            
        if(vehicleOrder.Distribution == null || vehicleOrder.Distribution.DistributionChannel == null) return null; 
        
        String partnerDealerCode = vehicleOrder.Distribution.DistributionChannel.PartnerUniqueID;                   
        if(String.isNotBlank(partnerDealerCode) && dealerCodes.containsKey(partnerDealerCode))
        {
            return dealerCodes.get(partnerDealerCode).New_Dealer_Code__c;
        }  
        return null; 
    }
    
}