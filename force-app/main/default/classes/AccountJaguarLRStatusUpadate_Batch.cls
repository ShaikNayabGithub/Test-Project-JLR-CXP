global class AccountJaguarLRStatusUpadate_Batch implements Database.Batchable<sObject>{
    public String countryVal;
    
    public AccountJaguarLRStatusUpadate_Batch(String countryVal){
        this.countryVal = countryVal;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Id corpRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate').getRecordTypeId();
        Id individualRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();
        String query;
        if(Test.isRunningTest()){
            query = 'SELECT Id,Customer_Journey_Stage__c,ntt_Jaguar_Status__c,ntt_Land_Rover_Status__c FROM Account where Region_or_Market__c =:countryVal AND (ntt_Jaguar_Status__c = null OR ntt_Land_Rover_Status__c = null) AND (recordTypeId =: corpRecTypeId OR recordTypeId =: individualRecTypeId)';
        }else{
            query = 'SELECT Id,Customer_Journey_Stage__c,ntt_Jaguar_Status__c,ntt_Land_Rover_Status__c FROM Account where Region_or_Market__c =:countryVal AND (ntt_Jaguar_Status__c = null AND ntt_Land_Rover_Status__c = null) AND (recordTypeId =: corpRecTypeId OR recordTypeId =: individualRecTypeId)'; 
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<SObject> sobjectList){
        Account accIns = (Account)sobjectList.get(0);
        
        system.debug('accIns 1--> '+json.serialize(accIns));
        
        AccountJaguarLRStatusUpadateProcessor.handleJaguarAndLandRoverStatus(accIns);
        
        system.debug('accIns 2--> '+json.serialize(accIns));
        
        AccountJaguarLRStatusUpadateProcessor.updateLRAndJaguarStatus(accIns);  
        
        system.debug('accIns 3--> '+json.serialize(accIns));
        
        AccountJaguarLRStatusUpadateProcessor.handleLapsedStatus(accIns);  
        
        system.debug('accIns 4--> '+json.serialize(accIns));
        
        
        if(accIns.ntt_Jaguar_Status__c != null 
           || accIns.ntt_Land_Rover_Status__c != null){
               system.debug('accIns 5--> '+json.serialize(accIns));
               update accIns;
           }
    }   
    
    global void finish( Database.BatchableContext BC ) {
    }
}