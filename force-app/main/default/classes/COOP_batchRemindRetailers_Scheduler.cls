global class COOP_batchRemindRetailers_Scheduler implements schedulable {
  global void execute(SchedulableContext sc)
    {
        COOP_BatchRemindRetailers batch = new COOP_BatchRemindRetailers();
        database.executeBatch(batch);
    }
}