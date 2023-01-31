global class aop_ScheduleEmails implements Schedulable{
    public void execute(SchedulableContext SC)
    {
    	aop_CampaignEmailBatch newBatch = new aop_CampaignEmailBatch();
    	database.executeBatch(newBatch);
    }
}