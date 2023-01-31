global class MemebrshipBatchSalesConsultantScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        MembershipBatchSalesConsultantJob job = new MembershipBatchSalesConsultantJob();
        database.executebatch(job,200);
    }
    
    //String jobID = System.schedule('My Scheduable', '0 0 10 * * ? *' , new MembershipBatchSalesConsultantJob());

}