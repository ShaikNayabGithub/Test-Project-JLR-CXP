public class AssetOppUpdateHandler {
    
    public static void ProcessOpportunityHandoverUpdate(List<Asset> currentAssets, Map<Id, Asset> oldAssetMap){
        String countryIsoCodeLbl = Label.HandedOverDateLbel;
        List<String> countryIsoSet = countryIsoCodeLbl.split(',');
        set<Id> assetIdsSet = new set<Id>();
        Map<Id, Asset> assetHandoverMap = new Map<Id, Asset>();
        for(asset at : currentAssets){            
            if(at.Handover_Date__c != null
               && at.Handover_Date__c != oldAssetMap.get(at.Id).Handover_Date__c){
                   assetIdsSet.add(at.Id);
               }
        }
        
        
        if(assetIdsSet != null && countryIsoSet != null
           && !assetIdsSet.isEmpty() && !countryIsoSet.isEmpty()){
               for(Asset ast : [select id,account.Country_ISO_Code__c,Handover_Date__c from Asset where id in: assetIdsSet
                                AND account.Country_ISO_Code__c in: countryIsoSet]){
                                    assetHandoverMap.put(ast.Id,ast);
                                }
               
               
               if(assetHandoverMap != null
                  && !assetHandoverMap.isEmpty()){
                      
                      map<id,opportunity> oppUpdateMap = new map<id,opportunity>();
                      for(opportunitylineitem oli : [select id,Asset__c,Product2Id,opportunityid,opportunity.Name 
                                                     from 
                                                     opportunitylineitem 
                                                     where
                                                     Asset__c in:assetHandoverMap.keyset() AND 
                                                     Asset__c != null AND 
                                                     opportunityid != null]){
                                                         if(assetHandoverMap.containskey(oli.Asset__c)
                                                            && assetHandoverMap.get(oli.Asset__c) != null
                                                            && assetHandoverMap.get(oli.Asset__c).Handover_Date__c != null){
                                                                opportunity opp = new opportunity();
                                                                opp.id = oli.opportunityid;
                                                                opp.Handed_Over_Date__c = assetHandoverMap.get(oli.Asset__c).Handover_Date__c;
                                                                oppUpdateMap.put( opp.id,opp);
                                                            }
                                                     }
                      if(oppUpdateMap != null
                         && !oppUpdateMap.isEmpty()){
                             update oppUpdateMap.values();
                         }
                  }
           }
    }
}