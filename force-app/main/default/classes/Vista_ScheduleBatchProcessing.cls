public class Vista_ScheduleBatchProcessing implements Schedulable{
    public void execute(SchedulableContext SC)
    {
        Vista_RequestProcessor_Batchable batchProc = new Vista_RequestProcessor_Batchable();
        database.executeBatch(batchProc, 1);
    }
}