global class PDIQuotaBatch implements Schedulable, Database.Batchable<sObject>, database.Stateful {
    
    global void execute(SchedulableContext SC) {
        Database.executeBatch(new PDIQuotaBatch(), 200);
    } 
global Database.QueryLocator start(Database.BatchableContext bc)
{
    	String query;
    
    return null;
}
global void execute(Database.BatchableContext bc,List<Account> acc1)
{}
global void finish(Database.BatchableContext bc){}
}