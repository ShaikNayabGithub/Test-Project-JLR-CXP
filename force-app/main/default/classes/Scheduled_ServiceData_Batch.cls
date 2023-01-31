global class Scheduled_ServiceData_Batch implements Schedulable{
    global void execute(SchedulableContext ctx) {
        
        Batch_Delete_ServiceData batch = new Batch_Delete_ServiceData(); 
		Database.executeBatch(batch);
    }

}