public class CSVUpload_PairedListPopulator {
    public void PopulateLists(CSVUpload_PairedList insertList, CSVUpload_PairedList updateList, 
            Map<Integer, SObject> recordMap, Map<Integer, CSVRowStatus> lineStatusesByRowIndex)
    {
       
       Account account;
       Set<String> accountTracker=new Set<String>();
       String type;
       Id accountId;
       boolean isAccount;
       String phone;
       
       
        for(Integer rowIndex : recordMap.keySet()) {
            CSVRowStatus rowStatus = lineStatusesByRowIndex.get(rowIndex);
            if(rowStatus != null && rowStatus.HasErrored == true) continue;
            
          // type=recordMap.get(rowIndex).getSObjectType().getDescribe().getName();
            
          // if(type=='Account'){
            //   account=(Account)recordMap.get(rowIndex);
              // phone=account.phone;
               //}
           
            //System.debug('this is the value account in pairlistpopulator: '+account);
           // System.debug('this is the type in pairelistpopulator: '+type);
            CSVUpload_PairedList listToAddTo = insertList;
           
                if(String.isNotEmpty(recordMap.get(rowIndex).Id))
                    listToAddTo = updateList;
                
           //      if(type!='Account' || (type=='Account' && !String.isBlank(phone) && !accountTracker.contains(phone)))
            //{
                   // if(!String.isBlank(phone) && type=='Account' && !accountTracker.contains(phone))
                      //  accountTracker.add(phone);
                     //else
                      //if(!String.isBlank(phone) && type=='Account' && accountTracker.contains(phone))
                        //listToAddTo = updateList;
                    
                listToAddTo.RowIndexes.add(rowIndex);
                listToAddTo.Records.add(recordMap.get(rowIndex));
             //}
            
        }
    }
}