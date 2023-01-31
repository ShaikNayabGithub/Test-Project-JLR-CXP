global class Product_ModelYearSetter_Batch implements Schedulable, Database.Batchable<sObject>, database.Stateful {
    //CXPD-2352 - Batch class for populating Model Year on Product object
    global void execute(SchedulableContext SC) {
        Database.executeBatch(new Product_ModelYearSetter_Batch(), 5);
    }
    Id derivativeRecId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Derivative').getRecordTypeId();
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query;
        query = 'SELECT Id, Model_Year__c, Model_Year_Code__c FROM Product2 WHERE RecordTypeId=:derivativeRecId AND isActive=true ORDER BY CreatedDate DESC';
        //query = 'SELECT Id, Model_Year__c, Model_Year_Code__c FROM Product2 where Id=\'01t1o00000BEbp9AAD\' ';
        return database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Product2> productAssetList){
        System.debug('productAssetList: '+productAssetList);
        List<Product2> prodUpdateList = new List<Product2>();
        Set<Id> prodIdSet = new Set<Id>();
        if(productAssetList!=NULL){
            for(Product2 prod: productAssetList){
                prodIdSet.add(prod.Id);
            }
            
            List<Asset> assetList = new List<Asset>();
            Map<Id,List<Asset>> assetMap = new Map<Id,List<Asset>>();
            //fetching related assets
            assetList = [SELECT Id, Product2Id, Model_Year__c, Model_Year_Code__c, CreatedDate FROM Asset WHERE Product2Id=:prodIdSet and Model_Year__c!=NULL];
            System.debug('assetList: '+assetList);
            for(Product2 prod: productAssetList){
                List<Asset> assetLst1 = new List<Asset>();
                for(Asset asset: assetList){
                    if(asset.Product2Id == prod.Id) assetLst1.add(asset);
                }
                assetMap.put(prod.Id, assetLst1);
            }
            
            System.debug('assetMap: '+assetMap);
            if(productAssetList!=NULL) prodUpdateList = ModelYearSetter(productAssetList, assetMap);
            System.debug('prodUpdateList: '+prodUpdateList);
            
            if(prodUpdateList!=NULL) update prodUpdateList;
            System.debug('Product List Updated: '+prodUpdateList);
        }
    }
    
    global void finish(Database.BatchableContext BC){
    }
    
    private List<Product2> ModelYearSetter(List<Product2> prodList, Map<Id, List<Asset>> assetMap){
        List<Product2> updateProdList = new List<Product2>();
        
        for(Product2 prod: prodList){
            String prodModelYear = prod.Model_Year__c;
            String prodModelYearCode = prod.Model_Year_Code__c;
            System.debug('prodModelYear: '+prodModelYear);
            List<Asset> assetList = new List<Asset>();
            if(assetMap.containsKey(prod.Id)) assetList.addAll(assetMap.get(prod.Id));
            Asset recentAsset = new Asset();
            System.debug('assetList: '+assetList);
            
            List<Asset> assetsToProcess = new List<Asset>();
            for(Asset ass: assetList){
                if(ass.Model_Year_Code__c!=NULL){
                    assetsToProcess.add(ass);
                }
            }
            if(assetsToProcess.isEmpty()) assetsToProcess.addAll(assetList);
            
            DateTime createdDateValue;
            for(Asset cAsset: assetsToProcess){
                System.debug('cAsset: '+cAsset);
                //fetching most recent asset of each product
                if(createdDateValue!=NULL && createdDateValue < cAsset.CreatedDate) {
                    createdDateValue = cAsset.CreatedDate;
                    recentAsset = cAsset;
                }
                else if(createdDateValue==NULL) {
                    createdDateValue = cAsset.CreatedDate;
                    recentAsset = cAsset;
                }
                System.debug('createdDateValue: '+createdDateValue);
            }
            System.debug('recentAsset: '+recentAsset);
            
            if(recentAsset.Model_Year__c!=NULL && recentAsset.Model_Year__c!=prodModelYear){
                prod.Model_Year__c = recentAsset.Model_Year__c;
            }
            if(recentAsset.Model_Year_Code__c!=NULL && recentAsset.Model_Year_Code__c!=prodModelYearCode){
                prod.Model_Year_Code__c = recentAsset.Model_Year_Code__c;
            }
            
            if((prod.Model_Year__c!=NULL && prod.Model_Year__c!=prodModelYear) || (prod.Model_Year_Code__c!=NULL && prod.Model_Year_Code__c!=prodModelYearCode))
                updateProdList.add(prod);
            
        }
        
        if(updateProdList!=NULL) return updateProdList;
        else return null;
    }
    
}