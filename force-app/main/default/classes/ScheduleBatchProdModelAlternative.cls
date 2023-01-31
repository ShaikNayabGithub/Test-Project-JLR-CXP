global class ScheduleBatchProdModelAlternative Implements Schedulable
    {
        global void execute(SchedulableContext sc)
        {
            callSchedule();
        }

        public void callSchedule()
        {
        batchProductModelUpdater batchable= new batchProductModelUpdater();
        Database.executebatch(batchable,10);
           
        }
    }