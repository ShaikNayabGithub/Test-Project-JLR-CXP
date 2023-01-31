public class Asset_ProductSetter {
    

    public void SetProductOnCreate(List<Asset> assets)
    {       
        for(Asset asset : assets) {         
                asset.Product2Id = asset.Derivative__c;
        }
    }

    public void SetProductOnUpdate(Map<Id,Asset> oldAssets, List<Asset> newAssets)
    {       
        for(Asset asset : newAssets) {
            Asset oldAsset = oldAssets.get(asset.id);
            Boolean isProductChanged = asset.Product2Id != oldAsset.Product2Id;
            Boolean isDerivitiveChanged = asset.Derivative__c != oldAsset.Derivative__c;

            if(isProductChanged){
                //asset.Product2Id.addError(System.Label.Asset_Product_Readonly_Error); //LB removed to allow vista messages to be processed
                continue;
            }

            if(isDerivitiveChanged){
                asset.Product2Id = asset.Derivative__c;
            }
        }
    }
}