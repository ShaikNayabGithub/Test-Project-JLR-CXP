global class ScheduleIMSLoadKorea implements Schedulable {

    Static final Integer SCHEDULED_BATCH_SIZE = Integer.ValueOf(Label.IMS_BATCH_DELTA_BATCH_SIZE);
    
    global void execute(SchedulableContext SC) {
        Database.executebatch(new BatchIMSDeltaProcessor('KR'), SCHEDULED_BATCH_SIZE);
    } 
    
}