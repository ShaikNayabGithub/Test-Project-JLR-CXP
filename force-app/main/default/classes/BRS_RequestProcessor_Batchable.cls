global class BRS_RequestProcessor_Batchable implements Database.batchable<SObject>, Database.AllowsCallouts {
    private final BRS_FeatureCreator featureCreator;
    private final BRS_RequestPostProcessor requestPostProcessor;
    
    
    public BRS_RequestProcessor_Batchable(BRS_FeatureCreator featureCreator, 
            BRS_RequestPostProcessor requestPostProcessor)
    {
        this.featureCreator = featureCreator;
        this.requestPostProcessor = requestPostProcessor;
    }


    global Database.QueryLocator start(Database.BatchableContext info)
    {
        return Database.getQueryLocator([Select Name, Market__c From BRS_Request__c 
            Where Status__c =: BRSRequestUtilities.UnprocessedStatus ORDER BY CreatedDate]);
    }
    
    
    global void execute(Database.BatchableContext info, List<SObject> sobjectList)
    {
        Set<String> serials = SObjectUtilities.GetFieldValues(sobjectList, 
                BRS_Request__c.Name.getDescribe().getName());
        Set<String> markets = SObjectUtilities.GetFieldValues(sobjectList, 
                BRS_Request__c.Market__c.getDescribe().getName());

        List<BRS_Request__c> requests = [SELECT Id, Name, Brand__c, Currencies__c, Derivatives__c, 
                Features__c, Market_Description__c, Models__c, Status__c, Market__c FROM BRS_Request__c 
                WHERE Name IN:serials AND Status__c =: BRSRequestUtilities.UnprocessedStatus 
                AND Market__c IN: markets];
        if(requests.size() == 0) return;

        
        try {
            this.featureCreator.Create(requests);
        }
        catch (Exception e)
        {
            for(BRS_Request__c request : requests) {
                request.Status__c = BRSRequestUtilities.FailureStatus;
                request.Error_Message__c += (e.getMessage() + '; ' + e.getStackTraceString() + '; ');
            }
        }
        
        this.requestPostProcessor.UpdateRequests(requests);
    }


    global void finish(Database.BatchableContext info) { }
}