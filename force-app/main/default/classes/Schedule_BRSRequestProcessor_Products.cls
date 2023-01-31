global class Schedule_BRSRequestProcessor_Products implements Schedulable {
    global void execute(SchedulableContext SC) {
        BRS_RequestProcessor_Products_BatchF batchProcessorFactory = new BRS_RequestProcessor_Products_BatchF();
        BRS_RequestProcessor_Products_Batch processor = batchProcessorFactory.Build();
        Database.executebatch(processor, 1);
    }
}