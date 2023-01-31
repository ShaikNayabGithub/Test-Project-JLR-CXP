public class CSVDataCollectionUtilities {
    public static Set<String> GetUniqueValues(String fieldName, CSVDataCollection csvData)
    {
        Set<String> columnValues = new Set<String>();
        Integer columnIndex=null;
        Integer vinColumn=null;
        Integer dateColumn=null;
      
        if(csvData!=null)
            if(csvData.ColumnIndexesByFieldName!=null){
                columnIndex = csvData.ColumnIndexesByFieldName.get(fieldName);
                vinColumn=csvData.ColumnIndexesByFieldName.get(ServiceUpload_Processor.VIN);
                dateColumn=csvData.ColumnIndexesByFieldName.get(ServiceUpload_Processor.SERVICE_REPAIR_DATE);
       
            }    
        
        if(columnIndex == null) return columnValues;

        for(List<String> row : csvData.LinesByRowIndex.Values()) {
            String columnValue = row[columnIndex];
            
            //ignore noemail@contract.com to reduce unnecesary amount of duplicated records
            if((columnValue.containsignorecase('noemail@contract.com') || columnValue.containsignorecase('witheld@contract.com') )&& fieldName=='Email')
            {
                columnValue=null;
              
            }
    
            //When they dont provide a repair order number we concatenate the VIN and the Service repair date to generate an id
            if(String.isBlank(columnValue) && fieldName==ServiceUpload_Processor.REPAIR_ORDER_NUMBER)
            {
                columnValue = row[vinColumn]+row[dateColumn];
                columnValues.add(columnValue.replaceAll( '\\s+', ''));    
            }
            else
            if(String.isNotBlank(columnValue)) {
                columnValues.add(columnValue);
            }
        }

        return columnValues;
    }
    
     public static List<String> GetAllValues(String fieldName, CSVDataCollection csvData)
    {
        List<String> columnValues = new List<String>();

        Integer columnIndex = csvData.ColumnIndexesByFieldName.get(fieldName);
        if(columnIndex == null) return columnValues;

        for(List<String> row : csvData.LinesByRowIndex.Values()) {
            String columnValue = row[columnIndex];

            if(String.isNotBlank(columnValue)) {
                columnValues.add(columnValue);
            }
        }

        return columnValues;
    }


    public static String GetColumnValue(CSVDataCollection dataCollection,
            String columnHeader, List<String> rowData)
    {
        
        Integer mileageIndex=null;
            if(dataCollection!=null)
                if(dataCollection.ColumnIndexesByFieldName!=null)
                    mileageIndex = dataCollection.ColumnIndexesByFieldName.get(columnHeader);
            
        if(mileageIndex == null) return null;

        return rowData[mileageIndex];
    }

    public static Map<String, Set<Integer>> MapRowIndexByColumnValue(String columnName, CSVDataCollection csvData)
    {
        Map<String, Set<Integer>> rowIndexesByValue = new Map<String, Set<Integer>>();
        String columnValue;
        
        if(csvData!=null)
            if(csvData.LinesByRowIndex!=null)
                for(Integer rowIndex : csvData.LinesByRowIndex.keySet()) {
                    List<String> rowData = csvData.LinesByRowIndex.get(rowIndex);
           
                    if(csvData!=null)
                        columnValue = CSVDataCollectionUtilities.GetColumnValue(csvData, columnName, rowData);
           
                    if(String.IsEmpty(columnValue)) continue;
                    
                    if(columnName.toLowerCase()=='email')
                        columnValue=columnValue.toLowerCase();
                        
                    Set<Integer> rowIndexes = rowIndexesByValue.get(columnValue);
                    if(rowIndexes == null) {
                        rowIndexes = new Set<Integer>();
                        rowIndexesByValue.put(columnValue, rowIndexes);
                    }
                    
                    rowIndexes.add(rowIndex);
                }

        return rowIndexesByValue;
    }
    
    public static String getSalutationValue(String salutationFromCSV){
    
        Schema.DescribeFieldResult fieldResult = Account.Salutation.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        List<String>salutationList=new List<String>();
        
        for( Schema.PicklistEntry f : ple){
          salutationList.add(f.getLabel());
        }
        
        for(String salutation:salutationList){
        
            if(salutation.contains(salutationFromCSV)==true)
                return salutation;    
        }
        
    return '';    
    }     
}