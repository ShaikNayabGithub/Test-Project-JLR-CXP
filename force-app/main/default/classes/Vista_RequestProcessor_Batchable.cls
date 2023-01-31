global class Vista_RequestProcessor_Batchable implements Database.Batchable<AggregateResult>, Database.Stateful {
    private final Vista_BatchProcessor batchProcessor = Vista_BatchProcessor_F.Create();
    private final Vista_RequestToRequestCollection_Adapter requestToRequestCollectionAdapter = new Vista_RequestToRequestCollection_Adapter();

    private static final String ORDER_NUMBER_FIELD_NAME = Schema.Vista_Request__c.MetaOrderNumber__c.getDescribe().getName();

    private set<string> processedOrderNumber= New set<string>();

    global Iterable<AggregateResult> start(Database.BatchableContext info)
    {
        String query = 'SELECT MetaOrderNumber__c orderNumber FROM Vista_Request__c WHERE Status__c=\'Unprocessed\' Group By MetaOrderNumber__c';
    	return new AggregateResultIterable(query);
        /*return Database.getQueryLocator([SELECT MetaOrderNumber__c FROM Vista_Request__c WHERE 
                Status__c='Unprocessed' ORDER BY CreatedDate]);*/
    }
    
    
    global void execute(Database.BatchableContext info, List<SObject> sobjectList)
    {
        //Set<String> orderNumbers = SObjectUtilities.GetFieldValues(sobjectList, ORDER_NUMBER_FIELD_NAME);
        AggregateResult ar = (AggregateResult)sobjectList[0];
		String orderNumber= string.valueOf(ar.get('orderNumber'));
        
        List<Vista_Request__c> requests = [SELECT Id,Vin__c,MetaOrderNumber__c,CreatedDate, CommonStatusPoint__c, EventDateTime__c, Error_Log__c, Market_Description__c,Market__c, Vehicle_Orders__c,brand__c 
                FROM Vista_Request__c WHERE Status__c='Unprocessed' AND MetaOrderNumber__c =:orderNumber];
    
        if(requests.Size() == 0) return;
        Vista_RequestCollection requestCollection = this.requestToRequestCollectionAdapter.Adapt(requests);
        try
        {
            this.batchProcessor.ProcessRequestCollection(requestCollection);
        }
        catch(exception e)
        {
            for(Vista_Request__c request : requests) {
                request.Error_Log__c = request.Error_Log__c + '\nError processing at ' + DateTime.now() + ' ' + e.getMessage() +'\n' +e.getStackTraceString();
                request.Status__c = 'Error';
            }
        }
        update requests;
    }


    global void finish(Database.BatchableContext info) 
    {
    }
}