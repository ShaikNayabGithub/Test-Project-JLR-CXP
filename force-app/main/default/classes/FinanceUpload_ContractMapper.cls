public class FinanceUpload_ContractMapper {
    public void AddToCollection(List<Contract> contracts, FinanceUpload_RecordCollection recordCollection)
    {
        Map<String, Set<Integer>> rowIndexesByFinanceReference = CSVDataCollectionUtilities.MapRowIndexByColumnValue(
                FinanceUpload_Constants.FINANCE_REFERENCE_COLUMN_HEADER, recordCollection.CSVDataCollection);
        Set<Integer> rowIndexes=new Set<Integer>();
        for(Contract contract : contracts) {
            
            if(rowIndexesByFinanceReference!=null  && contract!=null)
       
                rowIndexes = rowIndexesByFinanceReference.get(contract.Finance_Reference__c);
            
            if(rowIndexes!=null)
                for(Integer rowIndex : rowIndexes) {
                
                  //if(contract.Contract_Status__c!='Cancelled' && contract.Contract_Status__c!='Closed' && contract.Contract_Status__c!='Early Settled')
                    recordCollection.ContractsByRowId.put(rowIndex, contract);
                }
        }
    }
}