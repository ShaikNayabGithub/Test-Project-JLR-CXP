public without sharing  class RDAControllerSystem {
    
    public  List<RDA__c> getRDAsRelatedToAssets(List<Asset> assets ){
       System.debug('RDAControllerSystem assets');
              System.debug(assets);
        Set<Id> assetIds = new Set<Id>();
         Set<Id> assetIdsWithRDA = new Set<Id>();
        For(Asset ass : assets){
            assetIds.add(ass.id);
        }
       return   [SELECT asset__c, ID, RecordTypeId FROM Rda__c  WHERE Submitted_Status__c != 'Cancelled' AND Asset__c in  :assetIds limit 100];
     
       
    }

}