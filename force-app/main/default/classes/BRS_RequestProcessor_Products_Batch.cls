global class BRS_RequestProcessor_Products_Batch implements Database.batchable<SObject>, Database.AllowsCallouts {
    private final BRS_ProductCreator productCreator;
    private final BRS_RequestPostProcessor requestPostProcessor;
    
    
    public BRS_RequestProcessor_Products_Batch(BRS_ProductCreator productCreator, 
            BRS_RequestPostProcessor requestPostProcessor)
    {
        this.productCreator = productCreator;
        this.requestPostProcessor = requestPostProcessor;
    }


    global Database.QueryLocator start(Database.BatchableContext info)
    {
        return Database.getQueryLocator([Select Name, Market__c From BRS_Request__c 
            Where Status__c =: BRSRequestUtilities.FeaturesAddedStatus ORDER BY CreatedDate]);
    }
    
    
    global void execute(Database.BatchableContext info, List<SObject> sobjectList)
    {
        Set<String> serials = SObjectUtilities.GetFieldValues(sobjectList, 
                BRS_Request__c.Name.getDescribe().getName());
        Set<String> markets = SObjectUtilities.GetFieldValues(sobjectList, 
                BRS_Request__c.Market__c.getDescribe().getName());

        List<BRS_Request__c> requests = [SELECT Id, Name, Brand__c, Currencies__c, Derivatives__c, 
                Features__c, Market_Description__c, Models__c, Status__c, Market__c FROM BRS_Request__c 
                WHERE Name IN:serials AND Status__c =: BRSRequestUtilities.FeaturesAddedStatus 
                AND Market__c IN: markets];
        if(requests.size() == 0) return;

        
        try {
            //very, very temporary, please, please cleanup!!!!!!!!!!!
            Map<String, String> modelsByNameMarket = new Map<String, String>();
            for(BRS_Request__c request : requests) {
                String key = request.Name + request.Market__c;
                if(String.isNotBlank(request.Models__c)) {
                    modelsByNameMarket.put(key, request.Models__c);
                }
            }

            for(BRS_Request__c request : requests) {
                String key = request.Name + request.Market__c;
                request.Models__c = modelsByNameMarket.get(key);
            }
            //////temp end
            this.productCreator.Create(requests);
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