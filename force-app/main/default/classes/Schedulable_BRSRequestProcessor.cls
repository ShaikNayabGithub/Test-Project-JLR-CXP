global class Schedulable_BRSRequestProcessor implements Schedulable, Database.AllowsCallouts{
	global void execute(SchedulableContext SC) {
		BRS_RequestProcessor_Batchable_Factory batchProcessorFactory = new BRS_RequestProcessor_Batchable_Factory();
		BRS_RequestProcessor_Batchable processor = batchProcessorFactory.Build();
		Database.executebatch(processor, 3);
	}
}