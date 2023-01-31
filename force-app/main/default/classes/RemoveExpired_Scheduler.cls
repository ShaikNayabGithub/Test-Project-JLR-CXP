global class RemoveExpired_Scheduler implements Schedulable
{
    global void execute(SchedulableContext sc) 
    {
        //Instance creation to call all the batch classes
        RemoveExpiredReservedOpportunitiesBatch expiredReservedRecords = new RemoveExpiredReservedOpportunitiesBatch();
        DataBase.executeBatch(expiredReservedRecords);
        
        RemoveExpiredSaveVehicleForAccountBatch obj = new RemoveExpiredSaveVehicleForAccountBatch();
        DataBase.executeBatch(obj);
        
        RemoveExpiredSavedQuotesBatch expiredQuotesRecords = new RemoveExpiredSavedQuotesBatch();
        DataBase.executeBatch(expiredQuotesRecords);
        
        RemoveExpiredSavedVehiclesBatch expiredSavedVehiclesRecords = new RemoveExpiredSavedVehiclesBatch();
        DataBase.executeBatch(expiredSavedVehiclesRecords);
    }
}