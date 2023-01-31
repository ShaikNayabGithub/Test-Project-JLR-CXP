public class CSVUpload_ErrorProcessor {
    public Integer ProcessErrors(Database.SaveResult[] insertResults, List<Integer> rowIndexes, 
            Map<Integer, CSVRowStatus> lineStatusesByRowIndex)
    {
        Integer recordsSaved = 0;

        for(Integer i = 0; i < insertResults.Size(); i++) {
            if(!insertResults[i].isSuccess()) {
                CSVRowStatus rowStatus = lineStatusesByRowIndex.get(rowIndexes[i]);
                if(rowStatus == null) {
                    rowStatus = new CSVRowStatus();
                    lineStatusesByRowIndex.put(rowIndexes[i], rowStatus);
                }
            
			
                Database.Error[] errors = insertResults[i].getErrors();
                
                for(Database.Error errorString : errors) {
                
                    if(!String.isBlank(rowStatus.Message))
                        rowStatus.Message='Please review the row: '+rowIndexes[i]+' '+rowStatus.Message;
                    else
                    if(errorString.getstatuscode()==System.StatusCode.REQUIRED_FIELD_MISSING && findFalueInList(errorString.getFields(),'AccountId'))
                        rowStatus.Message='No Account or Asset found';
                    else
                    if(errorString.getstatuscode()==System.StatusCode.REQUIRED_FIELD_MISSING && findFalueInList(errorString.getFields(),'Asset__c'))
                        rowStatus.Message='No Asset found';
                    else    
                        rowStatus.Message='Please review the row: '+rowIndexes[i]+' '+errorString.getMessage();    
                        
                }

                rowStatus.HasErrored = true;
            } else {
                recordsSaved++;
            }
        }

        return recordsSaved;
    }
    
    boolean findFalueInList(List<String> listValues,String key){
    
        boolean found=false;
        
        for(String value: listValues){
            if(value==key)
                found=true;
        
        }
        
    return found;
    }
       
}