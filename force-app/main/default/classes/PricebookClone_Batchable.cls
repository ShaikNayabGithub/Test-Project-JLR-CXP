global class PricebookClone_Batchable implements Schedulable, Database.batchable<SObject>, Database.AllowsCallouts, Database.Stateful{

	global Database.QueryLocator start(Database.BatchableContext info)
    {
        return Database.getQueryLocator([SELECT Source_Pricebook__c, Destination_Pricebook__c, Destination_Currency__c FROM Pricebook_Clone__c]);
    }

	global void execute(Database.BatchableContext info, List<SObject> sobjectList)
    {
		Pricebook_Clone__c pricebookSetting = (Pricebook_Clone__c)sobjectList[0];
		PricebookCloneBuilder builder = new PricebookCloneBuilder(pricebookSetting);
		List<PricebookEntry> recordsToInsert = builder.Build();
				
		Database.insert(recordsToInsert, false);
	}

	global void finish(Database.BatchableContext info) { }

	global void execute(SchedulableContext sc)
	{
		PricebookClone_Batchable batch = new PricebookClone_Batchable();
		database.executebatch(batch, 1);
	}
}