public class FinanceUpload_ContractBuilder implements FinanceUpload_SObjectBuilder_I {

    public Contract Build(Integer csvRowIndex, FinanceUpload_RecordCollection recordCollection,Map<String,Id>mapIdAccountToIdUser,Map<String,Account>mapStringtoAccount,Map<String,Service_Data__c> mapStringToService)
    {
        Contract contract = recordCollection.ContractsByRowId.get(csvRowIndex);
        String message;
        
        List<String> rowData = null;
       
        if(recordCollection!=null)
            if(recordCollection.CSVDataCollection!=null)
                rowdata=recordCollection.CSVDataCollection.LinesByRowIndex.get(csvRowIndex);

        String type= String.valueOf(CSVDataCollectionUtilities.GetColumnValue(recordCollection.CSVDataCollection,'Vehicle Type', rowData));
        
        Account account = recordCollection.AccountsByRowId.get(csvRowIndex);     
              
        Asset asset = recordCollection.AssetsByRowId.get(csvRowIndex);
     
        //Finance upload v1.2
        if(asset!=null && type!=null && !type.containsIgnoreCase('new') && asset.Account.RecordType.DeveloperName == 'Retailer'){
            account=null;
            message='APO Vehicle, No Customer Match';
        }
        else
        if(asset!=null && account==null){
            if(asset.Account.RecordType.DeveloperName == 'Retailer'){
       
                account=asset.account;
            
            }    
        }
       
       if(contract!=null && account!=null)
           contract.accountId=account.id;
        else
        if(contract == null) {
            contract = new Contract(Contract_Status__c = 'Unknown');
            contract.message__c=message;
            
            if(account!=null)
                contract.AccountId = account.Id;
                else
                if(asset!=null)
                {
                    contract.accountId=asset.account.owner.accountid;
                }    
            
            if(asset!=null)
                contract.Asset__c = asset.Id;
            
            contract.ownerid=FinanceUpload_Constants.SYSTEM_USER;
            
            if(recordCollection!=null && recordCollection.CSVDataCollection!=null && recordCollection.CSVDataCollection.LinesByRowIndex!=null)
            {
                rowData=recordCollection.CSVDataCollection.LinesByRowIndex.get(csvRowIndex);
                 
                String brandName = CSVDataCollectionUtilities.GetColumnValue(recordCollection.CSVDataCollection, 
                        FinanceUpload_Constants.BRAND_COLUMN_HEADER, rowData);
                contract.Brand__c = VehicleSpecificationUtilities.Brands.get(brandName.toLowerCase()).Id;
          
                recordCollection.ContractsByRowId.put(csvRowIndex, contract);
            }    
            
        }
        
            if(asset!=null)
                if(contract!=null)
                    if(contract.Asset__c==null)
                        contract.Asset__c = asset.Id;
                        
        return contract;
    }
    
}