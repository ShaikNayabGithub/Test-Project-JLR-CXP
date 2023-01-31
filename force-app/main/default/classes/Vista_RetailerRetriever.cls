public class Vista_RetailerRetriever implements Vista_EntityRetriever_I {
    public void Retrieve(Vista_RequestCollection requestCollection)
    {
        if(requestCollection.Retailers == null) {
            requestCollection.Retailers = new Map<String, Account>();
        }

        Set<String> dealerCodes = new Set<String>();
        String dealerCode;
        for(List<Vista_RecordGroup> recordGroupList : requestCollection.RecordGroups.values()) {
            for(Vista_RecordGroup recordGroup : recordGroupList) {
                if(String.isEmpty(recordGroup.VistaVehicleOrder.Distribution.DistributionChannel.PartnerUniqueID)) continue;
                
              
                if(recordGroup.VistaVehicleOrder.Distribution.DistributionChannel.PartnerUniqueID!=null)
                    if(Dealer_Code_Override__c.getInstance(recordGroup.VistaVehicleOrder.Distribution.DistributionChannel.PartnerUniqueID)!=null)
                        dealerCode=Dealer_Code_Override__c.getInstance(recordGroup.VistaVehicleOrder.Distribution.DistributionChannel.PartnerUniqueID).new_dealer_code__c;
                
                if(dealerCode!=null && dealerCode!='')
                    dealerCodes.add(dealerCode);
                else
                
                    dealerCodes.add(recordGroup.VistaVehicleOrder.Distribution.DistributionChannel.PartnerUniqueID);
                
            }
        }

        for(Account retailer : [SELECT Id, Primary_Dealer_Code__c, Record_Sub_Type__c, ParentId FROM Account 
                WHERE Primary_Dealer_Code__c IN: dealerCodes]) {
            requestCollection.Retailers.put(retailer.Primary_Dealer_Code__c, retailer);
        }
    }
}