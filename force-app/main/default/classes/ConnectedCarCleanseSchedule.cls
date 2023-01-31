public class ConnectedCarCleanseSchedule implements Schedulable {
    public void execute(SchedulableContext ctx) {
        database.executeBatch(new ConnectedCarConsentCleanseBatch());
        database.executeBatch(new ConnectedCarAlertCleanseBatch());
    }
}