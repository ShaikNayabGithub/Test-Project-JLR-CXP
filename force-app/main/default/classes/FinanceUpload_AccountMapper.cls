public class FinanceUpload_AccountMapper {
    
    public void AddToCollection(List<Account> accounts, List<Contact> contacts,
                                List<Lead> leads, FinanceUpload_RecordCollection recordCollection)
    {
        
        Map<String, Set<Integer>> rowIndexesByEmail = CSVDataCollectionUtilities.MapRowIndexByColumnValue(
            FinanceUpload_Constants.EMAIL_COLUMN_HEADER, recordCollection.CSVDataCollection);
        Map<String, Set<Integer>> rowIndexesByPhone = CSVDataCollectionUtilities.MapRowIndexByColumnValue(
            FinanceUpload_Constants.PHONE_COLUMN_HEADER, recordCollection.CSVDataCollection);
        Map<String, Set<Integer>> rowIndexesByEntityId = CSVDataCollectionUtilities.MapRowIndexByColumnValue(
            FinanceUpload_Constants.LEGAL_ENTITY_ID, recordCollection.CSVDataCollection);
        Map<String, Set<Integer>> rowIndexesByMobilePhone = CSVDataCollectionUtilities.MapRowIndexByColumnValue(
            FinanceUpload_Constants.MOBILE_NUMBER, recordCollection.CSVDataCollection);
        
        for(Account account : accounts) {
            if(!String.isBlank(account.PersonEmail))
                this.AddToCollection(account, rowIndexesByEmail, account.PersonEmail.toLowerCase(), recordCollection);
            
            if(!String.isBlank(account.Retailer_Email__c))
                this.AddToCollection(account, rowIndexesByEmail, account.Retailer_Email__c.toLowerCase(), recordCollection);
            if(!String.isBlank(account.Email2__pc))
                this.AddToCollection(account, rowIndexesByEmail, account.Email2__pc.toLowerCase(), recordCollection);
            
            if(!String.isBlank(account.Email3__pc))
                this.AddToCollection(account, rowIndexesByEmail, account.Email3__pc.toLowerCase(), recordCollection);
            
            this.AddToCollection(account, rowIndexesByPhone, account.PersonHomePhone, recordCollection);
            this.AddToCollection(account, rowIndexesByPhone, account.PersonMobilePhone, recordCollection);
            this.AddToCollection(account, rowIndexesByPhone, account.PersonOtherPhone, recordCollection);
            this.AddToCollection(account, rowIndexesByPhone, account.Phone, recordCollection);
            this.AddToCollection(account, rowIndexesByMobilePhone, account.PersonMobilePhone, recordCollection);
            this.AddToCollection(account, rowIndexesByEntityId , account.LegalEntityID__c, recordCollection);
        }
        
        for(Contact contact : contacts) {
            if(!String.isBlank(contact.Email))
                this.AddToCollection(contact.Account, rowIndexesByEmail, contact.Email.toLowerCase(), recordCollection);
            
            if(!String.isBlank(contact.Email2__c))    
                this.AddToCollection(contact.Account, rowIndexesByEmail, contact.Email2__c.toLowerCase(), recordCollection);
            
            if(!String.isBlank(contact.Email3__c))        
                this.AddToCollection(contact.Account, rowIndexesByEmail, contact.Email3__c.toLowerCase(), recordCollection);
            
            this.AddToCollection(contact.Account, rowIndexesByPhone, contact.HomePhone, recordCollection);
            this.AddToCollection(contact.Account, rowIndexesByPhone, contact.MobilePhone, recordCollection);
            this.AddToCollection(contact.Account, rowIndexesByPhone, contact.OtherPhone, recordCollection);
            this.AddToCollection(contact.Account, rowIndexesByPhone, contact.Phone, recordCollection);
            this.AddToCollection(contact.Account, rowIndexesByPhone, contact.AssistantPhone , recordCollection);
        }
        
        for(Lead lead : leads) {
            this.AddToCollection(lead.Account__r, rowIndexesByEmail, lead.Email, recordCollection);
            this.AddToCollection(lead.Account__r, rowIndexesByEmail, lead.Email_Address_2__c, recordCollection);
            this.AddToCollection(lead.Account__r, rowIndexesByEmail, lead.Email_Address_3__c, recordCollection);
            this.AddToCollection(lead.Account__r, rowIndexesByPhone, lead.MobilePhone, recordCollection);
            this.AddToCollection(lead.Account__r, rowIndexesByPhone, lead.Other_Phone__c, recordCollection);
            this.AddToCollection(lead.Account__r, rowIndexesByPhone, lead.Phone, recordCollection);
        }
        
    }
    
    private void AddToCollection(Account account, Map<String, Set<Integer>> indexMap, String key,
                                 FinanceUpload_RecordCollection recordCollection)
    {
        
        if(account == null) return;
        Set<Integer> rowIndexes = indexMap.get(key);
        
        this.AddToCollection(account, rowIndexes, recordCollection);
        
    }
    
    private void AddToCollection(Account account, Set<Integer> rowIndexes, 
                                 FinanceUpload_RecordCollection recordCollection)
    {
        
        if(rowIndexes == null) return;
        
        for(Integer rowIndex : rowIndexes) {
            
            account accFromRow=recordCollection.AccountsByRowId.get(rowIndex);
            Asset rowAsset= recordCollection.AssetsByRowId.get(rowIndex);
            
            if(recordCollection.AccountsByRowId.ContainsKey(rowIndex)){
                
                if(accFromRow!=null && account!=null)
                {    if(accFromRow.id!=account.id )
                {
                    
                    if(account.recordtypeid!=SObjectUtilities.RecordTypes.get('Account').get('Individual_Golden_Record').Id 
                       && account.recordtypeid!=SObjectUtilities.RecordTypes.get('Account').get('Corporate_Golden_Record').Id  
                       && (accFromRow.recordtypeid==SObjectUtilities.RecordTypes.get('Account').get('Individual_Golden_Record').Id
                           || accFromRow.recordtypeid==SObjectUtilities.RecordTypes.get('Account').get('Corporate_Golden_Record').Id))
                    {
                        
                        
                        account=checkIfValidRetailer(account,accFromRow,rowAsset,recordCollection);
                        recordCollection.AccountsByRowId.put(rowIndex, account);                
                        
                        
                    }
                    else
                        if( accFromRow.recordtypeid!=SObjectUtilities.RecordTypes.get('Account').get('Individual_Golden_Record').Id
                           &&  accFromRow.recordtypeid!=SObjectUtilities.RecordTypes.get('Account').get('Corporate_Golden_Record').Id
                           && (account.recordtypeid==SObjectUtilities.RecordTypes.get('Account').get('Individual').Id 
                               || account.recordtypeid==SObjectUtilities.RecordTypes.get('Account').get('Corporate').Id))
                        
                    {
                        
                        account=checkIfValidRetailer(account,accFromRow,rowAsset,recordCollection);
                        recordCollection.AccountsByRowId.put(rowIndex, account);               
                        
                    }
                    
                    
                    
                }   
                 
                }
            }                  
            else{
                
                account=checkIfValidRetailer(account,accFromRow,rowAsset,recordCollection);
                
                if(account != null
                   && account.recordtypeid != null
                   && SObjectUtilities.RecordTypes != null
                   && SObjectUtilities.RecordTypes.get('Account') != null
                   && SObjectUtilities.RecordTypes.get('Account').get('Individual_Golden_Record') != null
                   && SObjectUtilities.RecordTypes.get('Account').get('Corporate_Golden_Record') != null
                   && SObjectUtilities.RecordTypes.get('Account').get('Individual_Golden_Record').Id != null
                   && SObjectUtilities.RecordTypes.get('Account').get('Corporate_Golden_Record').Id != null
                   && account.recordtypeid!=SObjectUtilities.RecordTypes.get('Account').get('Individual_Golden_Record').Id
                   && account.recordtypeid!=SObjectUtilities.RecordTypes.get('Account').get('Corporate_Golden_Record').Id){
                    recordCollection.AccountsByRowId.put(rowIndex, account);                
                   }
                
            }
            
        }//ends loop
        
    }
    
    
    private account checkIfValidRetailer(account account,Account accFromRow,asset veh,FinanceUpload_RecordCollection rc){
        
        id assetRetailerId;
        id accRetailerid;
        
        if(veh!=null){
            if(veh.account.recordtypeid==SObjectUtilities.RecordTypes.get('Account').get('Retailer').Id)
                assetRetailerId=veh.accountid;
            else
                assetRetailerId=rc.mapAssetIdToRetailerId.get(veh.id);
        }  
        
        accRetailerid=rc.mapAccountIdToRetailerId.get(account.id);
        
        if(assetRetailerId==accRetailerId)
            return account;      
        else 
            return accFromRow;
        
    }
}