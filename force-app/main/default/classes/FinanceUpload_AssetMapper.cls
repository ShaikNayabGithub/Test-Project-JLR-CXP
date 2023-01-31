public class FinanceUpload_AssetMapper {
    public void AddToCollection(List<Asset> assets, FinanceUpload_RecordCollection recordCollection)
    {
        Map<String, Set<Integer>> rowIndexesByVIN = CSVDataCollectionUtilities.MapRowIndexByColumnValue(
                FinanceUpload_Constants.VIN_COLUMN_HEADER, recordCollection.CSVDataCollection);
        Map<String, Set<Integer>> rowIndexesByRegistration = CSVDataCollectionUtilities.MapRowIndexByColumnValue(
                FinanceUpload_Constants.REGISTRATION_COLUMN_HEADER, recordCollection.CSVDataCollection);

        for(Asset asset : assets) {
            Set<Integer> vinRowIndexes = rowIndexesByVIN.get(asset.VIN__c);
            Set<Integer> registrationRowIndexes = rowIndexesByRegistration.get(asset.Registration_Number__c);

            this.AddToCollection(asset, vinRowIndexes, recordCollection);
            this.AddToCollection(asset, registrationRowIndexes, recordCollection);
        }
    }


    private void AddToCollection(Asset asset, Set<Integer> rowIndexes, 
            FinanceUpload_RecordCollection recordCollection)
    {
        if(rowIndexes == null) return;

        for(Integer rowIndex : rowIndexes) {
            recordCollection.AssetsByRowId.put(rowIndex, asset);
            if(asset.Account != null && String.IsNotEmpty(asset.Account.Id) &&
                    asset.Account.RecordTypeId != SObjectUtilities.RecordTypes.get('Account').get('Retailer').Id) {
                //recordCollection.AccountsByRowId.put(rowIndex, asset.Account);   //THIS WAS COMMENTED TO GET THE ACCOUNT FROM THE CSV FILE AND NOT FROM THE ASSET
            }
        }
    }
}