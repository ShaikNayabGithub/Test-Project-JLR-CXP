public class WrittenOffAssets {
    
    public void writtenOffAsset(List<Asset> newAssets, Map<Id, Asset> oldAssets){
        List<Asset> tmpAssets = new List<Asset>();
        for(Asset asset : newAssets){
            if(asset.Status == 'Written Off'){
                if(asset.Status != oldAssets.get(asset.id).Status){
                    tmpAssets.add(asset);
                }
            }
        }
        if(tmpAssets.size() > 0){
            UpdateExistingAsset(tmpAssets);
        }  
    }
    
    private void UpdateExistingAsset(List<Asset> currentAssets) {
        String errors = '';
        Set<id> accountsIds=new set<id>();
        String countryIsoCode ='';
        String checkAcctISO;
        String isoCode='';
        for(asset asset:currentAssets){
            accountsIds.add(asset.AccountId);
        }
        Map<String, Id> countryWrittenOffMap = new Map<String, Id>();
        //WHERE (createddate > 2018-11-12T00:00:00.000z AND RecordType.DeveloperName = 'Retailer' AND Country_ISO_Code__c != null AND Name LIKE '%Written Off Vehicles%')
        //WHERE Id IN :accountsIds
        List<Account> allAccounts = [SELECT Id,Name,Country_ISO_Code__c,Country_ISO_Code__pc, CreatedDate, RecordType.DeveloperName FROM Account WHERE (CreatedDate > 2018-11-12T00:00:00.000z 
                         AND RecordType.DeveloperName = 'Retailer' AND Country_ISO_Code__c != null AND Name LIKE '%Written Off Vehicles%') OR Id IN :accountsIds];
        Date november12 = Date.newInstance(2018, 11, 12);
        for(Account a : allAccounts){
            if(a.CreatedDate > november12 && a.RecordType.DeveloperName == 'Retailer' && a.Country_ISO_Code__c != null && a.Name.toUpperCase().contains('WRITTEN OFF VEHICLES')){ 
                countryWrittenOffMap.put(a.Country_ISO_Code__c, a.Id);
            }
        }
        Map<Id, String> accountIsoCodeMap = new Map<Id, String>(); //Assets Account Id against Country ISO Code
        for(Account assetAcc : allAccounts){
            if(accountsIds.contains(assetAcc.Id)){
                if(assetAcc.Country_Iso_Code__c != null){
                    accountIsoCodeMap.put(assetAcc.Id, assetAcc.Country_Iso_Code__c);
                }
                else if(assetAcc.Country_Iso_Code__pc != null){
                    accountIsoCodeMap.put(assetAcc.Id, assetAcc.Country_Iso_Code__pc);
                }
            }
        }
        for(asset ass :currentAssets){
            if(ass.AccountId != null){
                if(accountIsoCodeMap.containsKey(ass.AccountId)){
                    isoCode = accountIsoCodeMap.get(ass.AccountId);
                    if(countryWrittenOffMap.containsKey(isoCode)){
                        ass.AccountId = countryWrittenOffMap.get(isoCode);
                    }
                }
            }
        }
        
    }     
}