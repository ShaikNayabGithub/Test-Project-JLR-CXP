global class RDARollupBatch_Scheduler implements schedulable {
	global void execute(SchedulableContext sc)
    {
        RDARollupBatch batch = new RDARollupBatch(false);
        database.executeBatch(batch);
    }
}