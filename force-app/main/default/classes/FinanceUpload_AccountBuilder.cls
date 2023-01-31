public class FinanceUpload_AccountBuilder implements FinanceUpload_SObjectBuilder_I {
    public Account Build(Integer csvRowIndex, FinanceUpload_RecordCollection recordCollection,Map<String,Id>mapIdAccountToIdUser,Map<String,Account>mapStringtoAccount,Map<String,Service_Data__c> mapStringToService)
    {
        List<String> rowData = null;
        Account account;
        
        if(recordCollection!=null)
            if(recordCollection.CSVDataCollection!=null)
                if(recordCollection.CSVDataCollection.LinesByRowIndex!=null)
                {    
                    rowData =recordCollection.CSVDataCollection.LinesByRowIndex.get(csvRowIndex);
                    account = recordCollection.AccountsByRowId.get(csvRowIndex);
                   
                }    

        boolean accountFromDB=false;
        if(account != null){
            accountFromDB=true;
            return null;
              
        } 
         
             return null;
              
    }    
}