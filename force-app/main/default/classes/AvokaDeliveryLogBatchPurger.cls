global class AvokaDeliveryLogBatchPurger implements Database.Batchable<sObject>, Schedulable{
	public Datetime cutOffDate;

	global void execute(SchedulableContext SC) {
		this.cutOffDate = Datetime.now().addDays(-7);//move to custom setting?
		Database.executebatch(this);
	}

	global Database.QueryLocator start(Database.BatchableContext info)
    {
    	return Database.getQueryLocator([Select Id From avoka__Transact_Delivery__c Where CreatedDate <:cutOffDate]);
	}
	
	
	global void execute(Database.BatchableContext info, List<sObject> recordsForDeletion)
	{
		Database.delete(recordsForDeletion);
	}

	global void finish(Database.BatchableContext info)
	{
		
    }
}