public class CSVUpload_SObjectUpserter {
    private final CSVUpload_PairedListPopulator pairedListPopulator;
    private final CSVUpload_ErrorProcessor errorProcessor;  
    String type;
    Sobject record;
    Account account;
    Asset asset;
    Contract contract;
    Service_data__c service;
    public map<String,Service_data__c>serviceDataByRepairOrder=new Map<String,service_data__c>();
    Database.SaveResult[] insertResults;
    
    public CSVUpload_SObjectUpserter(CSVUpload_PairedListPopulator pairedListPopulator,
            CSVUpload_ErrorProcessor errorProcessor)
    {
        this.pairedListPopulator = pairedListPopulator;
        this.errorProcessor = errorProcessor;
    }

    //DML doubled up as upsert does not support List<SObject> - only concrete classes
    public Database.SaveResult[] UpsertRecords(Map<Integer, SObject> recordsByRowIndex, 
            Map<Integer, CSVRowStatus> lineStatusesByRowIndex, Apex_Job__c apexJob,Map<String,account> mapPhoneToIdAccount)
    {
        CSVUpload_PairedList insertList = new CSVUpload_PairedList();
        CSVUpload_PairedList updateList = new CSVUpload_PairedList();
        integer i=0;

        this.pairedListPopulator.PopulateLists(insertList, updateList, recordsByRowIndex, lineStatusesByRowIndex);
        
        if(insertList.Records.Size() > 0) {
            
            insertResults = Database.Insert(insertList.Records, false);
                                       
            for (Database.SaveResult sr : insertResults ) {
            
                   record=insertList.Records.get(i);
                    
                    if(record!=null){
                        type=record.getSObjectType().getDescribe().getName();
                    }
                            
                if(!sr.isSuccess())
                {
                    if(type=='Contract')
                    {
                        contract=(Contract)record;
                        if(contract!=null)
                            if(!String.isBlank(contract.message__c))
                                lineStatusesByRowIndex.values()[i].message=contract.message__c;
                     
                    }
                    else
                     if(type=='Service_Data__c')
                    {
                     service=(Service_Data__c)record;
                        if(service!=null)
                            if(!String.isBlank(service.message__c))
                                lineStatusesByRowIndex.values()[i].message=service.message__c;
                     
                    
                    
                    }    
                }    
                else
                if (sr.isSuccess()) {
                    
                    if(type=='Contract')
                    {
                        contract=(Contract)record;
                        contract.id=sr.getId();
                        apexJob.Contracts_Inserted__c+=1;
                       
                    }
                                  
                i++;       
                }              
           } 
         
             apexJob.Records_Inserted__c += this.errorProcessor.ProcessErrors(insertResults, insertList.RowIndexes,  
                    lineStatusesByRowIndex);                      
                    
        }

        if(updateList.Records.Size() > 0) {
          
            updateList.Records=removeDuplicatedRecords(updateList.Records);
            Database.SaveResult[] updateResults = Database.Update(updateList.Records, false);
            apexJob.Records_Updated__c += this.errorProcessor.ProcessErrors(updateResults, updateList.RowIndexes,   
                    lineStatusesByRowIndex);
        }
        
        
     return insertResults;   
        
    }
    
    private List<Sobject> removeDuplicatedRecords(List<sobject> updateList){
    
        Set<sobject> myset = new Set<sobject>();
        List<sobject> result = new List<sobject>();
        myset.addAll(updateList);
        result.addAll(myset);
        
        return result;
    
    }
    
    
}