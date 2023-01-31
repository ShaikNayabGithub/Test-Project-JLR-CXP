public with sharing class AssetPriceUpdaterTriggerHandler { 

    public void findAndUpdateAssets(List<AssetPriceUpdater__c> records) {  
    
        List<String> vins = new List<String>();
        for (AssetPriceUpdater__c a : records) vins.add(a.name);
        
        List<Asset> assetsToUpdate = [select id, local_price__c, name from asset where name in : vins];
        
        for (Asset a : assetsToUpdate) {
            for (AssetPriceUpdater__c u : records) {
                if (u.name == a.name) {
                    a.local_price__c = u.localprice__c;
                }
            }
        }
         
        if (!assetsToUpdate.isEmpty()) {
            Database.SaveResult[] srList = Database.update(assetsToUpdate, false);
            Integer i = -1;
            for (Database.SaveResult sr : srList) {
                i++;
                if (!sr.isSuccess()) { 
                    for(Database.Error err : sr.getErrors()) {
                        records[i].addError(err.getStatusCode() + ': ' + err.getMessage()); 
                    }
                }
            }
            //delete records; //clean up
        } 
           
    }

}