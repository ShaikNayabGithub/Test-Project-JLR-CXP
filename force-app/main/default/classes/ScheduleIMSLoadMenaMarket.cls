global class ScheduleIMSLoadMenaMarket implements Schedulable{
    Static final Integer SCHEDULED_BATCH_SIZE = Integer.ValueOf(Label.IMS_BATCH_DELTA_BATCH_SIZE);
    global void execute(SchedulableContext SC) {
        Database.executebatch(new BatchIMSDeltaProcessor(Label.IMS_BATCH_MENA_MARKET));
    } 
}