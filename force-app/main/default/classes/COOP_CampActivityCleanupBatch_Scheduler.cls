global class COOP_CampActivityCleanupBatch_Scheduler implements schedulable {
	global void execute(SchedulableContext sc)
    {
        COOP_CampActivityCleanupBatch batch = new COOP_CampActivityCleanupBatch();
        database.executeBatch(batch);
    }
}