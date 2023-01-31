public class ScheduleBatchForMedalliaDataCreate implements Schedulable{
    public void execute(SchedulableContext SC) {
        Database.executebatch(new BatchForMedalliaDataCreate());
    } 
}