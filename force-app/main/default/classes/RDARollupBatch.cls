global class RDARollupBatch implements Database.Batchable<sObject>, database.Stateful{
    private Set<Id> proccedAssetIdSet= New Set<Id>();
    Public boolean considerOldRec;
    
    public RDARollupBatch(boolean considerOldRec)
    {
        this.considerOldRec=considerOldRec;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute
        DateTime dt = System.Now().addMinutes(-65);
        String query =  'Select id,Asset__c from RDA__c where ';
            if(considerOldRec)
            query+='Asset__c !=null order by Asset__c';
        else
            query+='LastModifiedDate >=:dt AND Asset__c !=null order by Asset__c';  
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<RDA__c> rdaList) {
        asset updatedAsset;
        Map<Id,Asset> assetMapForUpdate= New Map<Id,Asset>();
        for(RDA__c rda:rdaList)
        {
            if(!proccedAssetIdSet.contains(rda.Asset__c))
            {
                assetMapForUpdate.put(rda.Asset__c, new asset(Id=rda.Asset__c,Non_Cancelled_RDA_Count__c=0));
                proccedAssetIdSet.add(rda.Asset__c);
            }
        }
        
        List<AggregateResult> assetCountLst= [ select count(id) cnt, 
                                              Asset__c 
                                              From RDA__c 
                                              where Asset__c IN:assetMapForUpdate.keySet()
                                              AND Submitted_Status__c !='Cancelled'
                                              group by Asset__c ];
        
        for(AggregateResult ag: assetCountLst)
        {
            updatedAsset=assetMapForUpdate.get((Id) ag.get('Asset__c'));
            updatedAsset.Non_Cancelled_RDA_Count__c=integer.valueOf(ag.get('cnt'));
            assetMapForUpdate.put((Id) ag.get('Asset__c'),updatedAsset);
        }
        
        if(!assetMapForUpdate.isEmpty())
            database.Update(assetMapForUpdate.values(),false);
    }
    
    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations like sending email
    }
}