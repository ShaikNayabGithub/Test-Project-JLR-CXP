global class MembershipBatchCustomerAccountsScheduler implements Schedulable {
global void execute(SchedulableContext sc) {
       MembershipBatchCustomerAccounts job = new MembershipBatchCustomerAccounts();
       Database.executeBatch(job, 200);
    }
    
}