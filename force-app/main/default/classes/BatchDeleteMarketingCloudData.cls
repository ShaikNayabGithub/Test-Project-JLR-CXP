global class BatchDeleteMarketingCloudData implements Schedulable, Database.batchable<sObject>, Database.Stateful
{
    String query;
    Static final Integer NUM_MONTHS_TO_KEEP_DATA = Integer.ValueOf(Label.NUM_MONTHS_TO_KEEP_MARKETING_CLOUD_DATA);
    
    global void execute(SchedulableContext SC) {
        Database.executebatch(new BatchDeleteMarketingCloudData(), 500);
    }

    global BatchDeleteMarketingCloudData()
    {
        Date dateUntil = System.today().addMonths(-NUM_MONTHS_TO_KEEP_DATA); //no need to check if the label is a valid integer - if not this will just fail and the batch will stop
        Datetime dtDateUntil = Datetime.newInstance(dateUntil.year(),dateUntil.month(),dateUntil.day());
        String sDateUntil = dtDateUntil.format('yyyy-MM-dd') + 'T00:00:00.000z';
        
        query = 'SELECT id from et4ae5__IndividualEmailResult__c ';         
        if (!Test.isRunningTest()) query += 'where createddate < ' + sDateUntil;
        
        system.debug('BatchDeleteMarketingCloudData.query = ' + query);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<et4ae5__IndividualEmailResult__c> MarketingCloudData)
    {
        if (NUM_MONTHS_TO_KEEP_DATA < 4) System.abortJob(BC.getJobId());
        
        if (MarketingCloudData.size()>0) {
            List<Id> mcIds = new List<Id>();
            for (String s : SObjectUtilities.getFieldValues(MarketingCloudData,'Id')) 
                mcIds.add(Id.ValueOf(s));
            if (MarketingCloudData.size()>0 && NUM_MONTHS_TO_KEEP_DATA >= 4) delete MarketingCloudData;
            Database.emptyRecycleBin(mcIds);
        }
    }
    
    global void finish(Database.BatchableContext BC)
    {
    }
    
}