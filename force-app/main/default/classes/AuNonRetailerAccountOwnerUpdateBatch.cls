global class AuNonRetailerAccountOwnerUpdateBatch implements Database.Batchable<sObject>{
    
    public string queryString;
    public string newOwnerId;
    
    public AuNonRetailerAccountOwnerUpdateBatch(string queryString, string newOwnerId)
    {
       this.queryString=queryString; 
       this.newOwnerId=newOwnerId;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        if(queryString==null || string.isEmpty(queryString) || string.isBlank(queryString) 
           || newOwnerId==null || string.isEmpty(newOwnerId) || string.isBlank(newOwnerId))
            system.abortJob(bc.getJobId());
        return Database.getQueryLocator(queryString);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> sObjects) {
        for(sObject singleObj :sObjects)
        {
           	singleObj.put('Ownerid',newOwnerId);
        }
        
        if(!sObjects.isEmpty())
            database.update(sObjects,false);
        
    }   
    
    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations like sending email
    }
}