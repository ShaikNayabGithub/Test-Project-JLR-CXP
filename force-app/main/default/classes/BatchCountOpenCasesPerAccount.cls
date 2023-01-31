global class BatchCountOpenCasesPerAccount implements Schedulable
{

    global void execute(SchedulableContext SC) {
        Database.executebatch(new BatchCountOpenCasesPerObject('Account'), 500);
    }
    
}