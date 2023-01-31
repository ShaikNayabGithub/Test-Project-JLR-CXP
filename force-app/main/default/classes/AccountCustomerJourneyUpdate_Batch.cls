global class AccountCustomerJourneyUpdate_Batch implements Database.Batchable<sObject>{
    
    public String countryVal;
    
    public AccountCustomerJourneyUpdate_Batch(String countryVal){
        this.countryVal = countryVal;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Integer[] years = new Integer[] { 2022, 2021, 2020};
            Date today = system.today();
            Id corpRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate').getRecordTypeId();
        Id individualRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();
        String query = 'SELECT Id,Customer_Journey_Stage__c, Country_ISO_Code__c, RecordTypeId FROM Account where CALENDAR_YEAR(CreatedDate) IN :years AND Country_ISO_Code__c =:countryVal AND Customer_Journey_Stage__c = null AND (recordTypeId =: corpRecTypeId OR recordTypeId =: individualRecTypeId) order by lastmodifieddate desc';
        return Database.getQueryLocator(query); 
    }
    
    global void execute(Database.BatchableContext BC, List<SObject> sobjectList){
        List<Account> accListToUpdate = new List<Account>();
        Integer count = sobjectList.size();
        Id corpRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Corporate').getRecordTypeId();
        Id individualRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Individual').getRecordTypeId();
        
        Account accIns = (Account)sobjectList.get(0);
        if(accIns.RecordTypeId == corpRecTypeId || accIns.RecordTypeId == individualRecTypeId){
            AccountCustomerJourneyUpdateProcessor.checkCaseAvailableDetails(accIns);
            AccountCustomerJourneyUpdateProcessor.checkAssetRoleDetails(accIns);
            system.debug('accIns 1--> '+json.serialize(accIns));
            if(accIns != null 
               && accIns.Customer_Journey_Stage__c != 'Resolve' && accIns.Customer_Journey_Stage__c != 'Maintain'){
                   System.debug('Not Maintain and Resolve');
                   AccountCustomerJourneyUpdateProcessor.checkOpportunityAvailableDetails(accIns);
               }
            
            system.debug('accIns 2--> '+json.serialize(accIns));
            
            if(accIns.Customer_Journey_Stage__c != null){
                accListToUpdate.add(accIns);
                system.debug('accIns 5--> '+json.serialize(accIns));
                
            }
            
            if(accListToUpdate!= null){
                update accListToUpdate;
            }
        }
        
    }
    
    global void finish( Database.BatchableContext BC ) {
        
    }
}