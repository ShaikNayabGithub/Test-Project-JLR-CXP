global class BatchCountOpenCasesPerContact implements Schedulable
{

    global void execute(SchedulableContext SC) {
        Database.executebatch(new BatchCountOpenCasesPerObject('Contact'), 500);
    }
    
}