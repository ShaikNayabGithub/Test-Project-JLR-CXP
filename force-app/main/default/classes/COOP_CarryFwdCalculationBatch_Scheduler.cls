global class COOP_CarryFwdCalculationBatch_Scheduler Implements Schedulable {
    global void execute(SchedulableContext sc)
    {
        COOP_CarryFwdCalculationBatch batch = new COOP_CarryFwdCalculationBatch();
        database.executeBatch(batch);
    }
}