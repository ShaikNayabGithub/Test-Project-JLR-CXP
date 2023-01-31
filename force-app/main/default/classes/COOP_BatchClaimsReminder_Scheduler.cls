global class COOP_BatchClaimsReminder_Scheduler implements schedulable {
	global void execute(SchedulableContext sc)
    {
        COOP_BatchClaimsReminder batch = new COOP_BatchClaimsReminder();
        database.executeBatch(batch);
    }
}