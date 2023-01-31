global class VistaSubscriptionEventProcessor_Batch implements Database.Batchable<AggregateResult>, Database.AllowsCallouts {
    public String Status;
    
    public VistaSubscriptionEventProcessor_Batch(String Status){
        this.Status = Status;
    }
    
    global Iterable<AggregateResult> start(Database.BatchableContext BC) {
        system.debug('Status --> '+Status);
        String query;
        if(Status == 'Invalid Response'){
            query  = 'SELECT OrderNo__c orderNumber  FROM Vista_Subscription_Event__c WHERE Event__c != null AND Status__c = \'Invalid Response\' AND OrderNo__c != null GROUP BY OrderNo__c limit 49990';
            Status = 'Invalid Response';
        }else{
            query = 'SELECT OrderNo__c orderNumber  FROM Vista_Subscription_Event__c WHERE Event__c != null AND Status__c = \'Unprocessed\' AND OrderNo__c != null GROUP BY OrderNo__c limit 49990';
            Status = 'Unprocessed';
        }
        return new AggregateResultIterable(query);
    }
    
    global void execute(Database.BatchableContext BC, List<SObject> sobjectList) {
        try{
            
            set<String> eventSet = new  set<String>();
            List<String> countryIsoCodeSet = new  List<String>();
            map<String,Vista_Subscription_Event_code__mdt> eventcodeMap = Vista_Subscription_Event_code__mdt.getall();
            AggregateResult ar = (AggregateResult)sobjectList[0];
            String orderNumber= string.valueOf(ar.get('orderNumber'));
            system.debug('orderNumber --> '+orderNumber);
            system.debug('Status --> '+Status);
            List<Vista_Subscription_Event__c> eventList = new List<Vista_Subscription_Event__c>();
            List<Vista_Subscription_Event__c> notProcessedEventList = new List<Vista_Subscription_Event__c>();
            for(Vista_Subscription_Event__c eve : [SELECT 
                                                   Id, OwnerId, IsDeleted, Name, CurrencyIsoCode, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, Event_Data__c, Event__c, Source_Id__c, Source__c, Subscription_Type__c, Subscription__c, Time_Stamp__c, URL__c, OrderNo__c, Error_Message__c, Status__c, orderMarket__c, iso3Country__c 
                                                   FROM 
                                                   Vista_Subscription_Event__c
                                                   WHERE
                                                   Status__c =: Status
                                                   AND OrderNo__c =: orderNumber
                                                   AND iso3Country__c != null
                                                  ]){
                                                      if(eventcodeMap.containskey(eve.Event__c)
                                                         && eventcodeMap.get(eve.Event__c).IsActive__c
                                                         && (eventcodeMap.get(eve.Event__c).Process_For_All_Markets__c 
                                                             || (eventcodeMap.get(eve.Event__c).Available_Countries__c != null
                                                                 && !eventcodeMap.get(eve.Event__c).Available_Countries__c.split(',').isEmpty()
                                                                 && eventcodeMap.get(eve.Event__c).Available_Countries__c.split(',').contains(eve.iso3Country__c)))){
                                                                     eventList.add(eve);
                                                                 }else{
                                                                     notProcessedEventList.add(eve);
                                                                 }
                                                      
                                                  }
            system.debug('orderNumber ==> '+orderNumber);
            system.debug('eventList ==> '+json.serializePretty(eventList));
            if(orderNumber != null 
               && eventList != null 
               && !eventList.isEmpty()){
                   Boolean isExistingAsset = false;
                   List<Asset> existingAssetList = [select id from Asset where Order_Number__c =:orderNumber AND Order_Number__c != null];                   
                   if(existingAssetList != null && !existingAssetList.isEmpty()){
                       isExistingAsset = true;
                   }
                   VistaSubscriptionEventDataProcessor.processVistaData(orderNumber,eventList,isExistingAsset);                
               }
            
            if(notProcessedEventList != null && !notProcessedEventList.isEmpty()){
                VistaSubscriptionEventDataProcessor.updateVistaData(notProcessedEventList,'Not Processing');
            }
        }catch(DMLException dmx){
            system.debug('Dmx1 --> '+dmx.getStackTraceString());
            system.debug('Dmx1 --> '+dmx.getDmlMessage(0));
        }catch(exception ex){
            system.debug('ex1 --> '+ex.getStackTraceString());
            system.debug('ex2 --> '+ex.getMessage());
        }
    }   
    global void finish(Database.BatchableContext BC) {
        if(Status != 'Unprocessed') return;
        List<CronTrigger> CronTriggerList = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = 'VistaSubscriptionEventProcessor' limit 1];
        if(CronTriggerList != null && !CronTriggerList.isEmpty() && CronTriggerList.size() == 1){
            if(!Test.isRunningTest()){
                CronTrigger ctIns = CronTriggerList.get(0);
                System.abortJob(ctIns.Id);
            }
        }
        DateTime dtCurrentTime = System.now().addMinutes(5);
        String sHour = '', sMinute='', sDayOfMonth='', sMonth='', sYear='';
        sMinute = String.ValueOf(dtCurrentTime.minute());
        sHour = String.ValueOf(dtCurrentTime.hour());
        sDayOfMonth = String.ValueOf(dtCurrentTime.day());
        sMonth = String.ValueOf(dtCurrentTime.month());
        sYear = String.ValueOf(dtCurrentTime.year()); 
        if(!Test.isRunningTest()){
            System.schedule('VistaSubscriptionEventProcessor', '0 '+sMinute+' '+sHour+' '+sDayOfMonth+' '+sMonth+' ?'+' '+sYear, new VistaSubscriptionEventScheduler('Unprocessed'));
        }
    }
}