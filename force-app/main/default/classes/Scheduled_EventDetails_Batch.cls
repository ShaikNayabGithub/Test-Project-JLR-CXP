global class Scheduled_EventDetails_Batch implements Schedulable{
	global void execute(SchedulableContext ctx) {
        
        Batch_Delete_EventDetails batch = new Batch_Delete_EventDetails(); 
		Database.executeBatch(batch);
    }
}