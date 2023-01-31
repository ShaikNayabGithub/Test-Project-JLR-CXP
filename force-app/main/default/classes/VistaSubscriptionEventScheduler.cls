public class VistaSubscriptionEventScheduler implements schedulable{
    public String Status;
    
    public VistaSubscriptionEventScheduler(String Status){
        this.Status = Status;
    }
    
    public void execute(SchedulableContext SC){
        database.executeBatch(new VistaSubscriptionEventProcessor_Batch(Status),1);
    }
}